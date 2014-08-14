module Polidea
  module Artifacts
    autoload :Processor,          'polidea/artifacts/processor'
    autoload :Config,             'polidea/artifacts/config'
    autoload :S3Uploader,         'polidea/artifacts/s3_uploader'
    autoload :PageGenerator,      'polidea/artifacts/page_generator'
    autoload :ManifestGenerator,  'polidea/artifacts/manifest_generator'
    autoload :InfoPlistParser,    'polidea/artifacts/info_plist_parser'
    autoload :Cli,                'polidea/artifacts/cli'
  end
end
