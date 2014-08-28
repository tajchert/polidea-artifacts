require 'uri'
require 'erb'

module Polidea::Artifacts
  class PageGenerator
    include ERB::Util

    attr_accessor :installation_link, :app_version, :app_name, :image_url
    def initialize

    end

    def generate_page_with_ipa_url(url)
      puts url
      ur_iencode = URI.encode_www_form_component(url)
      puts ur_iencode
      itms_url = "itms-services://?action=download-manifest&amp;url=#{ur_iencode}"
      @installation_link = itms_url

      file = File.open("res/installation_template.html", "r")
      contents = file.read

      ERB.new(contents).result(binding)

    end
    def generate_page_with_apk_url(url)
      puts url
      #ur_iencode = URI.encode_www_form_component(url)
      puts url
      #itms_url = "itms-services://?action=download-manifest&amp;url=#{ur_iencode}"
      @installation_link = url

      file = File.open("res/installation_template.html", "r")
      contents = file.read

      ERB.new(contents).result(binding)

    end
  end
end

