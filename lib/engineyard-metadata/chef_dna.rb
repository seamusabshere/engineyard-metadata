require 'active_support/version'
%w{
  active_support/json
}.each do |active_support_3_requirement|
  require active_support_3_requirement
end if ActiveSupport::VERSION::MAJOR == 3

module EY
  module Metadata
    class ChefDna
      PATH = '/etc/chef/dna.json'
      
      def data # :nodoc:
        @data ||= ActiveSupport::JSON.decode File.read(PATH)
      end
    
      # The present instance's public hostname.
      def present_public_hostname
        data['engineyard']['environment']['instances'].detect { |i| i['id'] == EY::Metadata.present_instance_id }['public_hostname']
      end
    
      # Currently the same as the SSH password.
      def database_password
        data['users'][0]['password']
      end
      
      # Currently the same as the SSH username.
      def database_username
        data['users'][0]['username']
      end
      
      # For newly deployed applications, equal to the application name.
      def database_name
        data['engineyard']['environment']['apps'][0]['database_name']
      end
      
      # Public hostname where you should connect to the database.
      #
      # Currently the db master public hostname.
      def database_host
        data['db_host']
      end
    
      # SSH username.
      def ssh_username
        data['engineyard']['environment']['ssh_username']
      end
      
      # SSH password.
      def ssh_password
        data['engineyard']['environment']['ssh_password']
      end
    
      # The public hostnames of all the app servers.
      #
      # If you're on a solo app, it counts the solo as an app server.
      def app_servers
        data['engineyard']['environment']['instances'].select { |i| %w{ app_master app solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
    
      # The public hostnames of all the db servers.
      #
      # If you're on a solo app, it counts the solo as a db server.
      def db_servers
        data['engineyard']['environment']['instances'].select { |i| %w{ db_master db_slave solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
    
      # The public hostnames of all the utility servers.
      #
      # If you're on a solo app, it counts the solo as a utility.
      def utilities
        data['engineyard']['environment']['instances'].select { |i| %w{ util solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
    
      # The public hostname of the app_master.
      def app_master
        i = data['engineyard']['environment']['instances'].detect { |i| i['role'] == 'app_master' } ||
            data['engineyard']['environment']['instances'].detect { |i| i['role'] == 'solo' }
        i['public_hostname']
      end
    
      # The public hostname of the db_master,
      def db_master
        i = data['engineyard']['environment']['instances'].detect { |i| i['role'] == 'db_master' } ||
            data['engineyard']['environment']['instances'].detect { |i| i['role'] == 'solo' }
        i['public_hostname']
      end
    end
  end
end
