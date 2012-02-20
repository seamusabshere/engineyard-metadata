require 'rubygems'
require 'bundler'
Bundler.setup
require 'rspec'
require 'active_support/json/encoding'
require 'webmock/rspec'
require 'fakefs/safe'
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'engineyard-metadata'

FAKE_SECURITY_GROUP = 'ey-cm1_production_blue-1294775925-1371-55979'
FAKE_INSTANCE_ID = 'i-ff17d493'
FAKE_CLOUD_TOKEN = 'justareallygreatsecret'

def pretend_we_are_on_a_developer_machine
  WebMock.enable!
  WebMock.stub_request(:get, "https://cloud.engineyard.com/api/v2/environments").to_return(
    :status => 200,
    :body => File.read(File.join(File.dirname(__FILE__), 'support', 'engine_yard_cloud_api_response.json')))
    
  dot_git_config = File.read File.join(File.dirname(__FILE__), 'support', 'dot.git.config')
  FakeFS.activate!
  git_config_path = File.join Dir.pwd, '.git', 'config'
  FileUtils.mkdir_p File.dirname(git_config_path)
  File.open(git_config_path, 'w') do |f|
    f.write dot_git_config
  end
end

def pretend_we_are_on_an_engineyard_appcloud_ec2_instance
  WebMock.enable!
  # fake call to amazon ec2 api to get present security group
  WebMock.stub_request(:get, "http://169.254.169.254/latest/meta-data/security-groups").to_return(
    :status => 200,
    :body => FAKE_SECURITY_GROUP
  )

  # fake call to amazon ec2 api to get present instance id
  WebMock.stub_request(:get, "http://169.254.169.254/latest/meta-data/instance-id").to_return(
    :status => 200,
    :body => FAKE_INSTANCE_ID
  )

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
  WebMock.reset!
end
