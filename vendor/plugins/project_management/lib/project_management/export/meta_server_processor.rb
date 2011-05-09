require 'zip/zip'

module ProjectExport
  # The MetaProcessor class does the heavy-lifting of the export 
  # functionalities that commit a project to the Meta-Server.
  class MetaServerProcessor
    private
    def self.find_project(title, logger)
      project = nil
      mode = Configuration.find_by_name('mode')
      if (mode.value == 'new')
        logger.debug{ 'Creating new project...' }
        project = Project.new( :title => title )
        project.save
        logger.debug{ 'done.' }

        # As soon as we successfully create a new project we update the local
        # configuration to ensure that we keep a reference to that project. 
        # This is to prevent multiple "NewProject_xx-yy-zz" from being created
        # if something fails during the commit process.
        mode.update_attribute(:value,  'meta-server')
        Configuration.new(:name => 'project', :value => project.attributes['id'] )
      else
        logger.debug{ 'This project was checked out from a Meta-Server. Locating... ' }
        project = Project.find( Configuration.find_by_name('project').value.to_i )
        logger.debug{ 'done.' }
      end

      return project
    end

    public

    def self.commit(params={})
      logger = params.fetch(:logger, Rails.logger)
      title = params.fetch(:title, "NewProject_#{DateTime.now.strftime('%Y-%m-%d')}")

      # Step 1: Find the right Project to commit a new Revision to
      Project.site_from_metaserver(MetaServer.new(:host => ProjectManagement::Configuration.ms_host,
                                                  :port => ProjectManagement::Configuration.ms_port,
                                                  :user => ProjectManagement::Configuration.ms_user,
                                                  :password => ProjectManagement::Configuration.ms_password))
      project = find_project(title, logger)
      logger.info{ "Project tile is: #{project.attributes['title']}" }

      # Step 2: create the project package in ./tmp/ and Base64 encode it
      logger.debug{ 'Preparing project package...' }
      filename = Rails.root.join('tmp', 'dradis-export.zip')
      Processor.full_project( :filename => filename)
      contents = Base64::encode64( File.read( filename ) )
      File.delete( filename )
      logger.debug{ 'Done' }

      # Step 3: send it over to the Meta-Server
      logger.debug{ 'Adding new revision...' }
      project.post( :add_revision, {}, {:package => contents}.to_xml(:root => 'revision') )
      logger.debug{ 'Done' }

    end
  end # /MetaServerProcessor 
end
