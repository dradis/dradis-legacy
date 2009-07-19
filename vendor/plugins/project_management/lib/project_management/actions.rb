# ProjectExport module of the plugin defines two actions:
#
#  = as_template: downloads a copy of the internal database for storage, it 
#    dumps the contents of the DB into an XML file.
#  = full_project: exports the database (see as_template) and attachments for 
#    each node. These are presented to the user as 'dradis_YYYY-MM-dd.zip'.
#
# This plugin theoretically supports any database backend supported by Active
# Record. It is most efficient when utilising an SQLite database.
module ProjectExport
  module Actions
    def full_project 
    end
    def as_template
      template = Processor.db_only
      send_data( template , :filename => 'dradis-template.xml',  :type => :xml )
    end
  end
end
