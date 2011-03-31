module EY
  class Metadata
    # This gets pulled in when you're running directly on a cloud instance.
    class Insider < Metadata
      # You can't get the list of environment names while you're on the instances themselves.
      def environment_names
        raise CannotGetFromHere
      end
      
      # An adapter that reads from the EngineYard AppCloud /etc/chef/dna.json file.
      def chef_dna
        @chef_dna ||= ChefDna.new
      end

      # An adapter that reads from Amazon's EC2 API.
      def amazon_ec2_api
        @amazon_ec2_api ||= AmazonEc2Api.new
      end
      
      def app_name
        return @app_name if @app_name.is_a? String
        if ENV['EY_APP_NAME']
          @app_name = ENV['EY_APP_NAME']
        elsif Dir.pwd =~ %r{/data/([^/]+)/current} or Dir.pwd =~ %r{/data/([^/]+)/releases}
          @app_name = $1
        end
        raise RuntimeError, "[engineyard-metadata gem] Please set EY.metadata.app_name= or set ENV['EY_APP_NAME']" unless @app_name.to_s.strip.length > 0
        @app_name
      end
      
      DELEGATED_TO_AMAZON_EC2_API = %w{
        present_instance_id
        present_security_group
      }

      DELEGATED_TO_CHEF_DNA = METHODS - instance_methods.map { |m| m.to_s } - DELEGATED_TO_AMAZON_EC2_API

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
    end
  end
end
