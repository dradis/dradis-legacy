module VulndbImport
  module Filters
    module VulnDB
      NAME = 'Search for a specific value in all the fields of VulnDB'

      def self.run(params={}) 
        records = []       

        # In case the user has changed the vulndb:rest_url setting
        Page.format = :xml
        Page.site = Configuration.rest_url

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
    module VulnDB_HQ
      NAME = 'Search online in your VulnDB HQ repository'

      def self.run(params={})
        records = []

        # In case the user has changed the vulndb:rest_url setting
        Page.site = Configuration.hq_rest_url
        Page.element_name = 'private_page'

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
