require 'dropbox_sdk'
require 'securerandom'

module Polidea::Artifacts::Uploaders

  class DropboxUploader
    def initialize

    end

    def authorize(dropbox_app_key, dropbox_app_secret)
      flow = DropboxOAuth2FlowNoRedirect.new(dropbox_app_key, dropbox_app_secret)
      authorize_url = flow.start

      # Have the user sign in and authorize this app
      puts '1. Go to: ' + authorize_url
      puts '2. Click "Allow" (you might have to log in first)'
      puts '3. Copy the authorization code'
      print 'Enter the authorization code here: '
      code = $stdin.gets.strip

      # This will fail if the user gave us an invalid authorization code
      access_token, user_id = flow.finish(code)

      puts 'Access token = ' + access_token

      client = DropboxClient.new(access_token)
      puts "linked account:", client.account_info.inspect
    end

    def upload(path_to_ipa, api_token)
      client = DropboxClient.new(api_token)
      puts "linked account:", client.account_info.inspect

      processor = Polidea::Artifacts::Processor.new('')
      processor.process_paths!([path_to_ipa])

      file = open(path_to_ipa)
      response = client.put_file("/#{processor.project_name}/#{processor.build_version}_#{processor.build_number}_#{SecureRandom.hex(16)}/#{Pathname.new(path_to_ipa).basename}", file)
      puts "uploaded:", response.inspect
    end
  end
end

