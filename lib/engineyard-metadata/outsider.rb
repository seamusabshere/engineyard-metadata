require 'etc'
require 'yaml'

module EY
  class Metadata
    # This gets pulled in when you're running from your developer machine (i.e., not on a cloud instance).
    module Outsider
      UNGETTABLE = METHODS.grep(/present/) + METHODS.grep(/password/) + METHODS.grep(/mysql/)
      
      GETTABLE = METHODS - UNGETTABLE - %w{ environment_name }
      
      UNGETTABLE.each do |name|
        define_method name do
          raise CannotGetFromHere
        end
      end
      
      GETTABLE.each do |name|
        define_method name do
          engine_yard_cloud_api.send name
        end
      end
      
      def eyrc_path
        File.join File.expand_path("~#{Etc.getpwuid.name}"), '.eyrc'
      end
      
      def preset_app_name?
        @app_name.is_a?(String) or ENV['EY_APP_NAME']
      end
      
      def app_name
        return @app_name if @app_name.is_a?(String)
        if ENV['EY_APP_NAME']
          @app_name = ENV['EY_APP_NAME']
        elsif engine_yard_cloud_api.possible_to_detect_app_from_environment_name?
          @app_name = engine_yard_cloud_api.app_name
        elsif engine_yard_cloud_api.possible_to_detect_app_from_git_config?
          @app_name = engine_yard_cloud_api.app_name
        end
        @app_name
      end
      
      def preset_environment_name?
        @environment_name.is_a?(String) or ENV['EY_ENVIRONMENT_NAME']
      end

      # Sets the environment you want, in case it can't be detected from ENV['EY_ENVIRONMENT_NAME'] or .git/config
      def environment_name=(str)
        @environment_name = str
      end
      
      # The name of the EngineYard AppCloud environment.
      def environment_name
        return @environment_name if @environment_name.is_a? String
        if ENV['EY_ENVIRONMENT_NAME']
          @environment_name = ENV['EY_ENVIRONMENT_NAME']
        elsif engine_yard_cloud_api.possible_to_detect_environment_from_git_config?
          @environment_name = engine_yard_cloud_api.environment_name
        end
        raise RuntimeError, "[engineyard-metadata gem] You need to run this from the application repo, set EY.metadata.environment_name= or set ENV['EY_ENVIRONMENT_NAME']" unless @environment_name.to_s.strip.length > 0
        @environment_name
      end
      
      # Sets the (secret) cloud token, in case it's not in ENV['EY_CLOUD_TOKEN'] or ~/.eyrc
      def ey_cloud_token=(str)
        @engine_yard_cloud_api = nil # because it depends on cloud token
        @ey_cloud_token = str
      end
      
      # The secret API token to access https://cloud.engineyard.com
      def ey_cloud_token
        return @ey_cloud_token if @ey_cloud_token.is_a? String
        if ENV['EY_CLOUD_TOKEN']
          @ey_cloud_token = ENV['EY_CLOUD_TOKEN']
        elsif File.exist? eyrc_path
          @ey_cloud_token = YAML.load(File.read(eyrc_path))['api_token']
        end
        raise RuntimeError, "[engineyard-metadata gem] You need to have #{eyrc_path}, set EY.metadata.ey_cloud_token= or set ENV['EY_CLOUD_TOKEN']" unless @ey_cloud_token.to_s.strip.length > 0
        @ey_cloud_token
      end

      # An adapter that reads from the public EngineYard Cloud API (https://cloud.engineyard.com)
      def engine_yard_cloud_api
        @engine_yard_cloud_api ||= EngineYardCloudApi.new ey_cloud_token
      end
    end
  end
end
