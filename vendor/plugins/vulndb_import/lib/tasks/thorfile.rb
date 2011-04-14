class DradisTasks < Thor
  class Import < Thor
    class VulnDB < Thor
      namespace "dradis:import:vulndb"

      desc "search QUERY", "search a remote Vuln::DB with a general query"
      def search(query)
        require 'config/environment'

        results = VulndbImport::Filters::TextSearch.run(:query => query)

        puts "Vuln::DB Search\n==============="
        puts "#{results.size} results\n"

        results.each do |record|
          puts "#{record[:title]}\n\t#{record[:description]}"
          puts "*" * 80
        end
      end
    end
  end
end
