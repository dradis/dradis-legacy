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

    private
    def self.validate_API_key()
      if ( Configuration.api_key == BAD_API_KEY )
        raise "Invalid API key detected. " +
          "Please register for an OSVDB API key at: \n\t" +
          'http://osvdb.org/account/signup'
          
      end
    end

    # Format the Vulnerability information to follow dradis fields format
    #   #[field]#
    #   content
    #   #[field]#
    #   content
    #   ...
    def self.from_OSVDB_to_dradis(result_set)
      result_set.collect do |record|
        {
          :title => record['title'],
          :description => record.collect do |key, value| "#[#{key}]#\n#{value}\n" end.join
        }
      end
    end

    public 
    
    # GeneralSearch Filter: Internally uses the "Find Vulns by custom query" 
    # API to get vulnerabilities by a custom query. Returns a maximum of 30 
    # vulns per request.
    # Sample Query for "XSS"  http://osvdb.org/api/vulns_by_custom_search/<your_API_key>/?request=XSS&order=osvdb_id
    module GeneralSearch
      NAME = "General Search"

      
      def self.run(params={})
        # Ensure that we have a valid OSVDB API key
        begin
          Filters::validate_API_key()
        rescue Exception => e
          return [ 
            { :title => 'Error in OSVDB API key', :description => e.message} 
          ]
        end

        logger = params.fetch( :logger, Rails.logger )        
        query = CGI::escape( params.fetch( :query, '') )

        logger.info{ "Running a general search in the OSVDB with the query: #{query}" }
        
        results = OSVDB::GeneralSearch(:API_key => Configuration.api_key, :query => query)
        return Filters::from_OSVDB_to_dradis( results )
      end
    end
 
    # OSVDIDLookup: run a search looking for a specific OSVDID
    #
    # Sample Query for osvdb_id 1234:  http://osvdb.org/api/find_by_osvdb/<your_API_key>/1234
    module OSVDBIDLookup
      NAME = 'OSVDB ID Lookup' 

      def self.run(params={})
        # Ensure that we have a valid OSVDB API key
        begin
          Filters::validate_API_key()
        rescue Exception => e
          return [ 
            { :title => 'Error in OSVDB API key', :description => e.message} 
          ]
        end

        logger = params.fetch( :logger, Rails.logger )        
        query = CGI::escape( params.fetch( :query, '1234') )

        logger.info{ "Running a OSVDB ID lookup on: #{query}" }
        results = OSVDB::IDLookup( :API_key => Configuration.api_key, :osvdb_id => query )

        return Filters::from_OSVDB_to_dradis( results)
      end
    end
    
    
  end
end
