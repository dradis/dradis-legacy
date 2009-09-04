module <%= class_name %>  
  
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
 
    # Your filters go here. Feel free to rename
    module <%= class_name %>Filter
    NAME = 'Dummy Filter: Reads a value from the config file'
      CONF_FILE = File.join(RAILS_ROOT, 'config', '<%= file_name %>.yml')
      CONF = YAML::load( File.read CONF_FILE ) 
      
      def self.run(params={})
        records = []
        # do stuff. For example
        records << { :title => 'This filter uses the config file', :description => "The value of 'some_property' is: #{CONF['some_property']}." }
        records << { :title => 'Filter information', :description => "Config file is located in #{CONF_FILE}" }
        return records
      end
    end
    
  end  
end
