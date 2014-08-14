require 'optparse'
require 'securerandom'

module Polidea::Artifacts
  class Cli
    attr_reader :options, :argv, :paths
    attr_accessor :command, :client

    VALID_COMMANDS = ['upload']

    def initialize(argv = nil)
      @argv    = argv || ARGV
      @options = {}
      @paths   = []
    end

    def start
      parse!

      execute_command
    end

    def upload
      S3Uploader.new(aws_key, aws_bucket, aws_region, aws_secret).upload(artifact)
    end

    private

    def execute_command
      if VALID_COMMANDS.include? command
        send(command)
        return 0
      else
        STDERR.puts 'Could not find command'
        return 1
      end
    end

    def fetch_paths
      options[:paths]
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
          opt.separator  '     upload: generates artifacts for specified file and uploads them to S3'
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

          opt.on('-h','--help', 'help') do
            puts @opt_parser
          end
        end
      end
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