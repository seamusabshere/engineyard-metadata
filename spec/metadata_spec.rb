require 'spec_helper'

shared_examples_for "it does in all execution environments" do
  it 'by getting the database username' do
    EY.metadata.database_username.should == 'deploy'
  end

  it 'by getting the database name' do
    EY.metadata.database_name.should == 'cm1_certified_blue'
  end

  it 'by getting the database host' do
    EY.metadata.database_host.should == 'ec2-67-202-19-255.compute-1.amazonaws.com'
  end

  it 'by getting the ssh username' do
    EY.metadata.ssh_username.should == 'deploy'
  end
  
  it 'by getting the app server hostnames' do
    EY.metadata.app_servers.should == ["ec2-174-129-212-130.compute-1.amazonaws.com"]
  end

  it 'by getting the db server hostnames' do
    EY.metadata.db_servers.should == ["ec2-67-202-19-255.compute-1.amazonaws.com"]
  end

  it 'by getting the utilities hostnames' do
    EY.metadata.utilities.should == []
  end

  it 'by getting the app master hostname' do
    EY.metadata.app_master.should == 'ec2-174-129-212-130.compute-1.amazonaws.com'
  end

  it 'by getting the db master hostname' do
    EY.metadata.db_master.should == 'ec2-67-202-19-255.compute-1.amazonaws.com'
  end

  it 'by getting the db slave hostnames' do
    EY.metadata.db_slaves.should == []
  end

  it 'by getting the app slave hostnames' do
    EY.metadata.app_slaves.should == []
  end

  it 'by getting the solo hostname' do
    EY.metadata.solo.should == nil
  end

  it 'by getting the environment name' do
    EY.metadata.environment_name.should == 'cm1_production_blue'
  end
  
  it 'by getting the stack name' do
    EY.metadata.stack_name.should == 'nginx_unicorn'
  end
  
  it 'by getting the repository URI' do
    EY.metadata.repository_uri.should == 'git@github.com:brighterplanet/cm1.git'
  end
  
  it 'by getting the app name' do
    EY.metadata.app_name.should == 'cm1_certified_blue'
  end
  
  it 'by getting the current path' do
    EY.metadata.current_path.should == '/data/cm1_certified_blue/current'
  end
  
  it 'by getting the shared path' do
    EY.metadata.shared_path.should == '/data/cm1_certified_blue/shared'
  end
  
  it 'by getting helpful ssh aliases' do
    EY.metadata.ssh_aliases.should =~ /Host cm1_production_blue-app_master\n  Hostname ec2-174-129-212-130.compute-1.amazonaws.com/
  end
end

shared_examples_for "it's executing outside the cloud" do
  it 'by getting the list of all environment names' do
    EY.metadata.environment_names.should == ["app1_production", "wlpf1_production", "data1_production", "cm1_production_red", "cm1_production_blue"]
  end

  it 'by refusing to get the present instance ID' do
    lambda {
      EY.metadata.present_instance_id
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end

  it 'by refusing to get the present instance role (as a string)' do
    lambda {
      EY.metadata.present_instance_role
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
  
  it 'by refusing to get the present public hostname' do
    lambda {
      EY.metadata.present_public_hostname
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
  
  it 'by refusing to get the present security group' do
    lambda {
      EY.metadata.present_security_group
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end

  it 'by refusing to get the database password' do
    lambda {
      EY.metadata.database_password
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end

  it 'by refusing to get the ssh password' do
    lambda {
      EY.metadata.ssh_password
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
  
  it 'by refusing to get the mysql command' do
    lambda {
      EY.metadata.mysql_command
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
  
  it 'by refusing to get the mysqldump command' do
    lambda {
      EY.metadata.mysqldump_command
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
end

shared_examples_for "it's executing inside the cloud" do
  it 'by refusing to get the list of all environment names' do
    lambda {
      EY.metadata.environment_names
    }.should raise_error(EY::Metadata::CannotGetFromHere)
  end
  
  it 'by getting the present instance ID' do
    EY.metadata.present_instance_id.should == FAKE_INSTANCE_ID
  end

  it 'by getting the present instance role (as a string)' do
    EY.metadata.present_instance_role.should == 'app_master'
  end

  it 'by getting the present public hostname' do
    EY.metadata.present_public_hostname.should == 'ec2-174-129-212-130.compute-1.amazonaws.com'
  end

  it 'by getting the present security group' do
    EY.metadata.present_security_group.should == FAKE_SECURITY_GROUP
  end
  
  it 'by getting the database password' do
    EY.metadata.database_password.should == 'USERS-0-PASSWORD'
  end
  
  it 'by getting the ssh password' do
    EY.metadata.ssh_password.should == 'USERS-0-PASSWORD'
  end
  
  it 'by getting the mysql command' do
    EY.metadata.mysql_command.should =~ %r{mysql -h ec2-67-202-19-255.compute-1.amazonaws.com -u deploy -pUSERS-0-PASSWORD cm1_certified_blue}
  end

  it 'by getting the mysqldump command' do
    EY.metadata.mysqldump_command.should =~ %r{mysqldump -h ec2-67-202-19-255.compute-1.amazonaws.com -u deploy -pUSERS-0-PASSWORD cm1_certified_blue}
  end
end

describe 'EY.metadata' do
  after do
    stop_pretending
  end
  
  describe "being executed on an EngineYard AppCloud (i.e. Amazon EC2) instance" do
    before do
      pretend_we_are_on_an_engineyard_appcloud_ec2_instance
      EY.reload_metadata
      EY.metadata.app_name = 'cm1_certified_blue'
    end
    it_should_behave_like "it does in all execution environments"
    it_should_behave_like "it's executing inside the cloud"
  end

  describe "being executed from a developer/administrator's local machine" do
    before do
      pretend_we_are_on_a_developer_machine
      EY.reload_metadata
      ENV.delete 'EY_CLOUD_TOKEN'
      ENV.delete 'EY_ENVIRONMENT_NAME'
      ENV.delete 'EY_APP_NAME'
      EY.metadata.app_name = 'cm1_certified_blue'
    end
    describe "controlled with environment variables" do
      before do
        ENV['EY_CLOUD_TOKEN'] = FAKE_CLOUD_TOKEN + 'aaa'
        ENV['EY_APP_NAME'] = 'cm1_certified_blue'
        EY.metadata.ey_cloud_token.should == FAKE_CLOUD_TOKEN + 'aaa' # sanity check
      end
      it_should_behave_like "it does in all execution environments"
      it_should_behave_like "it's executing outside the cloud"
    end
    describe "controlled with attr writers" do
      before do
        EY.metadata.ey_cloud_token = FAKE_CLOUD_TOKEN + 'bbb'
        EY.metadata.app_name = 'cm1_certified_blue'
        EY.metadata.ey_cloud_token.should == FAKE_CLOUD_TOKEN + 'bbb' # sanity check
      end
      it_should_behave_like "it does in all execution environments"
      it_should_behave_like "it's executing outside the cloud"
    end
    describe "depending on .eyrc" do
      before do
        File.open(EY.metadata.eyrc_path, 'w') { |f| f.write({'api_token' => FAKE_CLOUD_TOKEN + 'ccc'}.to_yaml) }
        EY.metadata.environment_name = 'cm1_production_blue'
        EY.metadata.ey_cloud_token.should == FAKE_CLOUD_TOKEN + 'ccc' # sanity check
      end
      it_should_behave_like "it does in all execution environments"
      it_should_behave_like "it's executing outside the cloud"
    end
  end
end
