namespace :import do

  namespace :osvdb do

    desc "Run a general search against the OSVDB"
    task :general, :query, :needs => :environment do |task, args|
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      p args
      p OSVDBImport::Filters::GeneralSearch.run( 
                                                  :query => args[:query],
                                                  :logger => logger )
    end

  end
end
