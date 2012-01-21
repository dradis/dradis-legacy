class DradisTasks < Thor
  class Upload < Thor
    namespace "dradis:upload"

    desc  "nikto FILE", "upload nikto results"
    long_desc "This will appear if the user runs 'thor help dradis:upload:nikto'"
    def nikto(file_path)
      require 'config/environment'

      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      unless File.exists?(file_path)
        $stderr.puts "** the file [#{file_path}] does not exist"
        exit -1
      end

      NiktoUpload.import(
        :file => file_path,
        :logger => logger)

      logger.close
    end

  end
end
