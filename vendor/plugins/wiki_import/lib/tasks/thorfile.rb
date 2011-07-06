class DradisTasks < Thor
  class Import < Thor
    class Wiki < Thor
      namespace "dradis:import:wiki"

      desc "search14 QUERY", "perform a general search against a remote MediaWiki v1.14"
      def search14(query)
        require 'config/environment'

        results = WikiImport::Filters::FullTextSearch14.run(:query => query)

        puts "Wiki Search\n==========="
        puts "#{results.size} results"

        results.each do |record|
          puts "#{record[:title]}\n\t#{record[:description]}"
        end
      end

      desc "search15 QUERY", "perform a general search against a remote MediaWiki v1.15"
      def search15(query)
        require 'config/environment'

        results = WikiImport::Filters::FullTextSearch15.run(:query => query)

        puts "Wiki Search\n==========="
        puts "#{results.size} results"

        results.each do |record|
          puts "#{record[:title]}\n\t#{record[:description]}"
        end
      end
      
    end
  end
end

