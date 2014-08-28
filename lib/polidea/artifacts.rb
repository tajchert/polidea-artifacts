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
    module Android
      autoload :Apk,          'polidea/artifacts/android/apk'
      autoload :Manifest,     'polidea/artifacts/android/manifest'
      autoload :Resource,     'polidea/artifacts/android/resource'
      autoload :AXMLParser,     'polidea/artifacts/android/axml_parser'
      autoload :Dex,     'polidea/artifacts/android/dex'
    end
  end
end


