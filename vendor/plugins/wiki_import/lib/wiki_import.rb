# WikiImport

require 'wiki_import/filters'
require 'wiki_import/meta'

# The WikiImport plugin leverages WikiMedia API to extract information from a 
# wiki (i.e. the 'Reporting Wiki') and import it into a dradis note.
module WikiImport
  CONF_FILE = File.join(RAILS_ROOT, 'config', 'wiki_import.yml')
  CONF = YAML::load( File.read CONF_FILE )


  # WikiMedia has its own formatting, and there are some tweaks we need to do 
  # to addapt it to standard dradis convention.
  def self.fields_from_wikitext(wikitext)
    dradis_fields = wikitext
    fields = CONF['fields']
    fields.each do |f|
      dradis_fields.sub!( /=#{f}=/, "#[#{f}]#" )
    end
    return dradis_fields
  end
end

module Plugins
  module Import
    include WikiImport
  end
end
