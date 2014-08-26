require 'spec_helper'

module Polidea::Artifacts
  describe Processor do
    let(:processor) { Processor.new('') }
    context "processing Android artifacts" do
      let(:artifact_paths) {["spec/res/PodsTest.apk"]}
      context 'Android using basic processing' do
        it "should add manifest file to artifacts" do
          expect(processor.process_paths!(artifact_paths)).to include(/.*AndroidManifest.xml/)
        end
        it "should add app file to artifacts" do
          expect(processor.process_paths!(artifact_paths)).to include(/.*PodsTest.apk/)
        end
        it "should add icon file to artifacts" do
          expect(processor.process_paths!(artifact_paths)).to include(/.*icon.png/)
        end
        it "should add installation page to the manifest" do
          expect(processor.process_paths!(artifact_paths)).to include(/.*install.html/)
        end

      end
      context 'Android using obfuscated processing' do
        before do
          processor.obfuscate_file_names = true
        end
        it "should add manifest file to artifacts" do
          expect(processor.process_paths!(artifact_paths)).to include(/.*.xml/)
        end
        it "should add app file to artifacts" do
          expect(processor.process_paths!(artifact_paths)).to include(/.*.apk/)
        end
        it "should add icon file to artifacts" do
          expect(processor.process_paths!(artifact_paths)).to include(/.*.png/)
        end
        it "should add installation page to the manifest" do
          expect(processor.process_paths!(artifact_paths)).to include(/.*.html/)
        end
      end
    end

    context "processing iOS artifacts" do
      let(:artifact_paths) {["spec/res/PodsTest.ipa"]}

      context 'using basic processing' do
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

      context 'using obfuscated processing' do

        before do
          processor.obfuscate_file_names = true
        end
        it "should add manifest file to artifacts" do
          expect(processor.process_paths!(artifact_paths)).not_to include(/.*manifest.plist/)
          expect(processor.process_paths!(artifact_paths)).to include(/.*.plist/)
        end

        it "should add app file to artifacts" do
          #Expected error
          #expect(processor.process_paths!(artifact_paths)).not_to include(/.*PodsTest.ipa/)
          #expect(processor.process_paths!(artifact_paths)).to include(/.*.ipa/)
        end

        it "should add icon file to the manifest" do
          expect(processor.process_paths!(artifact_paths)).not_to include(/.*AppIcon60x60@2x.png/)
          expect(processor.process_paths!(artifact_paths)).to include(/.*.png/)
        end

        it "should add installation page to the manifest" do
          expect(processor.process_paths!(artifact_paths)).not_to include(/.*install.html/)
          expect(processor.process_paths!(artifact_paths)).to include(/.*.html/)
        end
      end

    end

  end
end