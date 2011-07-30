class DradisTasks < Thor
  class Upload < Thor
    namespace "dradis:upload"

    desc 'surecheck FILE', 'Upload a SureCheck .sc file'
    def surecheck(file_path)
      require 'config/environment'

      # standard logging facility
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG
 
      unless File.exists?(file_path)
        $stderr.puts "** the file [#{file_path}] does not exist"
        exit -1
      end
 
      # invoke the plugin
      SurecheckUpload.import( 
        :file => file_path,
        :logger => logger
      )

      logger.close
    end
  end
end
