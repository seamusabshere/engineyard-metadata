module EY
  module Metadata
    # This gets pulled in when you're running directly on a cloud instance.
    module Insider
      DELEGATED_TO_AMAZON_EC2_API = %w{
        present_instance_id
        present_security_group
      }
    
      DELEGATED_TO_CHEF_DNA = KEYS - DELEGATED_TO_AMAZON_EC2_API

      DELEGATED_TO_AMAZON_EC2_API.each do |name|
        define_method name do
          amazon_ec2_api.send name
        end
      end

      DELEGATED_TO_CHEF_DNA.each do |name|
        define_method name do
          chef_dna.send name
        end
      end
      
      # An adapter that reads from the EngineYard AppCloud /etc/chef/dna.json file.
      def chef_dna
        @chef_dna ||= ChefDna.new
      end

      # An adapter that reads from Amazon's EC2 API.
      def amazon_ec2_api
        @amazon_ec2_api ||= AmazonEc2Api.new
      end
    end
  end
end
