module WikiImport
  # WikiMedia import plugins defines only one filter at the moment: 
  # FullTextSearch. Any other filters added in the future will also be included 
  # in this module.
  module Filters
    
    # Perform a text search agains the WikiMedia API. See 
    # http://www.mediawiki.org/wiki/API for further reference.
    module FullTextSearch
      NAME = 'Search in all fields of the wiki'
      CONF = { 
      }
    end
  end
end
