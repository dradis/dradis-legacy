class DradisTasks < Thor
  class Export < Thor
    namespace     "dradis:export"

    desc 'html', 'export the current repository structure as an HTML document'
    method_option :file, :type => :string, :desc => 'the report file to create'
    def html
      require 'config/environment'

      output_file = options.file || Rails.root.join('report.html')

      STDOUT.sync = true
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      doc = HTMLExport::Processor.generate(:logger => logger)
      File.open(output_file, 'w') do |f|
        f << doc
      end

      logger.info{ "Report file created at:\n\t#{output_file}" }
      logger.close
    end
  end
end


