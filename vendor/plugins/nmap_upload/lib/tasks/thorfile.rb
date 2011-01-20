class DradisTasks < Thor

  class Upload < Thor
    namespace     "dradis:upload"

    desc      "nmap FILE", "upload the results of an Nmap scan"
    long_desc "Upload an Nmap scan to create nodes and notes for the hosts and " +
              "ports discovered during scanning."
    def nmap(file_path)
      require 'config/environment'

      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      unless File.exists?(file_path)
        $stderr.puts "** the file [#{file_path}] does not exist"
        exit -1
      end

      NmapUpload.import(
        :file => File.new(file_path),
        :logger => logger)

      logger.close
    end
  end
end

# TODO: this fixes the assumption of the plugin that it will be receiving an 
#       as the :file parameter Attachment
class File
  def fullpath
    File.expand_path self.path
  end
end
