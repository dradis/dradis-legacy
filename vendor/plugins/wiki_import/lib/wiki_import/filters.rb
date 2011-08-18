module WikiImport
  # WikiMedia import plugins defines only one filter at the moment: 
  # FullTextSearch. Any other filters added in the future will also be included 
  # in this module.
  module Filters
    
    # Perform a text search against the WikiMedia API v1.14. See 
    # http://www.mediawiki.org/wiki/API for further reference.
    module FullTextSearch14
      NAME = 'Search in all fields of the wiki v1.14'

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

     # Perform a text search against the WikiMedia API v1.15. See
     # http://www.mediawiki.org/wiki/API for further reference.
     module FullTextSearch15
       NAME = 'Search in all fields of the wiki v1.15'

       # Searching returns links to content. Download the articles.
       def self.get_content(records)
         records.each do |r|
           filter_params = {
             :action => 'query',
             :prop => 'revisions',
             :rvprop => 'content',
             :titles => r['title'], # title found in user query
             :format => 'xml'
           }

           # Get the results over HTTP
           Net::HTTP.start(Configuration.host, Configuration.port) do |http|
             res = http.get("#{Configuration.path}?#{filter_params.to_query}")
             xmlres = Hash.from_xml( res.body )
             unless xmlres['api'].nil?
               r['description'] = xmlres['api']['query']['pages']['page']['revisions']['rev']
             end
           end
         end
       end

       def self.run(params={})
         records = []
         begin
           # Parameters required by MediaWiki API
           filter_params = {
             :action => 'query',
             :prop => 'revisions',
             :list => 'search',
             :srwhat => 'text',
             :srsearch => CGI::escape(params[:query]), # user query
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
               record = xmlres['api']['query']['search']['p']
               record = self.get_content(record)
             end
           end

           unless record.nil?
             record.each do |r|
               records << {
                 :title => r['title'].strip,
                 :description => WikiImport::fields_from_wikitext(r['description'])
               }
             end
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
