class DradisTasks < Thor
  class Upload < Thor
    namespace "dradis:upload"

    desc "retina FILE", "upload Retina results"
    def retina(file_path)
      require 'config/environment'

      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      unless File.exists?(file_path)
        $stderr.puts "** the file [#{file_path}] does not exist"
        exit -1
      end

      RetinaUpload.import(
        :file => file_path,
        :logger => logger)

      logger.close
    end
  end
end
