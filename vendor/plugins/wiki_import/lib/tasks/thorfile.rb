class DradisTasks < Thor
  class Import < Thor
    class Wiki < Thor
      namespace "dradis:import:wiki"

      desc "search QUERY", "perform a general search against a remote MediaWiki"
      def search(query)
        require 'config/environment'

        results = WikiImport::Filters::FullTextSearch.run(:query => query)

        puts "Wiki Search\n==========="
        puts "#{results.size} results"

        results.each do |record|
          puts "#{record[:title]}\n\t#{record[:description]}"
        end
      end
    end
  end
end

