require 'spec_helper'

module Polidea::Artifacts
  describe Processor do
    let(:processor) { Processor.new('') }

    context "processing iOS artifacts" do
      let(:artifact_paths) {["spec/res/PodsTest.ipa"]}
      it "should add manifest file to artifacts" do
        expect(processor.process_paths!(artifact_paths)).to include(/.*manifest.plist/)
      end

      it "should add app file to artifacts" do
        expect(processor.process_paths!(artifact_paths)).to include(/.*PodsTest.ipa/)
      end

      it "should add icon file to the manifest" do
        expect(processor.process_paths!(artifact_paths)).to include(/.*AppIcon60x60@2x.png/)
      end

      it "should add installation page to the manifest" do
        expect(processor.process_paths!(artifact_paths)).to include(/.*install.html/)
      end
    end
  end
end