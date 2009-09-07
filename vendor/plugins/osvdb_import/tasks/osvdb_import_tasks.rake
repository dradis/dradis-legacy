namespace :import do

  namespace :osvdb do

    desc "Run a general search against the OSVDB"
    task :general, :query, :needs => :environment do |task, args|
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      results = OSVDBImport::Filters::GeneralSearch.run( 
                                                  :query => args[:query],
                                                  :logger => logger )

      logger.info{ "Total number of records: #{results.size}\n" }
      results.each do |record|
        puts "#{record[:title]}\n\t#{record[:description]}"
      end
    end


    desc "Run a OSVDB ID Lookup"
    task :id_lookup, :osvdbid, :needs => :environment do |task, args|
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      results = OSVDBImport::Filters::OSVDBIDLookup.run( 
                                                  :query => args[:osvdbid],
                                                  :logger => logger )

      logger.info{ "Total number of records: #{results.size}\n" }
      results.each do |record|
        puts "#{record[:title]}\n\t#{record[:description]}"
      end

    end


  end
end
