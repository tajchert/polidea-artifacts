require 'optparse'
require 'securerandom'

module Polidea::Artifacts
  class Cli
    attr_reader :options, :argv, :paths
    attr_accessor :command, :client

    VALID_COMMANDS = ['upload', 'dropbox_authorize']

    def initialize(argv = nil)
      @argv    = argv || ARGV
      @options = { :obfuscate_names => false }
      @paths   = []
    end

    def start
      parse!

      execute_command
    end

    def upload
      if aws_key && aws_secret && aws_bucket && aws_region
        uploader = Uploaders::S3Uploader.new(aws_key, aws_bucket, aws_region, aws_secret)
        uploader.obfuscate_names = obfuscate_names
        uploader.upload(artifact)
        config = Config.new

        return 0
      elsif dropbox_token
        Uploaders::DropboxUploader.new.upload(artifact, dropbox_token)
        return 0
      end
      STDERR.puts 'Configuration incomplete'
      STDERR.puts @opt_parser
      return 3
    end

    def dropbox_authorize
      Uploaders::DropboxUploader.new.authorize(dropbox_key, dropbox_secret)
    end

    private

    def execute_command
      if VALID_COMMANDS.include? command
        unless artifact
          STDERR.puts 'No artifact to upload specified'
          STDERR.puts @opt_parser
          return 2
        end
        return send(command)
      else
        STDERR.puts 'Could not find command ' + command
        STDERR.puts @opt_parser
        return 1
      end
    end

    def parse!
      self.command = argv[0]
      parser.parse! argv
    end

    def parser
      @opt_parser ||= begin

        OptionParser.new do |opt|
          opt.banner = 'Usage: polidea-uploader COMMAND [OPTIONS]'
          opt.separator  ''
          opt.separator  'Commands'
          opt.separator  '     upload: generates artifacts for specified file and uploads them to S3 or Dropbox'
          opt.separator  '     dropbox_authorize: generates Dropbox api access token'
          opt.separator  ''
          opt.separator  'Options'

          opt.on('--path PATH', 'path to ipa or apk tp upload to a server') do |path|
            self.artifact=path
          end

          opt.on('--aws_key KEY', 'S3 access key') do |key|
            self.aws_key = key
          end

          opt.on('--aws_secret KEY', 'S3 secret') do |key|
            self.aws_secret = key
          end

          opt.on('--aws_region REGION', 'S3 bucket region') do |region|
            self.aws_region = region
          end

          opt.on('--aws_bucket BUCKET', 'S3 bucket') do |bucket|
            self.aws_bucket = bucket
          end

          opt.on('--dropbox_key KEY', 'Dropbox app key') do |key|
            self.dropbox_key = key
          end

          opt.on('--dropbox_secret SECRET', 'Dropbox app secret') do |secret|
            self.dropbox_secret = secret
          end

          opt.on('--dropbox_token TOKEN', 'Dropbox api token') do |token|
            self.dropbox_token = token
          end

          opt.on('--obfuscate_names', 'Obfuscate uploaded file names') do
            self.obfuscate_names = true
          end

          opt.on('-h','--help', 'help') do
            puts @opt_parser
          end
        end
      end
    end

    def obfuscate_names=(obfuscate)
      options[:obfuscate_names] = obfuscate
    end

    def obfuscate_names
      options[:obfuscate_names]
    end

    def dropbox_token=(token)
      options[:dropbox_token] = token
    end

    def dropbox_token
      options[:dropbox_token]
    end

    def dropbox_key=(key)
      options[:dropbox_key] = key
    end

    def dropbox_key
      options[:dropbox_key]
    end

    def dropbox_secret=(secret)
      options[:dropbox_secret] = secret
    end

    def dropbox_secret
      options[:dropbox_secret]
    end

    def artifact
      options[:path]
    end

    def artifact=(path)
      options[:path] = path
    end

    def aws_secret
      options[:aws_secret]
    end

    def aws_secret=(secret)
      options[:aws_secret] = secret
    end

    def aws_key
      options[:aws_key]
    end

    def aws_key=(key)
      options[:aws_key] = key
    end

    def aws_bucket
      options[:aws_bucket]
    end

    def aws_bucket=(bucket)
      options[:aws_bucket] = bucket
    end

    def aws_region
      options[:aws_region]
    end

    def aws_region=(region)
      options[:aws_region] = region
    end

  end
end