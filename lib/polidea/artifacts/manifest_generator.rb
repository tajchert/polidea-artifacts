require 'cfpropertylist'

module Polidea::Artifacts
  class ManifestGenerator
    def initialize ()
    end

    def create_manifest (manifest_stream, url_to_ipa, bundle_id, app_version, app_name)

      ipa_dict = {:kind => 'software-package', :url => url_to_ipa}
      metadata_dict = {:'bundle-identifier' => bundle_id, :'bundle-version' => app_version, :title => app_name, :kind => 'software'}

      items_dict = {:items => [{:assets => [ipa_dict], :metadata => metadata_dict}]}

      manifest_stream << items_dict.to_plist({:plist_format => CFPropertyList::List::FORMAT_XML})
    end
  end

end
