require 'uri'
require 'erb'

module Polidea::Artifacts
  class PageGenerator
    include ERB::Util

    attr_accessor :installation_link, :app_version, :app_name, :image_url
    def initialize

    end

    def generate_page_url(url)
      puts url
      file = File.open("res/installation_template.html", "r")
      contents = file.read

      if url.to_s.include? "apk"
        @installation_link = url
        contents = file.read
      else
        ur_iencode = URI.encode_www_form_component(url)
        puts ur_iencode
        itms_url = "itms-services://?action=download-manifest&amp;url=#{ur_iencode}"
        @installation_link = itms_url
      end
      ERB.new(contents).result(binding)
    end

  end
end

