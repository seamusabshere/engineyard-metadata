module EY
  module Metadata
    DELEGATED_TO_AMAZON_EC2_API = %w{
      present_instance_id
      present_security_group
    }
        
    DELEGATED_TO_CHEF_DNA = %w{
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
    }
    
    DELEGATED_TO_AMAZON_EC2_API.each do |name|
      EY::Metadata.send :define_method, name do
        amazon_ec2_api.send name
      end
    end
    
    DELEGATED_TO_CHEF_DNA.each do |name|
      EY::Metadata.send :define_method, name do
        chef_dna.send name
      end
    end

    extend self
    
    autoload :ChefDna, 'engineyard-metadata/chef_dna'
    autoload :AmazonEc2Api, 'engineyard-metadata/amazon_ec2_api'
    
    # An adapter that reads from the EngineYard AppCloud /etc/chef/dna.json file.
    def chef_dna
      @chef_dna ||= EY::Metadata::ChefDna.new
    end
    
    # An adapter that reads from Amazon's EC2 API.
    def amazon_ec2_api
      @amazon_ec2_api ||= EY::Metadata::AmazonEc2Api.new
    end
  end
end
