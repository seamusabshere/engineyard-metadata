gem 'nap' # gives you rest...
require 'rest'
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
      
      include SshAliasHelper
      
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
      # This is less reliable that the answer you would get running from an instance, because databases used to be named after environments.
      def database_name
        app_name
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

      # A list of all the environment names belonging to this account.
      def environment_names
        environments.map { |environment| environment['name'] }
      end
      
      # The name of the single app that runs in this environment.
      #
      # Warning: this gem currently doesn't support multiple apps per environment.
      def app_name
        data['apps'][0]['name']
      end
      
      # The path to the current deploy on app servers.
      def current_path
        "/data/#{app_name}/current"
      end
      
      # The path to the shared directory on app servers.
      def shared_path
        "/data/#{app_name}/shared"
      end
      
      # Used internally to determine whether we've decoded the API response yet.
      def data_loaded?
        defined?(@data) and @data.is_a? Hash
      end
      
      # Used internally to store the full list of environments that the API gives us.
      def environments
        return @environments if @environments.is_a? Array
        raw_json = REST.get(URL, 'X-EY-Cloud-Token' => EY::Metadata.ey_cloud_token).body
        raw_data = ActiveSupport::JSON.decode raw_json
        @environments = raw_data['environments']
      end
      
      # Used internally to store data about the specific environment we're working with.
      def data
        return @data if data_loaded?
        matching_environments = environments.select do |environment|
          if EY::Metadata.environment_name
            environment['name'] == EY::Metadata.environment_name
          else
            environment['apps'].any? { |app| app['repository_uri'] == EY::Metadata.repository_uri }
          end
        end
        raise RuntimeError, "[engineyard-metadata gem] Found too many environments: #{matching_environments.map { |environment| environments['name'] }.join(', ')}" if matching_environments.length > 1
        @data = matching_environments[0]
        raise RuntimeError, "[engineyard-metadata gem] Couldn't find an EngineYard environment with the repository uri #{repository_uri}" unless data_loaded?
        @data
      end
    end
  end
end
