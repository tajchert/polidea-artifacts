require 'yaml'

ROOT_PATH = './'

module Polidea::Artifacts
  class Config
    attr_reader :config

    def initialize
      if File.exists?(config_path)
        @config = YAML.load_file(config_path)
      else
        @config = {}
      end
    end

    def s3_bucket
      @config['s3_bucket']
    end

    def s3_region
      @config['s3_region']
    end

    def s3_access_key
      @config['s3_access_key']
    end

    def dropbox_token
      @config['dropbox-token']
    end

    private

    def config_path
      File.join(ROOT_PATH, 'deploy.yml')
    end
  end
end