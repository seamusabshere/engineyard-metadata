require 'spec_helper'

shared_examples_for "it does in all execution environments" do
  it 'get the database username' do
    EY::Metadata.database_username.should == 'FAKE_SSH_USERNAME'
  end

  it 'get the database name' do
    EY::Metadata.database_name.should == 'FAKE_APP_NAME'
  end

  it 'get the database host' do
    EY::Metadata.database_host.should == 'FAKE_DB_MASTER_PUBLIC_HOSTNAME'
  end

  it 'get the ssh username' do
    EY::Metadata.ssh_username.should == 'FAKE_SSH_USERNAME'
  end
  
  it 'get the app server hostnames' do
    EY::Metadata.app_servers.should == [ 'app_1.compute-1.amazonaws.com' , 'app_master.compute-1.amazonaws.com' ]
  end

  it 'get the db server hostnames' do
    EY::Metadata.db_servers.should == [ 'FAKE_DB_MASTER_PUBLIC_HOSTNAME', 'db_slave_1.compute-1.amazonaws.com' ]
  end

  it 'get the utilities hostnames' do
    EY::Metadata.utilities.should == [ 'FAKE_UTIL_1_PUBLIC_HOSTNAME' ]
  end

  it 'get the app master hostname' do
    EY::Metadata.app_master.should == 'app_master.compute-1.amazonaws.com'
  end

  it 'get the db master hostname' do
    EY::Metadata.db_master.should == 'FAKE_DB_MASTER_PUBLIC_HOSTNAME'
  end

  it 'get the db slave hostnames' do
    EY::Metadata.db_slaves.should == [ 'db_slave_1.compute-1.amazonaws.com' ]
  end

  it 'get the app slave hostnames' do
    EY::Metadata.app_slaves.should == [ 'app_1.compute-1.amazonaws.com' ]
  end

  it 'get the solo hostname' do
    EY::Metadata.solo.should == nil
  end

  it 'get the environment name' do
    EY::Metadata.environment_name.should == 'FAKE_ENVIRONMENT_NAME'
  end
  
  it 'get the stack name' do
    EY::Metadata.stack_name.should == 'FAKE_STACK_NAME'
  end
  
  it 'get the repository URI' do
    EY::Metadata.repository_uri.should == 'FAKE_REPOSITORY_URI'
  end
end

shared_examples_for "it's executing outside the cloud" do
  it 'not get the present instance ID' do
    lambda {
      EY::Metadata.present_instance_id
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end

  it 'not get the present instance role (as a string)' do
    lambda {
      EY::Metadata.present_instance_role
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
  
  it 'not get the present public hostname' do
    lambda {
      EY::Metadata.present_public_hostname
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
  
  it 'not get the present security group' do
    lambda {
      EY::Metadata.present_security_group
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end

  it 'not get the database password' do
    lambda {
      EY::Metadata.database_password
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end

  it 'not get the ssh password' do
    lambda {
      EY::Metadata.ssh_password
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
  
  it 'not get the mysql command' do
    lambda {
      EY::Metadata.mysql_command
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
  
  it 'not get the mysqldump command' do
    lambda {
      EY::Metadata.mysqldump_command
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
  
  it 'get the raw EngineYard Cloud API data' do
    EY::Metadata.engine_yard_cloud_api.data.should be_a(Hash)
  end
end

shared_examples_for "it's executing inside the cloud" do
  it 'get the present instance ID' do
    EY::Metadata.present_instance_id.should == PRESENT_INSTANCE_ID
  end

  it 'get the present instance role (as a string)' do
    EY::Metadata.present_instance_role.should == 'app_master'
  end

  it 'get the present public hostname' do
    EY::Metadata.present_public_hostname.should == PRESENT_PUBLIC_HOSTNAME
  end

  it 'get the present security group' do
    EY::Metadata.present_security_group.should == PRESENT_SECURITY_GROUP
  end
  
  it 'get the database password' do
    EY::Metadata.database_password.should == 'USERS-0-PASSWORD'
  end
  
  it 'get the ssh password' do
    EY::Metadata.ssh_password.should == 'SSH-PASSWORD'
  end
  
  it 'get the mysql command' do
    EY::Metadata.mysql_command.should =~ %r{mysql -h FAKE_DB_MASTER_PUBLIC_HOSTNAME -u FAKE_SSH_USERNAME -pUSERS-0-PASSWORD FAKE_APP_NAME}
  end

  it 'get the mysqldump command' do
    EY::Metadata.mysqldump_command.should =~ %r{mysqldump -h FAKE_DB_MASTER_PUBLIC_HOSTNAME -u FAKE_SSH_USERNAME -pUSERS-0-PASSWORD FAKE_APP_NAME}
  end
end

describe 'EY::Metadata' do
  after do
    stop_pretending
  end
  
  describe "being executed on an EngineYard AppCloud (i.e. Amazon EC2) instance" do
    before do
      pretend_we_are_on_an_engineyard_appcloud_ec2_instance
      EY::Metadata.reload
    end
    it_should_behave_like "it does in all execution environments"
    it_should_behave_like "it's executing inside the cloud"
  end

  describe "being executed from a developer/administrator's local machine" do
    before do
      pretend_we_are_on_a_developer_machine
      EY::Metadata.reload
      EY::Metadata.clear
      ENV.delete 'EY_CLOUD_TOKEN'
      ENV.delete 'EY_ENVIRONMENT_NAME'
    end
    describe "controlled with environment variables" do
      before do
        ENV['EY_CLOUD_TOKEN'] = FAKE_CLOUD_TOKEN + 'aaa'
        ENV['EY_ENVIRONMENT_NAME'] = FAKE_ENVIRONMENT_NAME
        EY::Metadata.ey_cloud_token.should == FAKE_CLOUD_TOKEN + 'aaa' # sanity check
      end
      it_should_behave_like "it does in all execution environments"
      it_should_behave_like "it's executing outside the cloud"
    end
    describe "controlled with attr writers" do
      before do
        EY::Metadata.ey_cloud_token = FAKE_CLOUD_TOKEN + 'bbb'
        EY::Metadata.environment_name = FAKE_ENVIRONMENT_NAME
        EY::Metadata.ey_cloud_token.should == FAKE_CLOUD_TOKEN + 'bbb' # sanity check
      end
      it_should_behave_like "it does in all execution environments"
      it_should_behave_like "it's executing outside the cloud"
    end
    describe "depending on .eyrc" do
      before do
        File.open(EY::Metadata.eyrc_path, 'w') { |f| f.write({'api_token' => FAKE_CLOUD_TOKEN + 'ccc'}.to_yaml) }
        EY::Metadata.environment_name = FAKE_ENVIRONMENT_NAME
        EY::Metadata.ey_cloud_token.should == FAKE_CLOUD_TOKEN + 'ccc' # sanity check
      end
      it_should_behave_like "it does in all execution environments"
      it_should_behave_like "it's executing outside the cloud"
    end
  end
end
