# VulndbImport

require 'vulndb_import/meta'

module VulndbImport
  module Filters
    module TextSearch
      NAME = 'Search for a specific value in all the fields of the DB'
      CONF_FILE = Rails.root.join('config', 'vulndb_import.yml')
      CONF = YAML::load( File.read CONF_FILE )

      def self.run(params={}) 
        records = [] 
        begin
          filter_params = {
            :format => :ext_json,
            :fields => '["id","vulnerability[title]","vulnerability[body]"]',
            :query => params[:query]
          } 
          Net::HTTP.start(CONF['host'], CONF['port']) do |http|
            res = http.get("#{CONF['path']}?#{filter_params.to_query}") 
            records = ActiveSupport::JSON::decode(res.body)['vulnerabilities'].collect do |record|
              { 
                :title => record['vulnerability']['title'], 
                :description => record['vulnerability']['body'] 
              }
            end
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

module Plugins
  module Import
    include VulndbImport
  end
end
