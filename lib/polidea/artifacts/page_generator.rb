require 'uri'

module Polidea::Artifacts
  class PageGenerator
    def initialize

    end

    def generate_page_with_url(url)
      puts url
      ur_iencode = URI.encode_www_form_component(url)
      puts ur_iencode
      itms_url = "itms-services://?action=download-manifest&amp;url=#{ur_iencode}"

      "<html><body><a href=\"#{itms_url}\">install</a></body></html>"
    end
  end
end

