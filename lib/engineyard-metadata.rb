module EY
  autoload :Metadata, 'engineyard-metadata/metadata'
  def self.metadata
    Metadata.instance
  end
end
