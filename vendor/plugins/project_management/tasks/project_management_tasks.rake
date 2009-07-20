require 'logger'

namespace :project do

  # This task will dump the contents of the database into an XML file that can
  # be later re-used and imported into new projects.
  desc 'Save the current database structure as a template'
  task :as_template => :environment do
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    template = ProjectExport::Processor.db_only(:logger => logger)
    f = File.new('dradis-template.xml', 'w')
    f.write template
    f.close
    logger.info{ "Template file created at:\n\t#{ File.expand_path( f.path ) }" }
    logger.close
  end

  # This task will load into the current database the contents of the template
  # file passed as the first argument
  desc 'Import the contents of a template file into the current project'
  task :import_template => :environment do
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    ProjectTemplateUpload::import(:logger => logger, :file => Attachment.new(:filename =>'dradis-template.xml', :node_id => 1))
    logger.close
  end

  # Save the current project into a Zip file. The archive will contain an XML
  # file with the contents of the database (categories, nodes and notes) and
  # all the attachments that have been uploaded into the system.
  desc 'Save the project information into a Zip file.'
  task :as_zip => :environment do
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    ProjectExport::Processor.full_project(:logger => logger, :filename => 'dradis-export.zip')
    logger.info{ "Template file created at:\n\t#{ File.expand_path( 'dradis-export.zip' ) }" }
    logger.close
  end
end
