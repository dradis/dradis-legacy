class DradisTasks < Thor
  class Upload < Thor
    namespace "dradis:upload"

   desc  "zap FILE", "upload ZAP results"
   long_desc "This will appear if the user runs 'thor help dradis:upload:zap'"
   def zap(file_path)
     require 'config/environment'

     logger = Logger.new(STDOUT)
     logger.level = Logger::DEBUG

     unless File.exists?(file_path)
       $stderr.puts "** the file [#{file_path}] does not exist"
       exit -1
     end

     ZapUpload.import(
       :file => file_path,
       :logger => logger)

     logger.close
   end

  end
end
