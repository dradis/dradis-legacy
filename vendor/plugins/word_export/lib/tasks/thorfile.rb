class DradisTasks < Thor

  class Export < Thor
    namespace     "dradis:export"

    desc      "word", "export the current repository structure as a Word report"
    method_option   :file, :type => :string, :desc => "the report file to create, or directory to create it in"
    def word
      require 'config/environment'

      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      template_path = options.file || Rails.root.join('backup')

      unless template_path =~ /\.xml\z/
        date      = DateTime.now.strftime("%Y-%m-%d")
        sequence  = Dir.glob(File.join(template_path, "dradis-report_#{date}_*.xml")).collect { |a| a.match(/_([0-9]+)\.xml\z/)[1].to_i }.max || 0
        template_path = File.join(template_path, "dradis-report_#{date}_#{sequence + 1}.xml")
      end

      doc = WordExport::Processor.generate(:logger => logger)
      doc.write(File.new(template_path, 'w'), -1, true)

      logger.info{ "Report file created at:\n\t#{template_path}" }
      logger.close
    end

  end
end
