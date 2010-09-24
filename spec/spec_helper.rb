require 'rubygems'
require 'spec'
require 'ruby-debug'
require 'active_support/json/encoding'

PRESENT_PUBLIC_HOSTNAME = 'app_master.compute-1.amazonaws.com'
PRESENT_SECURITY_GROUP = 'ey-data1_production-1-2-3'
PRESENT_INSTANCE_ID = 'i-deadbeef'

require 'fakeweb'
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

dna_json = File.read File.join(File.dirname(__FILE__), 'support', 'dna.json')
require 'fakefs'
FileUtils.mkdir_p '/etc/chef'
File.open '/etc/chef/dna.json', 'w' do |f|
  f.write dna_json
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'engineyard-metadata'

# Spec::Runner.configure do |config|
#   config.before(:all) do
#     
#   end
# end
