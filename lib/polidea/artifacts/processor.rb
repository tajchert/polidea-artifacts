require 'pathname'
require 'fileutils'
require 'zip'
require 'securerandom'
require 'cfpropertylist'

module Polidea::Artifacts
  class Processor

    attr_reader :project_name, :build_number, :build_version

    def initialize(upload_path)
      @bucket_url = upload_path
    end

    def process_paths(paths)
      artifact_paths = []
      paths.each do |path|
        if /.*\.ipa/.match(path)
          process_archive!(path, artifact_paths)
        else
          artifact_paths << path
        end
      end
      artifact_paths
    end

    def artifacts_dir
      'tmp/artifacts/'
    end

    def upload_path
      @upload_path ||= "#{@project_name}/#{@build_version}_#{@build_number}_#{SecureRandom.hex(16)}"
    end

    private

    def process_archive!(path, artifact_paths)
      # remove old files and create directory if needed
      if File.directory?(artifacts_dir)
        artifacts_path = Pathname.new(artifacts_dir) + '*'
        FileUtils.rm_rf(Dir.glob(artifacts_path.to_s))
      else
        FileUtils.mkdir_p(artifacts_dir)
      end

      # copy ipa to artifacts folder and file to artifacts to copy
      copy_artifact(path)
      ipa_pathname = Pathname.new(path)
      FileUtils.cp(path, artifacts_dir)
      artifact_paths << "#{artifacts_dir}#{ipa_pathname.basename}"

      # setup data
      parser = plist_parser!(path)
      @project_name = parser.app_name
      @build_number = parser.build_number
      @build_version = parser.app_version

      # generate manifest
      artifact_paths << generate_manifest(ipa_pathname, parser)

      # get icon
      icon_file_path = process_icon(artifact_paths, parser)

      #generate html
      page_generator = PageGenerator.new
      page_generator.app_name = parser.app_name
      page_generator.app_version = parser.app_version
      page_generator.image_url = "#{Pathname.new(icon_file_path).basename}"

      installation_page_url = "#{artifacts_dir}install.html"
      File.open(installation_page_url, 'w') {|f| f.write(page_generator.generate_page_with_ipa_url("#{@bucket_url}/#{upload_path}/manifest.plist"))}
      artifact_paths << installation_page_url
    end

    def process_icon(artifact_paths, parser)
      icon_file_path = nil
      icon_paths = parser.icon_files
      unless icon_paths.nil? && icon_paths.empty?
        icon_file_path = Dir["#{unzipped_ipa_path}Payload/#{@ipa_name}.app/#{icon_paths.first}*"].first
        icon_file_name = "#{artifacts_dir}#{Pathname.new(icon_file_path).basename}"
        copy_artifact("#{icon_file_path}")
        artifact_paths << icon_file_name
      end
      icon_file_path
    end

    def plist_parser!(path)
      # get file name without extension
      @ipa_name = Pathname.new(path).basename('.*')
      unzip_file(path, unzipped_ipa_path)

      # process manifest
      info_plist = CFPropertyList::List.new(:file => "#{unzipped_ipa_path}Payload/#{@ipa_name}.app/Info.plist")
      data = CFPropertyList.native_types(info_plist.value)

      InfoPlistParser.new(data)
    end

    def generate_manifest(ipa_pathname, plist_parser)
      manifest_file = "#{artifacts_dir}manifest.plist"
      manifest_generator = ManifestGenerator.new

      fd = IO.sysopen(manifest_file, 'w')
      file_stream = IO.new(fd, 'w')

      app_name = plist_parser.app_name
      app_version = plist_parser.app_version
      manifest_generator.create_manifest(file_stream, "#{@bucket_url}/#{upload_path}/#{ipa_pathname.basename}", plist_parser.bundle_id, app_version, app_name)
      file_stream.close

      "#{artifacts_dir}#{manifest_file}"
    end

    def copy_artifact(file_name)
      unless File.directory?(artifacts_dir)
        FileUtils.mkdir_p(artifacts_dir)
      end
      FileUtils.cp(file_name, artifacts_dir)
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
      'tmp/zip_ipa/'
    end

  end
end
