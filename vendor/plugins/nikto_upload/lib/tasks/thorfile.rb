class DradisTasks < Thor
  class Upload < Thor
    namespace     "dradis:upload"

    desc      "nikto FILE", "upload nikto results"
    def nikto(file_path)
      require 'config/environment'

      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      unless File.exists?(file_path)
        $stderr.puts "** the file [#{file_path}] does not exist"
        exit -1
      end

      NiktoUpload.import(
        :file => File.new(file_path),
        :logger => logger)

      logger.close
    end

  end
end

# FIXME: this fixes the assumption of the plugin that it will be receiving an
#       as the :file parameter Attachment
class File
  def fullpath
    File.expand_path self.path
  end
end
