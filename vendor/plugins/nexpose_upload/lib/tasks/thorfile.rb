class DradisTasks < Thor
  class Upload < Thor
    namespace     "dradis:upload"

    desc "nexpose FILE", "upload NeXpose results"
    def nexpose(file_path)
      require 'config/environment'

      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      unless File.exists?(file_path)
        $stderr.puts "** the file [#{file_path}] does not exist"
        exit -1
      end

      NexposeUpload.import(
        :file => file_path,
        :logger => logger)

      logger.close
    end

  end
end
