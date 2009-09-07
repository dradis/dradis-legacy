# Open Source Vulnerability Database (OSVDB) Import Plugin
#
# "OSVDB is an independent and open source database created by and for the
# community. Our goal is to provide accurate, detailed, current, and unbiased 
# technical information." - http://osvdb.org/
#
# This plugin provides search filters to query the OSVDB from within dradis. 
# The plugin makes use of the API provided by OSVDB (http://osvdb.org/api).
#
# You will need to register in their site to get an API key: 
# http://osvdb.org/account/signup

module OSVDBImport  
  
  # complete this with the different filters that your import plugin defines
  module Filters
    BAD_API_KEY = '<your_API_key>'
    CONF_FILE = File.join(RAILS_ROOT, 'config', 'osvdb_import.yml')
    CONF = YAML::load( File.read CONF_FILE )

    # GeneralSearch Filter: Internally uses the "Find Vulns by custom query" 
    # API to get vulnerabilities by a custom query. Returns a maximum of 30 
    # vulns per request.
    # Sample Query for "XSS"  http://osvdb.org/api/vulns_by_custom_search/<your_API_key>/?request=XSS&order=osvdb_id
    module GeneralSearch
      NAME = "General Search"

      
      def self.run(params={})
        p CONF

        logger = params.fetch( :logger, RAILS_DEFAULT_LOGGER )        
        query = params.fetch( :query, '')
        url = "http://osvdb.org/api/vulns_by_custom_search/<your_API_key>/?request=#{CGI::escape(query)}&order=osvdb_id"

        logger.info{ "Running a general search in the OSVDB with the query: #{query}" }
        logger.debug{ "URL is: #{url}" }
        
      end
    end
 
    # OSVDIDLookup: run a search looking for a specific OSVDID
    #
    # Sample Query for osvdb_id 1234:  http://osvdb.org/api/find_by_osvdb/<your_API_key>/1234
    module OSVDBIDLookup
      NAME = 'OSVDB ID Lookup' 

      def self.run(params={})

      end
    end
    
    
  end
end
