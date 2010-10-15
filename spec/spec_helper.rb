require 'rubygems'
require 'rspec'
require 'active_support/json/encoding'
require 'fakeweb'
require 'fakefs/safe'

PRESENT_PUBLIC_HOSTNAME = 'app_master.compute-1.amazonaws.com'
PRESENT_SECURITY_GROUP = 'ey-data1_production-1-2-3'
PRESENT_INSTANCE_ID = 'i-deadbeef'
FAKE_CLOUD_TOKEN = 'FAKE_EY_CLOUD_TOKEN'
FAKE_ENVIRONMENT_NAME = 'FAKE_ENVIRONMENT_NAME'

def pretend_we_are_on_a_developer_machine
  FakeWeb.allow_net_connect = false
  FakeWeb.register_uri  :get,
                        "https://cloud.engineyard.com/api/v2/environments",
                        :status => ["200", "OK"],
                        :body => File.read(File.join(File.dirname(__FILE__), 'support', 'engine_yard_cloud_api_response.json'))
  dot_git_config = File.read File.join(File.dirname(__FILE__), 'support', 'dot.git.config')
  FakeFS.activate!
  git_config_path = File.join Dir.pwd, '.git', 'config'
  FileUtils.mkdir_p File.dirname(git_config_path)
  File.open(git_config_path, 'w') do |f|
    f.write dot_git_config
  end
end

def pretend_we_are_on_an_engineyard_appcloud_ec2_instance
  FakeWeb.allow_net_connect = false
  # fake call to amazon ec2 api to get present security group
  FakeWeb.register_uri  :get,
                        "http://169.254.169.254/latest/meta-data/security-groups",
                        :status => ["200", "OK"],
                        :body => PRESENT_SECURITY_GROUP

  # fake call to amazon ec2 api to get present instance id
  FakeWeb.register_uri  :get,
                        "http://169.254.169.254/latest/meta-data/instance-id",
                        :status => ["200", "OK"],
                        :body => PRESENT_INSTANCE_ID

  # first read a file from the real file system...
  dna_json = File.read File.join(File.dirname(__FILE__), 'support', 'dna.json')
  # ... then turn on the fakefs
  FakeFS.activate!
  FileUtils.mkdir_p '/var/log/engineyard'
  FileUtils.mkdir_p '/etc/chef'
  File.open '/etc/chef/dna.json', 'w' do |f|
    f.write dna_json
  end
end

def stop_pretending
  # http://lukeredpath.co.uk/blog/using-fakefs-with-cucumber-features.html
  FakeFS::FileSystem.clear
  FakeFS.deactivate!
  FakeWeb.clean_registry
end

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'engineyard-metadata'))