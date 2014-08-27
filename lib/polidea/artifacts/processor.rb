require 'pathname'
require 'fileutils'
require 'zip'
require 'securerandom'
require 'cfpropertylist'


module Polidea::Artifacts
  class Processor
    attr_reader :project_name, :build_number, :build_version

    attr_accessor :obfuscate_file_names

    def initialize(upload_path)
      @base_upload_url = upload_path
    end

    def process_paths!(paths)
      artifact_paths = []
      paths.each do |path|
        if /.*\.ipa/.match(path)
          process_archive!(path, artifact_paths)
          end
        if /.*\.apk/.match(path)
          process_android_archive!(path, artifact_paths)
        else
          artifact_paths << path
        end
      end
      artifact_paths
    end

    def artifacts_dir
      @artifacts_dir ||= tmp_dir + 'artifacts'
    end

    def artifacts_android_dir
      @artifacts_dir ||= tmp_apk_dir + 'artifacts'
    end

    def upload_path
      @upload_path ||= "#{@project_name}/#{@build_version}_#{@build_number}_#{SecureRandom.hex(16)}"
    end

    private

    def process_archive!(path, artifact_paths)
      # remove old files and create directory if needed
      if File.directory?(artifacts_dir)
        artifacts_path = artifacts_dir + '*'
        FileUtils.rm_rf(Dir.glob(artifacts_path))
      else
        FileUtils.mkdir_p(artifacts_dir)
      end

      # copy ipa to artifacts folder and file to artifacts to copy
      ipa_pathname = copy_artifact(path, artifact_paths)

      # setup data
      parser = plist_parser!(path)
      @project_name = parser.app_name
      @build_number = parser.build_number
      @build_version = parser.app_version

      # generate manifest
      manifest_path = copy_artifact(generate_manifest(ipa_pathname, parser), artifact_paths)

      # get icon
      icon_file_path = process_icon(artifact_paths, parser)

      #generate html
      page_generator = PageGenerator.new
      page_generator.app_name = parser.app_name
      page_generator.app_version = parser.app_version
      page_generator.image_url = "#{Pathname.new(icon_file_path).basename}"

      installation_page_url = Pathname.new(tmp_dir) + 'install.html'
      File.open(installation_page_url, 'w') {|f| f.write(page_generator.generate_page_with_ipa_url(Pathname.new(@base_upload_url) + Pathname.new(upload_path) + manifest_path))}
      copy_artifact(installation_page_url, artifact_paths)
    end

    def process_android_archive!(path, artifact_paths)
      # remove old files and create directory if needed
      if File.directory?(artifacts_android_dir)
        artifacts_path = artifacts_android_dir + '*'
        FileUtils.rm_rf(Dir.glob(artifacts_path))
      else
        FileUtils.mkdir_p(artifacts_android_dir)
      end

      # copy apk to artifacts folder
      copy_artifact(path, artifact_paths)

      #Setup data
      apk = ::Android::Apk.new(path)
      @project_name = apk.manifest.label
      @build_number = apk.manifest.version_name
      @build_version = apk.manifest.version_code

      # generate manifest (readable xml form)
      File.open(File.basename("AndroidManifest.xml"), 'wb') {|f| f.write (apk.manifest.to_xml) }
      if File.file?("AndroidManifest.xml")
        manifest_path = copy_artifact("AndroidManifest.xml", artifact_paths)
        FileUtils.rm("AndroidManifest.xml")
      end
      #manifest end


      # get icon
      icons = apk.icon # { "res/drawable-hdpi/ic_launcher.png" => "\x89PNG\x0D\x0A...", ... }
      name_most_x = 0
      icons.each do |name, data|
        if (name.count "x")  > name_most_x
          name_most_x = name.count "x"
          STDOUT.puts name.count "x"
          File.open(File.basename("icon.png"), 'wb') {|f| f.write data } # save to file.
        end
      end
      if File.file?("icon.png")
        icon_file_path = copy_artifact("icon.png", artifact_paths)
        FileUtils.rm("icon.png")
      end
      #icon end


      #generate html
      page_generator = PageGenerator.new
      page_generator.app_name = @project_name
      page_generator.app_version = @build_version
      page_generator.image_url = "#{Pathname.new(icon_file_path).basename}"

      installation_page_url = Pathname.new(tmp_dir) + 'install.html'
      File.open(installation_page_url, 'w') {|f| f.write(page_generator.generate_page_with_ipa_url(Pathname.new(@base_upload_url) + Pathname.new(upload_path) + manifest_path))}
      copy_artifact(installation_page_url, artifact_paths)
    end

    def process_icon(artifact_paths, parser)
      icon_file_path = nil
      icon_paths = parser.icon_files
      unless icon_paths.nil? && icon_paths.empty?
        icon_file_path = Dir[Pathname.new(unzipped_ipa_path) + "Payload/#{@ipa_name}.app/#{icon_paths.first}*"].first
        copy_artifact(icon_file_path, artifact_paths)
      end
      icon_file_path
    end

    def plist_parser!(path)
      # get file name without extension
      @ipa_name = Pathname.new(path).basename('.*')
      unzip_file(path, unzipped_ipa_path)

      # process manifest
      plist_path = Pathname.new(unzipped_ipa_path) + "Payload/#{@ipa_name}.app/Info.plist"
      info_plist = CFPropertyList::List.new(:file => plist_path)
      data = CFPropertyList.native_types(info_plist.value)

      InfoPlistParser.new(data)
    end

    def generate_manifest(ipa_pathname, plist_parser)
      manifest_file = tmp_dir + 'manifest.plist'
      manifest_generator = ManifestGenerator.new

      fd = IO.sysopen(manifest_file, 'w')
      file_stream = IO.new(fd, 'w')

      app_name = plist_parser.app_name
      app_version = plist_parser.app_version
      manifest_generator.create_manifest(file_stream, (Pathname.new(@base_upload_url) + "#{upload_path}/#{ipa_pathname.basename}").to_s, plist_parser.bundle_id, app_version, app_name)
      file_stream.close

      manifest_file.to_s
    end

    def copy_artifact(file_name, artifact_paths)
      unless File.directory?(artifacts_dir)
        FileUtils.mkdir_p(artifacts_dir)
      end
      path = nil
      file_path = Pathname.new(file_name)
      if obfuscate_file_names
        obfuscated_file_name = artifacts_dir + Pathname.new("#{SecureRandom.hex(16)}#{file_path.extname}")
        FileUtils.cp(file_name, obfuscated_file_name)
        path = obfuscated_file_name
      else
        FileUtils.cp(file_name, artifacts_dir)
        path = artifacts_dir + file_path.basename
      end
      artifact_paths << path.to_s
      path
    end

    def create_artifact(file_name, data, artifact_paths)
      unless File.directory?(artifacts_dir)
        FileUtils.mkdir_p(artifacts_dir)
      end
      path = nil
      file_path = Pathname.new(file_name)
      if obfuscate_file_names
        obfuscated_file_name = artifacts_dir + Pathname.new("#{SecureRandom.hex(16)}#{file_path.extname}")
        File.open(obfuscated_file_name, 'w') { |file| file.write(data) }
        path = obfuscated_file_name
      else
        File.open(artifacts_dir + file_name, 'w') { |file| file.write(data) }
        path = artifacts_dir + file_path.basename
      end
      artifact_paths << path.to_s
      path
    end

    def unzip_file (file, destination)
      Zip::File.open(file) { |zip_file|
        zip_file.each { |f|
            f_path=File.join(destination, f.name)
            zip_file.extract(f, f_path) unless File.exist?(f_path)
        }
      }
    end

    def unzipped_ipa_path
      @unzipped_ipa_path ||= tmp_dir + 'zip_ipa'
    end

    def tmp_dir
      @tmp_dir ||= Pathname.new('tmp')
    end

    def unzipped_apk_path
      @unzipped_apk_path ||= tmp_apk_dir + 'zip_apk'
    end

    def tmp_apk_dir
      @tmp_apk_dir ||= Pathname.new('tmp_android')
    end

  end
end
