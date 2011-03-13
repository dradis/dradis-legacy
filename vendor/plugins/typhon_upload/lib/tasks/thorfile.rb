class DradisTasks < Thor
  class Upload < Thor
    namespace     "dradis:upload"

    desc      "typhon FILE", "upload typhon results"
    def typhon(file_path)
      require 'config/environment'

      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      unless File.exists?(file_path)
        $stderr.puts "** the file [#{file_path}] does not exist"
        exit -1
      end

      TyphonUpload.import(
        :file => filename,
        :logger => logger)

      logger.close
    end

  end
end
