module Polidea
  module Artifacts
    autoload :Processor,          'polidea/artifacts/processor'
    autoload :Config,             'polidea/artifacts/config'
    autoload :PageGenerator,      'polidea/artifacts/page_generator'
    autoload :ManifestGenerator,  'polidea/artifacts/manifest_generator'
    autoload :InfoPlistParser,    'polidea/artifacts/info_plist_parser'
    autoload :Cli,                'polidea/artifacts/cli'
    module Uploaders
      autoload :S3Uploader,       'polidea/artifacts/uploaders/s3_uploader'
      autoload :DropboxUploader,  'polidea/artifacts/uploaders/dropbox_uploader'
    end
  end
end
