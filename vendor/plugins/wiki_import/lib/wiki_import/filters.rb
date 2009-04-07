module WikiImport
  # WikiMedia import plugins defines only one filter at the moment: 
  # FullTextSearch. Any other filters added in the future will also be included 
  # in this module.
  module Filters
    
    # Perform a text search agains the WikiMedia API. See 
    # http://www.mediawiki.org/wiki/API for further reference.
    module FullTextSearch
      NAME = 'Search in all fields of the wiki'
      # TODO: is there a better way of storing the configuration?
      CONF = { 
        'host' => 'localhost',
        'port' => 80,
        'path' => '/mediawiki-1.14.0/api.php'
      }

      def self.run(params={})
        records = []
        return records
      end
    end
  end
end
