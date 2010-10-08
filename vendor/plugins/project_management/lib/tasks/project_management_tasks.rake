require 'logger'

# TODO: this fixes the assumption of the plugin that it will be receiving an 
#       as the :file parameter Attachment
class File
  def fullpath
    File.expand_path self.path
  end
end

namespace :export do

  # ------------------------------------------------------------ project:export
  #
  # Export tasks, including as a template, zip file or to the meta-server 
  namespace :project do

    # This task will dump the contents of the database into an XML file that can
    # be later re-used and imported into new projects.
    desc 'Save the current database structure as a template'
    task :template => :environment do
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG
      template = ProjectExport::Processor.db_only(:logger => logger)
      f = File.new('dradis-template.xml', 'w')
      f.write template
      f.close
      logger.info{ "Template file created at:\n\t#{ File.expand_path( f.path ) }" }
      logger.close
    end

    # Save the current project into a Zip file. The archive will contain an XML
    # file with the contents of the database (categories, nodes and notes) and
    # all the attachments that have been uploaded into the system.
    desc 'Save the project information into a Zip file.'
    task :zip => :environment do
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG
      ProjectExport::Processor.full_project(:logger => logger, :filename => 'dradis-export.zip')
      logger.info{ "Template file created at:\n\t#{ File.expand_path( 'dradis-export.zip' ) }" }
      logger.close
    end

    desc 'Commit project to the Meta-Server'
    task :metaserver => :environment do
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      mode = Configuration.find_by_name('mode').value
      title = "NewProject_#{DateTime.now.strftime('%Y-%m-%d')}"

      # If this project was never checked out from the Meta-Server, give the
      # user a chance to choose a project title
      if (mode == 'new')
        puts "This project was not checked out from a Meta-Server. Please provide a project name:"
        response = STDIN.gets("\n").chomp
        if !response.empty?
          title = response
        end  
      end

      begin
        ProjectExport::MetaServerProcessor.commit(:logger => logger, :title => title)
      rescue Exception => e
        logger.error{ 'There was an error sending the project to the Meta-Server:' }
        logger.error{ e.message }
        logger.error{ "The current settings from [#{ProjectManagement::CONF_FILE}]:" }
        logger.error{ ProjectManagement::CONF['meta-server'] }
      end

      logger.close
    end

  end # /project namespace
end # /export namespace

namespace :upload do
  # ------------------------------------------------------------ project:import
  #
  # Upload tasks, load a template or a project package into this instance
  namespace :project do

    # This task will load into the current database the contents of the template
    # file passed as the first argument
    desc 'Upload the contents of a template file into the current project'
    task :template, :file, :needs => :environment do |t, args|

      filename = args[:file] 
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      fail "Please provide a file: rake 'upload:project:template[<file>]'" if filename.nil?
      fail "File [#{filename}] does not exist" unless File.exists?(filename)

      ProjectTemplateUpload::import(:logger => logger, :file => File.new(filename) )
      logger.close
    end

    # The reverse operation to the project:export:zip task. From a zipped 
    # project package extract the contents of the archive and populate the 
    # dradis DB and attachments with them.
    desc 'Upload the contents of a project package'
    task :zip, :file, :needs => :environment do |t, args|
      
      filename = args[:file]
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      fail "Please provide a file: rake 'upload:project:zip[<file>]'" if filename.nil?
      fail "File [#{filename}] does not exist" unless File.exists?(filename)

      ProjectPackageUpload::import(:logger => logger, :file => File.new(filename) )
      logger.close
    end

  end # /project namespace

end # /upload namespace
