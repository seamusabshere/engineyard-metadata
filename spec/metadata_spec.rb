require 'spec_helper'

describe EY do
  it 'has a FakeFS dna.json' do
    File.exist?('/etc/chef/dna.json').should == true
  end
end

describe EY::Metadata do
  it 'gets the present instance ID' do
    EY::Metadata.present_instance_id.should == PRESENT_INSTANCE_ID
  end
  
  it 'gets the present instance role (as a string)' do
    EY::Metadata.present_instance_role.should == 'app_master'
  end
  
  it 'gets the present public hostname' do
    EY::Metadata.present_public_hostname.should == PRESENT_PUBLIC_HOSTNAME
  end
  
  it 'gets the present security group' do
    EY::Metadata.present_security_group.should == PRESENT_SECURITY_GROUP
  end
  
  it 'gets the database password' do
    EY::Metadata.database_password.should == 'USERS-0-PASSWORD'
  end
  
  it 'gets the database username' do
    EY::Metadata.database_username.should == 'USERS-0-USERNAME'
  end

  it 'gets the database name' do
    EY::Metadata.database_name.should == 'APPS-0-DATABASE_NAME'
  end

  it 'gets the database host' do
    EY::Metadata.database_host.should == 'external_db_master.compute-1.amazonaws.com'
  end
  
  it 'gets the ssh username' do
    EY::Metadata.ssh_username.should == 'SSH-USERNAME'
  end
  
  it 'gets the ssh password' do
    EY::Metadata.ssh_password.should == 'SSH-PASSWORD'
  end
  
  it 'gets the app server hostnames' do
    EY::Metadata.app_servers.should == [ 'app_1.compute-1.amazonaws.com' , 'app_master.compute-1.amazonaws.com' ]
  end
  
  it 'gets the db server hostnames' do
    EY::Metadata.db_servers.should == [ 'db_master.compute-1.amazonaws.com', 'db_slave_1.compute-1.amazonaws.com' ]
  end
  
  it 'gets the utilities hostnames' do
    EY::Metadata.utilities.should == [ 'util_1.compute-1.amazonaws.com' ]
  end

  it 'gets the app master hostname' do
    EY::Metadata.app_master.should == 'app_master.compute-1.amazonaws.com'
  end
  
  it 'gets the db master hostname' do
    EY::Metadata.db_master.should == 'db_master.compute-1.amazonaws.com'
  end
  
  it 'gets the mysql command' do
    EY::Metadata.mysql_command.should == '/usr/bin/mysql -h external_db_master.compute-1.amazonaws.com -u USERS-0-USERNAME -pUSERS-0-PASSWORD APPS-0-DATABASE_NAME'
  end
  
  it 'gets the mysqldump command' do
    EY::Metadata.mysqldump_command.should == '/usr/bin/mysqldump -h external_db_master.compute-1.amazonaws.com -u USERS-0-USERNAME -pUSERS-0-PASSWORD APPS-0-DATABASE_NAME'
  end
  
  it 'gets the db slave hostnames' do
    EY::Metadata.db_slaves.should == [ 'db_slave_1.compute-1.amazonaws.com' ]
  end

  it 'gets the app slave hostnames' do
    EY::Metadata.app_slaves.should == [ 'app_1.compute-1.amazonaws.com' ]
  end
  
  it 'gets the solo hostname' do
    EY::Metadata.solo.should == nil
  end
  
  it 'gets the environment name' do
    EY::Metadata.environment_name.should == 'APP-NAME_production'
  end
end
