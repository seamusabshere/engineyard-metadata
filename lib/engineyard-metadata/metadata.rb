module EY
  # All methods are defined on this module. For example, you're supposed to say
  #
  #   EY::Metadata.database_username
  #
  # instead of trying to call it from a particular adapter.
  module Metadata
    KEYS = %w{
      present_instance_id
      present_security_group
      present_instance_role
      present_public_hostname
      database_password
      database_username
      database_name
      database_host
      ssh_username
      ssh_password
      app_servers
      db_servers
      utilities
      app_master
      db_master
      mysql_command
      mysqldump_command
      app_slaves
      db_slaves
      solo
      environment_name
      stack_name
      repository_uri
    } unless defined?(KEYS)
    
    # This gets raised when you can't get a particular piece of metadata from the execution environment you're in.
    class CannotGetFromHere < RuntimeError
    end
    
    autoload :Insider, 'engineyard-metadata/insider'
    autoload :Outsider, 'engineyard-metadata/outsider'
    autoload :ChefDna, 'engineyard-metadata/chef_dna'
    autoload :AmazonEc2Api, 'engineyard-metadata/amazon_ec2_api'
    autoload :EngineYardCloudApi, 'engineyard-metadata/engine_yard_cloud_api'
    
    def self.reload
      if File.directory? '/var/log/engineyard'
        extend Insider
      else
        extend Outsider
      end
    end
    reload
  end
end
