require 'logger'

namespace :export do
  # This task generates a Word report from a set of dradis Notes. This notes 
  # have to be asigned to a specific category and have to have the format 
  # specified in Processor#generate.
  # 
  # The output report will be stored in +./report.xml+
  desc "Export the contents of the dradis repository to a Word document"
  task :word => :environment do
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    doc = WordExport::Processor.generate(:logger => logger)
    doc.write(File.new('report.xml','w'), -1, true)
    logger.close
  end
end

