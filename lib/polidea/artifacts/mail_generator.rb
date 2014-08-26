require 'uri'
require 'shorturl'

module Polidea::Artifacts
  class MailGenerator
    attr_accessor :installation_website_url, :app_version, :app_name, :image_url, :folder_loc
    def initialize
    end

    def generate_qr_code (url)
      if File.exist?("qr_code.png")
        File.delete("qr_code.png")
      end
      puts "generating qr code!"
      shortUlr = ShortURL.shorten(url)
      qr = RQRCode::QRCode.new(shortUlr, :size => 5, :level => :h )
      png = qr.to_img                                             # returns an instance of ChunkyPNG
      png.resize(512, 512).save("qr_code.png")
      puts "Short url: " + shortUlr.to_s
    end
  end
end

