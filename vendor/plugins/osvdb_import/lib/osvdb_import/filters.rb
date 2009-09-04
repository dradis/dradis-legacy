module OSVDBImport  
  
  # complete this with the different filters that your import plugin defines
  module Filters

    # Dummy filter that can be deleted
    module SearchInArray
      NAME = "Dummy filter: Search for a word in a static array (['red', 'blue', 'green']"
      CONF = {
        :list => ['red', 'blue', 'green']
      }
      def self.run(params={})
        records = []
        if (CONF[:list].include?(params[:query]))
          records << { :title => 'Search found!', :description => 'The search term was found in the list' }
        else
          records << { :title => 'Not found', :description => 'The search term was not in the list' }
        end
        records << {:title => 'Filter information', :description => "This filter is implemented in #{__FILE__}"}
        return records
      end
    end
 
    # Your filters go here

  end
end
