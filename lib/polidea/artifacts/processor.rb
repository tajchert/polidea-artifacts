require 'pathname'
require 'fileutils'
require 'zip'
require 'cfpropertylist'

module Polidea::Artifacts
  class Processor

    def initialize(upload_path)
      @upload_path = upload_path
    end

    def process_paths(paths)
      artifact_paths = []
      paths.each do |path|
        if /.*\.ipa/.match(path)
          process_archive(path, artifact_paths)
        else
          artifact_paths << path
        end
      end
      artifact_paths
    end

    def artifacts_dir
      'tmp/artifacts/'
    end

    private

    def process_archive(path, artifact_paths)
      manifest_file = "tmp/manifest.plist"

      dirname = File.dirname(manifest_file)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end

      # get file name without extension
      ipa_name = Pathname.new(path).basename(".*")
      unzipped_ipa_path = "tmp/zip_ipa/"
      unzip_file(path, unzipped_ipa_path)

      # process manifest
      info_plist = CFPropertyList::List.new(:file => "#{unzipped_ipa_path}Payload/#{ipa_name}.app/Info.plist")
      data = CFPropertyList.native_types(info_plist.value)
      manifest_generator = ManifestGenerator.new

      fd = IO.sysopen(manifest_file, "w")
      file_stream = IO.new(fd, "w")

      ipa_pathname = Pathname.new(path)
      manifest_generator.create_manifest(file_stream, "#{@upload_path}/#{ipa_pathname.basename}", data['CFBundleIdentifier'], data['CFBundleShortVersionString'], data['CFBundleName'])
      file_stream.close

      copy_artifact(manifest_file)
      copy_artifact(path)

      artifact_paths << "#{artifacts_dir}#{manifest_file}"
      artifact_paths << "#{artifacts_dir}#{ipa_pathname.basename}"

      FileUtils.cp(path, artifacts_dir)
      # get icon
      icon_paths = data['CFBundleIcons']
      unless icon_paths.empty?
        icon_file_names = icon_paths['CFBundlePrimaryIcon']['CFBundleIconFiles']
        unless icon_file_names.empty?
          icon_file_path = Dir["tmp/zip_ipa/Payload/#{ipa_name}.app/#{icon_file_names.first}*"].first
          icon_file_name = "#{artifacts_dir}#{Pathname.new(icon_file_path).basename}"
          copy_artifact("#{icon_file_path}")
          artifact_paths << icon_file_name
        end
      end
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
  end
end
