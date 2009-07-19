# ProjectExport module of the plugin defines two actions:
#
#  = as_template: downloads a copy of the internal database for storage, it 
#    dumps the contents of the DB into an XML file.
#  = full_project: exports the database (see db_only) and attachments for each
#    node. These are presented to the user as 'dradis.zip'.
#
# This plugin theoretically supports any database backend supported by Active
# Record. It is most efficient when utilising an SQLite database.
module ProjectExport
  module Actions
    def full_project 
    end
    def as_template

      template = REXML::Document.new
      template << REXML::Element.new('template')

      template.root << REXML::Document.new(
                        Category.find(:all).to_xml(:except => [:id, :created_at, :updated_at])
                       ).root

      template.root << REXML::Element.new('nodes')
      Node.find(:all, :conditions => {:parent_id => nil} ).each do |branch|
        # FIXME: How do we associate notes with categories if the id changes? use the name
        template.root[1] << REXML::Document.new( branch.full_xml ).root
      end

      send_data template, :filename => 'template.xml',  :type => :xml
    end
  end
end
