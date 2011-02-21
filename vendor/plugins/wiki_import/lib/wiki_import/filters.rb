module WikiImport
  # WikiMedia import plugins defines only one filter at the moment: 
  # FullTextSearch. Any other filters added in the future will also be included 
  # in this module.
  module Filters
    
    # Perform a text search against the WikiMedia API. See 
    # http://www.mediawiki.org/wiki/API for further reference.
    module FullTextSearch
      NAME = 'Search in all fields of the wiki'

      def self.run(params={})
        records = []
        begin
          # Parameters required by MediaWiki API
          filter_params = {
            :action => 'query',
            :prop => 'revisions',
            :generator => 'search',
            :gsrsearch => CGI::escape(params[:query]), # user query
            :rvprop => 'content',
            :format => 'xml'
          }
          record = nil
          fields = nil

          # Get the results over HTTP
          Net::HTTP.start(Configuration.host, Configuration.port) do |http|
            res = http.get("#{Configuration.path}?#{filter_params.to_query}") 
            xmlres = Hash.from_xml( res.body )
            unless xmlres['api'].nil?
              record = xmlres['api']['query']['pages']['page']['revisions']['rev']
            end
          end

          unless record.nil?
            records << {
              :title => record.scan(/=Title=\n(.*?)=/m).first.first.strip,
              :description => WikiImport::fields_from_wikitext(record)
            }
          end
          
        rescue Exception => e
          records << { 
                      :title => 'Error fetching records',
                      :description => e.message + "\n\n\n" +
                                    "This error can be cause by a configuration " +
                                    "issue (i.e. dradis not finding the MediaWiki instance). " +
                                    "Please review the configuration settings located at:\n\n" +
                                    "./server/vendor/plugins/wiki_import/lib/wiki_import/filters.rb"
                     }
        end

        return records
      end
    end
  end
end
