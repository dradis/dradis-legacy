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

    # This Export menu entry will send a Zip file containing both the contents
    # of the repository and any attachments that have been uploaded into the 
    # current project
    def full_project 
      filename = Rails.root.join('tmp', 'dradis-export.zip')

      project = Processor.full_project( :filename => filename)
      send_file( filename )

      # FIXME: the zip file is left in the tmp/ directory
    end

    # This entry will create an XML file containing all the information held in
    # the repository: categories, nodes and notes.
    # This can be used, for instance, to create 'methodologies' a series of 
    # notes and nodes that you can re-use every time you have to perform a 
    # certain task (e.g. 'web application' test)
    def as_template
      template = Processor.db_only
      send_data( template , :filename => 'dradis-template.xml',  :type => :xml )
    end

    
    # Pack the current project( using Processor.full_project) and send it to 
    # the Meta-Server either as a new Project or a new Revision of an old 
    # project depending on how this project was started (see SessionController#setup).
    def metaserver_commit 
      #TODO: Should we consider restricting this to requests from 'localhost'?
      # At the end of the day this will use the settings from configuration manager
      # to submit the project. The file would contain the credentials of the
      # dradis server owner
      begin
        MetaServerProcessor.commit
        flash[:notice] = 'Project successfully sent to the Meta-Server'
      rescue Exception => e
        flash[:error] = e.message
        flash[:error] << ". Verify your connection settings"
      end
      redirect_to root_path 
    end
  end
end
