require 'active_support'
require 'active_support/version'
%w{
  active_support/json
}.each do |active_support_3_requirement|
  require active_support_3_requirement
end if ActiveSupport::VERSION::MAJOR == 3
require 'eat'

module EY
  class Metadata
    # An adapter that reads from /etc/chef/dna.json, which is only available on cloud instances.
    class ChefDna
      PATH = '/etc/chef/dna.json'

      include SshAliasHelper

      def dna # :nodoc:
        @dna ||= ActiveSupport::JSON.decode eat(PATH)
      end
      
      def application # :nodoc:
        dna['engineyard']['environment']['apps'].detect { |a| a['name'] == EY.metadata.app_name }
      end
  
      # The present instance's role
      def present_instance_role
        dna['instance_role']
      end
    
      # The present instance's public hostname.
      def present_public_hostname
        dna['engineyard']['environment']['instances'].detect { |i| i['id'] == EY.metadata.present_instance_id }['public_hostname']
      end
  
      # Currently the same as the SSH password.
      def database_password
        dna['users'][0]['password']
      end
    
      # Currently the same as the SSH username.
      def database_username
        dna['users'][0]['username']
      end
    
      # For newly deployed applications, equal to the application name.
      def database_name
        application['database_name']
      end
      
      # The git repository that you told EngineYard to use for this application.
      def repository_uri
        application['repository_name']
      end

      # Public hostname where you should connect to the database.
      #
      # Currently the db master public hostname.
      def database_host
        db_master
      end
  
      # SSH username.
      def ssh_username
        dna['engineyard']['environment']['ssh_username']
      end
    
      # SSH password.
      def ssh_password
        dna['engineyard']['environment']['ssh_password']
      end
  
      # The public hostnames of all the app servers.
      #
      # If you're on a solo app, it counts the solo as an app server.
      def app_servers
        dna['engineyard']['environment']['instances'].select { |i| %w{ app_master app solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
    
      # The public hostnames of all the app slaves.
      def app_slaves
        dna['engineyard']['environment']['instances'].select { |i| %w{ app }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
  
      # The public hostnames of all the db servers.
      #
      # If you're on a solo app, it counts the solo as a db server.
      def db_servers
        dna['engineyard']['environment']['instances'].select { |i| %w{ db_master db_slave solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
  
      # The public hostnames of all the db slaves.
      def db_slaves
        dna['engineyard']['environment']['instances'].select { |i| %w{ db_slave }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
  
      # The public hostnames of all the utility servers.
      #
      # If you're on a solo app, it counts the solo as a utility.
      def utilities
        dna['engineyard']['environment']['instances'].select { |i| %w{ util solo }.include? i['role'] }.map { |i| i['public_hostname'] }.sort
      end
  
      # The public hostname of the app_master.
      #
      # If you're on a solo app, it counts the solo as the app_master.
      def app_master
        if x = dna['engineyard']['environment']['instances'].detect { |i| i['role'] == 'app_master' }
          x['public_hostname']
        else
          solo
        end
      end
  
      # The public hostname of the db_master.
      #
      # If you're on a solo app, it counts the solo as the app_master.
      def db_master
        if x = dna['engineyard']['environment']['instances'].detect { |i| i['role'] == 'db_master' }
          x['public_hostname']
        else
          solo
        end
      end
    
      # The public hostname of the solo.
      def solo
        if x = dna['engineyard']['environment']['instances'].detect { |i| i['role'] == 'solo' }
          x['public_hostname']
        end
      end

      # The shell command for mysql, including username, password, hostname and database
      def mysql_command
        "/usr/bin/mysql -h #{database_host} -u #{database_username} -p#{database_password} #{database_name}"
      end

      # The shell command for mysql, including username, password, hostname and database
      def mysqldump_command
        "/usr/bin/mysqldump -h #{database_host} -u #{database_username} -p#{database_password} #{database_name}"
      end
    
      # The name of the EngineYard AppCloud environment.
      def environment_name
        dna['environment']['name']
      end
      
      # The stack in use, like nginx_passenger.
      def stack_name
        dna['engineyard']['environment']['stack_name']
      end
    end
  end
end
