class DradisTasks < Thor
  class Import < Thor
    class VulnDB < Thor
      namespace "dradis:import:vulndb"

      desc "private QUERY", "search a remote VulnDB instance with a general query"
      def private(query)
        require 'config/environment'

        results = VulndbImport::Filters::VulnDB.run(:query => query)

        puts "VulnDB Search\n==============="
        puts "#{results.size} results\n"

        results.each do |record|
          puts "#{record[:title]}\n\t#{record[:description]}"
          puts "*" * 80
        end
      end

      desc "hq QUERY", "search your VulnDB HQ (http://vulndbhq.com) repository"
      def hq(query)
        require 'config/environment'

        results = VulndbImport::Filters::VulnDB_HQ.run(:query => query)

        puts "VulnDB HQ Search\n==============="
        puts "#{results.size} results\n"

        results.each do |record|
          puts "#{record[:title]}\n\t#{record[:description]}"
          puts "*" * 80
        end
      end

    end
  end
end
