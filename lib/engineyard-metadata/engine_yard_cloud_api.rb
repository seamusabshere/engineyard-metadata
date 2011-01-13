gem 'nap' # gives you rest...
require 'rest'
require 'active_support'
require 'active_support/version'
%w{
  active_support/json
  active_support/core_ext/enumerable
}.each do |active_support_3_requirement|
  require active_support_3_requirement
end if ActiveSupport::VERSION::MAJOR == 3

module EY
  class Metadata
    # An adapter that reads from the public EngineYard Cloud API (https://cloud.engineyard.com). Available from anywhere.
    #
    # See README for what environment variables and/or files you need to have in place for this to work.
    class EngineYardCloudApi
      attr_reader :last_used_ey_cloud_token
      URL = 'https://cloud.engineyard.com/api/v2/environments'
      
      include SshAliasHelper
      
      def initialize(last_used_ey_cloud_token)
        @last_used_ey_cloud_token = last_used_ey_cloud_token
      end
      
      # Currently the same as the SSH username.
      def database_username
        environment['ssh_username']
      end
      
      # The username for connecting by SSH.
      def ssh_username
        environment['ssh_username']
      end
      
      # Currently the same as the app name, at least for recently-created environments.
      #
      # This is less reliable that the answer you would get running from an instance, because databases used to be named after environments.
      def database_name
        EY.metadata.app_name
      end
      
      # The hostname of the database host.
      def database_host
        db_master
      end

      # The public hostname of the db_master.
      #
      # If you're on a solo app, it counts the solo as the app_master.
      def db_master
        if x = environment['instances'].detect { |i| i['role'] == 'db_master' }
          x['public_hostname']
        else
          solo
        end
      end
      
      # The public hostnames of all the app servers.
      #
      # If you're on a solo app, it counts the solo as an app server.
      def app_servers
        environment['instances'].select { |i| %w{ app_master app solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
      
      # The public hostnames of all the db servers.
      #
      # If you're on a solo app, it counts the solo as a db server.
      def db_servers
        environment['instances'].select { |i| %w{ db_master db_slave solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
      
      # The public hostnames of all the utility servers.
      #
      # If you're on a solo app, it counts the solo as a utility.
      def utilities
        environment['instances'].select { |i| %w{ util solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
      
      # The public hostnames of all the app slaves.
      def app_slaves
        environment['instances'].select { |i| %w{ app }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
  
      # The public hostnames of all the db slaves.
      def db_slaves
        environment['instances'].select { |i| %w{ db_slave }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
      
      # The public hostname of the app_master.
      #
      # If you're on a solo app, it counts the solo as the app_master.
      def app_master
        if x = environment['instances'].detect { |i| i['role'] == 'app_master' }
          x['public_hostname']
        else
          solo
        end
      end

      # The public hostname of the solo.
      def solo
        if x = environment['instances'].detect { |i| i['role'] == 'solo' }
          x['public_hostname']
        end
      end
      
      # The name of the EngineYard AppCloud environment.
      def environment_name
        environment['name']
      end
      
      # The stack in use, like nginx_passenger.
      def stack_name
        environment['stack_name']
      end
      
      # The git repository that you told EngineYard to use for this application.
      def repository_uri
        application['repository_uri']
      end
      
      # A list of all the environment names belonging to this account.
      def environment_names
        environments.map { |environment| environment['name'] }
      end
      
      # The name of the app we're looking at.
      def app_name
        application['name']
      end
      
      # Used internally to store the full list of environments that the API gives us.
      def environments
        return @environments if @environments.is_a? Array
        raw_json = REST.get(URL, 'X-EY-Cloud-Token' => last_used_ey_cloud_token).body
        raw_data = ActiveSupport::JSON.decode raw_json
        @environments = raw_data['environments']
      end
      
      # Used internally to store data about the specific application we're working with.
      def application
        hit = if EY.metadata.preset_app_name?
          catch(:found_it) do
            environments.each do |e|
              if hit = e['apps'].detect { |a| a['name'] == EY.metadata.app_name }
                throw :found_it, hit
              end
            end
          end
        elsif possible_to_detect_app_from_environment_name?
          environment['apps'][0]
        elsif possible_to_detect_app_from_git_config?
          catch(:found_it) do
            environments.each do |e|
              if hit = e['apps'].detect { |a| a['repository_uri'] == repository_uri_from_git_config }
                throw :found_it, hit
              end
            end
          end
        end
        raise RuntimeError, "[engineyard-metadata gem] Couldn't find a matching application. Please set EY.metadata.app_name= or ENV['EY_APP_NAME']" unless hit
        hit
      end
      
      def repository_uri_from_git_config
        return @repository_uri_from_git_config if @repository_uri_from_git_config.is_a? String
        git_config_path = File.join Dir.pwd, '.git', 'config'
        if File.exist? git_config_path
          git_config = File.read git_config_path
          git_config =~ /^\[remote.*?\burl = (.*?)\n/m
          @repository_uri_from_git_config = $1
        end
      end
      
      def possible_to_detect_app_from_environment_name?
        environment['apps'].length == 1
      end
      
      def possible_to_detect_environment_from_app_name?
        return false unless EY.metadata.preset_app_name?
        environments.sum { |e| e['apps'].sum { |a| (a['name'] == EY.metadata.app_name) ? 1 : 0 } } == 1
      end
      
      def possible_to_detect_app_from_git_config?
        return false unless repository_uri_from_git_config
        environments.sum { |e| e['apps'].sum { |a| (a['repository_uri'] == repository_uri_from_git_config) ? 1 : 0 } } == 1
      end
      
      def possible_to_detect_environment_from_git_config?
        return false unless repository_uri_from_git_config
        environments.any? { |e| e['apps'].any? { |a| a['repository_uri'] == repository_uri_from_git_config } }
      end
      
      # Used internally to store data about the specific environment we're working with.
      def environment
        hit = if EY.metadata.preset_environment_name?
          environments.detect { |e| e['name'] == EY.metadata.environment_name }
        elsif possible_to_detect_environment_from_app_name?
          environments.detect { |e| e['apps'].any? { |a| a['name'] == EY.metadata.app_name } }
        elsif possible_to_detect_environment_from_git_config?
          environments.detect { |e| e['apps'].any? { |a| a['repository_uri'] == repository_uri_from_git_config } }
        end
        raise RuntimeError, "[engineyard-metadata gem] Couldn't find a matching environment. Please set EY.metadata.environment_name= or ENV['EY_ENVIRONMENT_NAME']" unless hit
        hit
      end
    end
  end
end
