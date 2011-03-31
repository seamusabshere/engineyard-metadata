require 'engineyard-metadata/version'
require 'engineyard-metadata/metadata'

module EY
  def self.metadata
    @metadata ||= if ::File.directory?('/var/log/engineyard')
      Metadata::Insider.new
    else
      Metadata::Outsider.new
    end
  end
  
  def self.reload_metadata
    @metadata = nil
  end
end
