require 'spec_helper'

module Polidea::Artifacts
  describe ManifestGenerator do
    let (:manifest_generator) { ManifestGenerator.new }
    let (:app_url) {"url_to_ipa"}
    let (:bundle_id) {"bundle_id"}
    let (:bundle_version) {"bundle_version"}
    let (:title) {"title"}

    it 'should generate manifest plist with url to IPA' do
      s = StringIO.new('')
      manifest_generator.create_manifest(s, app_url, bundle_id, bundle_version, title)
      info_plist = CFPropertyList::List.new(:data => s.string)
      plist_obj = CFPropertyList.native_types(info_plist.value)
      items = plist_obj['items']
      expect(items).to_not be_nil

      assets_dict = nil
      items.each do |item|
        if item['assets']
          assets_dict = item['assets']
        end
      end

      expect(assets_dict).to_not be_nil
      expect(assets_dict[0]).to_not be_nil
      expect(assets_dict[0]['url'] == app_url).to be_truthy
    end

    it 'should generate manifest plist with bundle id' do
      s = StringIO.new('')
      manifest_generator.create_manifest(s, app_url, bundle_id, bundle_version, title)
      info_plist = CFPropertyList::List.new(:data => s.string)
      plist_obj = CFPropertyList.native_types(info_plist.value)
      items = plist_obj['items']
      expect(items).to_not be_nil

      metadata_dict = nil
      items.each do |item|
        if item['metadata']
          metadata_dict = item['metadata']
        end
      end

      expect(metadata_dict).to_not be_nil
      expect(metadata_dict['bundle-identifier']).to eq(bundle_id)
    end

    it 'should generate manifest plist with bundle version' do
      s = StringIO.new('')
      manifest_generator.create_manifest(s, app_url, bundle_id, bundle_version, title)
      info_plist = CFPropertyList::List.new(:data => s.string)
      plist_obj = CFPropertyList.native_types(info_plist.value)
      items = plist_obj['items']
      expect(items).to_not be_nil

      metadata_dict = nil
      items.each do |item|
        if item['metadata']
          metadata_dict = item['metadata']
        end
      end

      expect(metadata_dict).to_not be_nil
      expect(metadata_dict['bundle-version']).to eq(bundle_version)
    end

    it 'should generate manifest plist with app title' do
      s = StringIO.new('')
      manifest_generator.create_manifest(s, app_url, bundle_id, bundle_version, title)
      info_plist = CFPropertyList::List.new(:data => s.string)
      plist_obj = CFPropertyList.native_types(info_plist.value)
      items = plist_obj['items']
      expect(items).to_not be_nil

      metadata_dict = nil
      items.each do |item|
        if item['metadata']
          metadata_dict = item['metadata']
        end
      end

      expect(metadata_dict).to_not be_nil
      expect(metadata_dict['title']).to eq(title)
    end
  end
end