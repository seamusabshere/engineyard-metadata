module EY
  module Metadata
    # This gets pulled in when you're running from your developer machine (i.e., not on a cloud instance).
    module Outsider
      IMPOSSIBLE = KEYS.grep(/present/) + KEYS.grep(/password/) + KEYS.grep(/mysql/)
      
      POSSIBLE = KEYS - IMPOSSIBLE
      
      IMPOSSIBLE.each do |name|
        define_method name do
          raise CannotGetFromHere
        end
      end
      
      POSSIBLE.each do |name|
        define_method name do
          engine_yard_cloud_api.send name
        end
      end
      
      def eyrc_path
        File.join File.expand_path("~#{Etc.getpwuid.name}"), '.eyrc'
      end
      
      def git_config_path
        File.join Dir.pwd, '.git', 'config'
      end

      # An adapter that reads from the public EngineYard Cloud API (https://cloud.engineyard.com)
      def engine_yard_cloud_api
        @engine_yard_cloud_api ||= EngineYardCloudApi.new
      end
    end
  end
end
