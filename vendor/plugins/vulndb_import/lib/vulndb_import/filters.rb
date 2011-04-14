module VulndbImport
  module Filters
    module TextSearch
      NAME = 'Search for a specific value in all the fields of the DB'

      def self.run(params={}) 
        records = []       
        begin              
          records = Page.find(:all, :params => {:q => params[:query]}).collect do |page| 
            { 
              :title => page.name, 
              :description => page.content 
            }
          end
        rescue Exception => e
          records << { 
                      :title => 'Error fetching records',
                      :description => e.message
                     }
        end
        return records
      end
    end
  end
end