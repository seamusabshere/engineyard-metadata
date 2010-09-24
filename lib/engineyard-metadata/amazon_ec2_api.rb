require 'open-uri'

module EY
  module Metadata
    class AmazonEc2Api
      # The present instance's Amazon Ec2 instance id.
      def present_instance_id
        open("http://169.254.169.254/latest/meta-data/instance-id").gets
      end

      # The present instance's Amazon Ec2 security group.
      def present_security_group
        open('http://169.254.169.254/latest/meta-data/security-groups').gets
      end
    end
  end
end
