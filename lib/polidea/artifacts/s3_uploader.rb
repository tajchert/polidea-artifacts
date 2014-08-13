require 'travis/artifacts'
require 'FileUtils'

module Polidea::Artifacts

  class S3Uploader
    def initialize(base_path, aws_access_key, aws_bucket, aws_region, aws_secret)
      @base_path = base_path

      @config = Config.new
      ENV['ARTIFACTS_AWS_ACCESS_KEY_ID'] = aws_access_key
      ENV['ARTIFACTS_S3_BUCKET'] = aws_bucket
      ENV['ARTIFACTS_AWS_SECRET_ACCESS_KEY'] = aws_secret
      ENV['ARTIFACTS_AWS_REGION'] = aws_region

    end

    def upload(path)
      bucket_url = "https://#{ENV['ARTIFACTS_S3_BUCKET']}.s3.amazonaws.com/"

      puts bucket_url

      upload_path = "#{bucket_url}#{@base_path}"
      processor = Processor.new(upload_path)
      paths = processor.process_paths([path])

      travis_artifacts_path_new = Travis::Artifacts::Path.new(processor.artifacts_dir, '', './')
      s3_uploader = Travis::Artifacts::Uploader.new([travis_artifacts_path_new], {:target_path => @base_path})

      s3_uploader.upload


      file_mapping = {}
      paths.each do |artifact_path|
        pathname = Pathname.new(upload_path)
        key = key_for_artifact(artifact_path)
        unless key.nil?
          pathname = pathname + "#{Pathname.new(artifact_path).basename}"
          file_mapping[key] = "#{pathname.to_s}"
        end
      end

      puts '====='
      puts 'Uploaded artifacts:'
      puts file_mapping
      puts '====='

      file_mapping
    end

    def key_for_artifact(artifact_path)
      artifact_extension = File.extname(artifact_path)

      case artifact_extension
        when '.ipa'
          return :ipa
        when '.png'
          return :icon
        when '.plist'
          return :manifest
        when '.html'
          return :installation_page
      end

      nil
    end

  end

end

