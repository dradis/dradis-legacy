# WikiImport

require 'wiki_import/filters'
require 'wiki_import/meta'

# The WikiImport plugin leverages WikiMedia API to extract information from a 
# wiki (i.e. the 'Reporting Wiki') and import it into a dradis note.
module WikiImport
  class Configuration < Core::Configurator
    configure :namespace => 'wikiimport'
    setting :host, :default => 'localhost'
    setting :port, :default => 80
    setting :path, :default => '/mediawiki/api.php'
    setting :fields, :default => 'Title,Impact,Probability,Description,Recommendation'
  end

  # WikiMedia has its own formatting, and there are some tweaks we need to do 
  # to addapt it to standard dradis convention.
  def self.fields_from_wikitext(wikitext)
    dradis_fields = wikitext
    fields = Configuration.fields.split(',')
    fields.each do |f|
      dradis_fields.sub!( /=+#{f}=+/, "#[#{f}]#" )
    end
    return dradis_fields
  end
end

module Plugins
  module Import
    include WikiImport
  end
end
