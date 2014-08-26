require 'aws/s3'
require 'fileutils'
require 'rqrcode_png'

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

      bucket_url = bucket.url.sub 'http:', 'https:'

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

      mail_generator = Polidea::Artifacts::MailGenerator.new
      #mail_generator.folder_loc = upload_path
      # mail_generator.app_version = @build_version
      # mail_generator.image_url = "#{Pathname.new(icon_file_path).basename}"
      file_mapping = {}
      paths.each do |artifact_path|
        pathname = Pathname.new(upload_path)
        key = key_for_artifact(artifact_path)
        unless key.nil?
          pathname = pathname + "#{Pathname.new(artifact_path).basename}"
          file_mapping[key] = "#{pathname.to_s}"
          puts key.to_s
          puts pathname.to_s
          if key.to_s == "installation_page"
            mail_generator.installation_website_url = pathname.to_s
          end
          if key.to_s == "icon"
            mail_generator.image_url = pathname.to_s
          end
        end
      end
      mail_generator.generate_qr_code(mail_generator.installation_website_url)


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

