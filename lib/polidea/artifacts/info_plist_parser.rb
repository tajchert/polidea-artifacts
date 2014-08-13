module Polidea::Artifacts
  class InfoPlistParser
    def initialize(plist_data)
      @plist_data = plist_data
    end

    def icon_files
      icons = @plist_data['CFBundleIcons']

      unless icons.nil?
        primary_icon = icons['CFBundlePrimaryIcon']

        unless primary_icon.nil?
          return primary_icon['CFBundleIconFiles']
        end
      end

      nil
    end

    def app_name
      @plist_data['CFBundleName']
    end

    def app_version
      @plist_data['CFBundleShortVersionString']
    end

    def bundle_id
      @plist_data['CFBundleIdentifier']
    end

  end
end

