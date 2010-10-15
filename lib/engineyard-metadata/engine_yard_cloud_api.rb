require 'rest' # from nap gem
require 'active_support'
require 'active_support/version'
%w{
  active_support/json
}.each do |active_support_3_requirement|
  require active_support_3_requirement
end if ActiveSupport::VERSION::MAJOR == 3

module EY
  module Metadata
    # An adapter that reads from the public EngineYard Cloud API (https://cloud.engineyard.com). Available from anywhere.
    #
    # See README for what environment variables and/or files you need to have in place for this to work.
    class EngineYardCloudApi
      URL = 'https://cloud.engineyard.com/api/v2/environments'
      
      # Currently the same as the SSH username.
      def database_username
        data['ssh_username']
      end
      
      # The username for connecting by SSH.
      def ssh_username
        data['ssh_username']
      end
      
      # Currently the same as the app name, at least for recently-created environments.
      #
      # It used to be named after the environment.
      def database_name
        data['apps'][0]['name']
      end
      
      # The hostname of the database host.
      def database_host
        db_master
      end

      # The public hostname of the db_master.
      #
      # If you're on a solo app, it counts the solo as the app_master.
      def db_master
        if x = data['instances'].detect { |i| i['role'] == 'db_master' }
          x['public_hostname']
        else
          solo
        end
      end
      
      # The public hostnames of all the app servers.
      #
      # If you're on a solo app, it counts the solo as an app server.
      def app_servers
        data['instances'].select { |i| %w{ app_master app solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
      
      # The public hostnames of all the db servers.
      #
      # If you're on a solo app, it counts the solo as a db server.
      def db_servers
        data['instances'].select { |i| %w{ db_master db_slave solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
      
      # The public hostnames of all the utility servers.
      #
      # If you're on a solo app, it counts the solo as a utility.
      def utilities
        data['instances'].select { |i| %w{ util solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
      
      # The public hostnames of all the app slaves.
      def app_slaves
        data['instances'].select { |i| %w{ app }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
  
      # The public hostnames of all the db slaves.
      def db_slaves
        data['instances'].select { |i| %w{ db_slave }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
      
      # The public hostname of the app_master.
      #
      # If you're on a solo app, it counts the solo as the app_master.
      def app_master
        if x = data['instances'].detect { |i| i['role'] == 'app_master' }
          x['public_hostname']
        else
          solo
        end
      end

      # The public hostname of the solo.
      def solo
        if x = data['instances'].detect { |i| i['role'] == 'solo' }
          x['public_hostname']
        end
      end
      
      # The name of the EngineYard AppCloud environment.
      def environment_name
        data['name']
      end
      
      # The stack in use, like nginx_passenger.
      def stack_name
        data['stack_name']
      end
      
      # The git repository that you told EngineYard to use for this application.
      def repository_uri
        data['apps'][0]['repository_uri']
      end
      
      def data_loaded?
        defined?(@data) and @data.is_a? Hash
      end
      
      def data
        return @data if data_loaded?
        raw_json = REST.get(URL, 'X-EY-Cloud-Token' => EY::Metadata.ey_cloud_token).body
        raw_data = ActiveSupport::JSON.decode raw_json
        matching_environment_hshs = raw_data['environments'].select do |environment_hsh|
          if EY::Metadata.environment_name
            environment_hsh['name'] == EY::Metadata.environment_name
          else
            environment_hsh['apps'].any? { |app_hsh| app_hsh['repository_uri'] == repository_uri }
          end
        end
        raise RuntimeError, "[engineyard-metadata gem] Found too many environments: #{matching_environment_hshs.map { |hsh| hsh['name'] }.join(', ')}" if matching_environment_hshs.length > 1
        @data = matching_environment_hshs[0]
        raise RuntimeError, "[engineyard-metadata gem] Couldn't find an EngineYard environment with the repository uri #{repository_uri}" unless data_loaded?
        @data
      end
    end
  end
end
