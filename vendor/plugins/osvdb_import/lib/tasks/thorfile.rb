class DradisTasks < Thor
  class Import < Thor
    class OSVDB < Thor
      namespace     "dradis:import:osvdb"

      desc      "search QUERY", "search the OSVDB with a general query"
      def search(query)
        require 'config/environment'

        results = OSVDBImport::Filters::GeneralSearch.run(:query => query)

        puts "OSVDB Search\n============"
        puts "#{results.size} results"

        results.each do |record|
          puts "#{record[:title]}\n\t#{record[:description]}"
        end
      end

      desc      "lookup ID", "search the OSVDB for a specific ID"
      def lookup(id)
        require 'config/environment'

        results = OSVDBImport::Filters::OSVDBIDLookup.run(:query => id)

        puts "OSVDB Search\n============"
        puts "#{results.size} results"

        results.each do |record|
          puts "#{record[:title]}\n\t#{record[:description]}"
        end
      end

    end
  end
end
