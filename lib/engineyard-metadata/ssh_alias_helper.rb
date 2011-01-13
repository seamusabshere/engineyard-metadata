module EY
  class Metadata
    module SshAliasHelper
      # Aliases like 'my_env-app_master' or 'my_env-utilities-5' that go in .ssh/config
      #
      # For example:
      #   Host my_env-app_master
      #     Hostname ec2-111-111-111-111.compute-1.amazonaws.com
      #     User deploy
      #     StrictHostKeyChecking no
      def ssh_aliases
        counter = Hash.new 0
        %w{ app_master db_master db_slaves app_slaves utilities }.map do |role_group|
          send(role_group).map do |public_hostname|
            ssh_alias counter, role_group, public_hostname
          end
        end.flatten.join("\n")
      end
      
      # Used internally to generate a single ssh alias.
      def ssh_alias(counter, role_group, public_hostname)
        id = case role_group
        when 'db_slaves', 'app_slaves', 'utilities'
          "#{role_group}-#{counter[role_group] += 1}"
        else
          role_group
        end
        %{Host #{environment_name}-#{id}
  Hostname #{public_hostname}
  User #{ssh_username}
  StrictHostKeyChecking no
}        
      end
    end
  end
end
