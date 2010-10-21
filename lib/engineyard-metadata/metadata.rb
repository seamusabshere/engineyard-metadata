module EY
  # All methods are defined on this module. For example, you're supposed to say
  #
  #   EY::Metadata.database_username
  #
  # instead of trying to call it from a particular adapter.
  module Metadata
    KEYS = %w{
      app_master
      app_name
      app_servers
      app_slaves
      current_path
      database_host
      database_name
      database_password
      database_username
      db_master
      db_servers
      db_slaves
      environment_name
      environment_names
      mysql_command
      mysqldump_command
      present_instance_id
      present_instance_role
      present_public_hostname
      present_security_group
      repository_uri
      shared_path
      solo
      ssh_aliases
      ssh_password
      ssh_username
      stack_name
      utilities
    } unless defined?(KEYS)
    
    # This gets raised when you can't get a particular piece of metadata from the execution environment you're in.
    class CannotGetFromHere < RuntimeError
    end
    
    autoload :SshAliasHelper, 'engineyard-metadata/ssh_alias_helper'

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
