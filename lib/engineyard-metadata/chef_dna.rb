require 'active_support'
require 'active_support/version'
%w{
  active_support/json
}.each do |active_support_3_requirement|
  require active_support_3_requirement
end if ActiveSupport::VERSION::MAJOR == 3

module EY
  class Metadata
    # An adapter that reads from /etc/chef/dna.json, which is only available on cloud instances.
    class ChefDna
      PATH = '/etc/chef/dna.json'

      include SshAliasHelper

      def dna # :nodoc:
        @dna ||= ActiveSupport::JSON.decode File.read(PATH)
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
  
      # An identifying attribute of each app server. Defaults to public_hostname.
      #
      # If you're on a solo app, it counts the solo as an app server.
      def app_servers(identifier = EY::Metadata::DEFAULT_IDENTIFIER)
        dna['engineyard']['environment']['instances'].select { |i| %w{ app_master app solo }.include? i['role'] }.map { |i| i[normalize_identifier(identifier)] }.sort
      end
   
      # An identifying attribute of each app slave. Defaults to public_hostname. 
      def app_slaves(identifier = EY::Metadata::DEFAULT_IDENTIFIER)
        dna['engineyard']['environment']['instances'].select { |i| %w{ app }.include? i['role'] }.map { |i| i[normalize_identifier(identifier)] }.sort
      end

      # An identifying attribute of each DB server. Defaults to public_hostname.
      #
      # If you're on a solo app, it counts the solo as a db server.
      def db_servers(identifier = EY::Metadata::DEFAULT_IDENTIFIER)
        dna['engineyard']['environment']['instances'].select { |i| %w{ db_master db_slave solo }.include? i['role'] }.map { |i| i[normalize_identifier(identifier)] }.sort
      end
  
      # An identifying attribute of each DB slave. Defaults to public_hostname.
      def db_slaves(identifier = EY::Metadata::DEFAULT_IDENTIFIER)
        dna['engineyard']['environment']['instances'].select { |i| %w{ db_slave }.include? i['role'] }.map { |i| i[normalize_identifier(identifier)] }.sort
      end
  
      # An identifying attribute of each utility server. Defaults to public_hostname.
      #
      # If you're on a solo app, it counts the solo as a utility.
      def utilities(identifier = EY::Metadata::DEFAULT_IDENTIFIER)
        dna['engineyard']['environment']['instances'].select { |i| %w{ util solo }.include? i['role'] }.map { |i| i[normalize_identifier(identifier)] }.sort
      end
  
      # An identifying attribute of the app_master. Defaults to public_hostname.
      #
      # If you're on a solo app, it counts the solo as the app_master.
      def app_master(identifier = EY::Metadata::DEFAULT_IDENTIFIER)
        if x = dna['engineyard']['environment']['instances'].detect { |i| i['role'] == 'app_master' }
          x[normalize_identifier(identifier)]
        else
          solo(identifier)
        end
      end
  
      # An identifying attribute of the db_master. Defaults to public_hostname.
      #
      # If you're on a solo app, it counts the solo as the db_master.
      def db_master(identifier = EY::Metadata::DEFAULT_IDENTIFIER)
        if x = dna['engineyard']['environment']['instances'].detect { |i| i['role'] == 'db_master' }
          x[normalize_identifier(identifier)]
        else
          solo(identifier)
        end
      end
    
      # An identifying attribute of the solo. Defaults to public_hostname.
      def solo(identifier = EY::Metadata::DEFAULT_IDENTIFIER)
        if x = dna['engineyard']['environment']['instances'].detect { |i| i['role'] == 'solo' }
          x[normalize_identifier(identifier)]
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

      def normalize_identifier(identifier)
        (identifier == 'amazon_id') ? 'id' : identifier
      end
    end
  end
end
