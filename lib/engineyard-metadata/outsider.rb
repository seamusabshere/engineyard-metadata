require 'etc'
require 'yaml'

module EY
  module Metadata
    # This gets pulled in when you're running from your developer machine (i.e., not on a cloud instance).
    module Outsider
      LOCALLY_DETERMINED = %w{ environment_name repository_uri }
      UNGETTABLE = KEYS.grep(/present/) + KEYS.grep(/password/) + KEYS.grep(/mysql/)
      
      GETTABLE = KEYS - LOCALLY_DETERMINED - UNGETTABLE
      
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
      
      def git_config_path
        File.join Dir.pwd, '.git', 'config'
      end
      
      def clear
        @repository_uri = nil
        @environment_name = nil
        @ey_cloud_token = nil
        @engine_yard_cloud_api = nil
      end
      
      def environment_name=(str)
        # clear this out in case it was inferred
        @repository_uri = nil
        # clear this out in case we're looking up a new environment
        @engine_yard_cloud_api = nil
        @environment_name = str
      end
      
      # The name of the EngineYard AppCloud environment.
      def environment_name
        return @environment_name if @environment_name.is_a? String
        @environment_name = if engine_yard_cloud_api.data_loaded?
          # this happens when we don't get any help from the user and the environment has been found based on the repository uri
          engine_yard_cloud_api.environment_name
        elsif ENV['EY_ENVIRONMENT_NAME']
          ENV['EY_ENVIRONMENT_NAME']
        end
        raise RuntimeError, "[engineyard-metadata gem] You need to run this from the application repo, set EY::Metadata.environment_name= or set ENV['EY_ENVIRONMENT_NAME']" unless @environment_name.to_s.strip.length > 0
        @environment_name
      end
      
      def ey_cloud_token=(str)
        # clear this out in case it was inferred
        @repository_uri = nil
        # clear this out in case we're looking up a new environment
        @engine_yard_cloud_api = nil
        @ey_cloud_token = str
      end

      # The secret API token to access https://cloud.engineyard.com
      def ey_cloud_token
        return @ey_cloud_token if @ey_cloud_token.is_a? String
        @ey_cloud_token = if ENV['EY_CLOUD_TOKEN']
          ENV['EY_CLOUD_TOKEN']
        elsif File.exist? eyrc_path
          YAML.load(File.read(eyrc_path))['api_token']
        end
        raise RuntimeError, "[engineyard-metadata gem] You need to have #{eyrc_path}, set EY::Metadata.ey_cloud_token= or set ENV['EY_CLOUD_TOKEN']" unless @ey_cloud_token.to_s.strip.length > 0
        @ey_cloud_token
      end
      
      # The URL that EngineYard has on file for your application.
      #
      # There's no setter for this because you should really use EY::Metadata.environment_name= or ENV['EY_ENVIRONMENT_NAME']
      def repository_uri
        return @repository_uri if @repository_uri.is_a? String
        @repository_uri = if engine_yard_cloud_api.data_loaded?
          engine_yard_cloud_api.repository_uri
        elsif ENV['EY_REPOSITORY_URI']
          ENV['EY_REPOSITORY_URI']
        elsif File.exist? git_config_path
          git_config = File.read git_config_path
          git_config =~ /^\[remote.*?\burl = (.*?)\n/m
          $1
        end
        raise RuntimeError, "[engineyard-metadata gem] Please set EY::Metadata.environment_name= or set ENV['EY_ENVIRONMENT_NAME']" unless @repository_uri.to_s.strip.length > 0
        @repository_uri
      end

      # An adapter that reads from the public EngineYard Cloud API (https://cloud.engineyard.com)
      def engine_yard_cloud_api
        @engine_yard_cloud_api ||= EngineYardCloudApi.new
      end
    end
  end
end
