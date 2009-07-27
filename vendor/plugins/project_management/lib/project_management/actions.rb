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
      filename = File.join(RAILS_ROOT, 'tmp', 'dradis-export.zip')

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

      # Step 1: Find the right Project to commit a new Revision to
      # FIXME: Hard coded MetaServer config? You can do better than this!
      Project.site_from_metaserver( MetaServer.new( 
                                      'host' => '192.168.49.128',
                                      'port' => '3000',
                                      'user' => 'etd',
                                      'password' => 'etd001') 
                                  )

      project = nil
      mode = Configuration.find_by_name('mode').value
      if (mode == 'new')
        project = Project.new
        project.attributes[:title] = "NewProject_#{DateTime.now.strftime('%Y-%m-%d')}"
        project.save
      else
        project = Project.find( Configuration.find_by_name('project').value.to_i )
      end

      # Step 2: create the project package in ./tmp/
      filename = File.join(RAILS_ROOT, 'tmp', 'dradis-export.zip')
      Processor.full_project( :filename => filename)
      contents = Base64::encode64( File.read( filename ) )
      File.delete( filename )

      # Step 3: send it over to the Meta-Server
      project.post( :add_revision, {}, {:package => contents}.to_xml(:root => 'revision') )

      redirect_to :back
    end
  end
end
