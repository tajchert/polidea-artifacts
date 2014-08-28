require 'aws/s3'
require 'fileutils'

module Polidea::Artifacts::Uploaders

  class S3Uploader

    attr_accessor :obfuscate_names

    def initialize(aws_access_key, aws_bucket, aws_region, aws_secret)
      @access_key = aws_access_key
      @bucket = aws_bucket
      @secret = aws_secret
      @region = aws_region

    end

    def upload(path)
      s3 = AWS::S3.new(:access_key_id => @access_key, :secret_access_key => @secret, :region => @region)
      bucket = s3.buckets[@bucket]

      bucket_url = bucket.url

      puts bucket_url

      # TODO check how to do it better
      processor = Polidea::Artifacts::Processor.new(bucket_url)
      processor.obfuscate_file_names = obfuscate_names
      paths = processor.process_paths!([path])
      upload_path = Pathname.new(bucket_url) + processor.upload_path

      paths.each do |f|
        pathname = Pathname.new(processor.upload_path) + Pathname.new(f).basename
        obj = bucket.objects[pathname]
        obj.write(Pathname.new(f), :acl => :public_read)
      end

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

