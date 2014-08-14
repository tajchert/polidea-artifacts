require 'spec_helper'
require 'cfpropertylist'

module Polidea::Artifacts
  describe InfoPlistParser do

    let(:parser) {
      info_plist_data = CFPropertyList::List.new(:file => "spec/res/Info.plist")
      InfoPlistParser.new(CFPropertyList.native_types(info_plist_data.value))
    }

    it 'should parse icon file name' do
      expect(parser.icon_files.count).to eq(1)
      expect(parser.icon_files[0]).to eq('AppIcon60x60')
    end

    it 'should parse application name' do
      expect(parser.app_name).to eq('PodsTest')
      end

    it 'should parse application version' do
      expect(parser.app_version).to eq('1.0')
    end

    it 'should parse bundle id' do
      expect(parser.bundle_id).to eq('com.polidea.podstest')
    end

    it 'should parse build number' do
      expect(parser.build_number).to eq('2')
    end
  end
end
