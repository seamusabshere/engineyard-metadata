require 'eat'

module EY
  class Metadata
    # An adapter that reads from Amazon EC2's metadata web service, which is only available from cloud instances.
    class AmazonEc2Api
      # The present instance's Amazon Ec2 instance id.
      def present_instance_id
        @present_instance_id ||= eat('http://169.254.169.254/latest/meta-data/instance-id')
      end

      # The present instance's Amazon Ec2 security group.
      def present_security_group
        @present_security_group ||= eat('http://169.254.169.254/latest/meta-data/security-groups')
      end
    end
  end
end
