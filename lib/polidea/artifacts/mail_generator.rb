require 'uri'
require 'shorturl'
require 'mailgun'

module Polidea::Artifacts
  class MailGenerator
    attr_accessor :installation_website_url, :app_version, :app_name, :image_url, :folder_loc
    attr_reader :apk
    def initialize(url, icon, apk)
      @apk = apk
      @image_url = icon
      @installation_website_url = url
      generate_qr_code(@installation_website_url)
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

    def send_mail(to)
      puts "Trying to send email to: " + to
      puts image_url.to_s
      RestClient.post "https://api:key-here"\
                      "@api.mailgun.net/v2/samples.mailgun.org/messages",
                      :from => "Travis <travis@polidea.com>",
                      :to => to,
                      :subject => apk.manifest.label.to_s + " release " + apk.manifest.version_name.to_s,
                      :html => "<img src=" + image_url.to_s + " alt=" + apk.manifest.version_name.to_s+">\n<a target=\"_blank\" href=\"" + @installation_website_url.to_s + "\">Install</a>"
      puts "End of sending email"
    end
  end
end

