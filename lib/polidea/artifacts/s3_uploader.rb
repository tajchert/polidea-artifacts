require 'travis/artifacts'
require 'FileUtils'
require 'fog'

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

    def upload_ipa(path)
      bucket_url = "https://#{ENV['ARTIFACTS_S3_BUCKET']}.s3.amazonaws.com/"

      puts bucket_url

      processor = Processor.new("#{bucket_url}#{@base_path}")
      processor.process_paths([path])

      travis_artifacts_path_new = Travis::Artifacts::Path.new(processor.artifacts_dir, '', './')
      s3_uploader = Travis::Artifacts::Uploader.new([travis_artifacts_path_new], {:target_path => @base_path})

      s3_uploader.upload
    end

  end

end

