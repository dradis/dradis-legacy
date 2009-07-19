require 'logger'

namespace :project do

  # This task will dump the contents of the database into an XML file that can
  # be later re-used and imported into new projects.
  desc 'Save the current database structure as a template'
  task :as_template => :environment do
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    template = ProjectExport::Processor.db_only(:logger => logger)
    f = File.new('template.xml', 'w')
    f.write template
    f.close
    logger.info{ "Template file created at:\n\t#{ File.expand_path( f.path ) }" }
    logger.close
  end

end
