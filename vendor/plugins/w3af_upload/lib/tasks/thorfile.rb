class DradisTasks < Thor
  class Upload < Thor
    namespace     "dradis:upload"

    desc "w3af FILE", "upload w3af results"
    def w3af(file_path)
      require 'config/environment'

      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      unless File.exists?(file_path)
        $stderr.puts "** the file [#{file_path}] does not exist"
        exit -1
      end

      W3afUpload.import(
        :file => file_path,
        :logger => logger)

      logger.close
    end

  end
end
