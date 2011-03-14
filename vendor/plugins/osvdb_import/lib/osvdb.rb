require 'net/http'

unless defined?(Rails)
  require 'rexml/document'
  require 'rubygems'
  gem 'activesupport'
  require 'active_support'
end

# Open Source Vulnerability Database (OSVDB) Ruby module
#
# This module provides helper methods to query the OSVDB.
#
# You will need to register in their site to get an API key: 
# http://osvdb.org/account/signup
module OSVDB

  private
  # Internal method that runs the query, parses the XML and returns the 
  # resulting array of vulnerabilities
  def self.run_search(params={})
    url = params[:url]

    records = []
    begin
      Net::HTTP.start(url.host, url.port) do |http|
        res = http.get( url.request_uri )
        result_set = Hash.from_xml( res.body )

        if result_set.key?('vulnerabilities')
          # more than one
          records = result_set['vulnerabilities']
        else
          if result_set.key?('vulnerability')
            records << result_set['vulnerability']
          else
            raise 'Query returned an empty result set'
          end
        end

      end
    rescue Exception => e
      records << {
                  'title' => 'Error fetching records',
                  'description' => e.message
                 }
    end

    return records

  end

  public
  # Find by Microsoft Security Bulletin ID. Required parameters:
  #   +:API_key+ Your OSVDB API key
  #   +:mssb_id+ Microsoft Security Buletin ID (e.g. MS05-006)
  def self.ByMSSB(params={})
    key = params[:API_key]
    mssb = params[:mssb_id]

    url = URI.parse( "http://osvdb.org/api/find_by_mssb/#{key}/#{mssb}" )

    return run_search(:url => url)
  end

  # Run a custom search against the online OSVDB repository. Required
  # parameters:
  #   +:API_key+ Your OSVDB API key
  #   +:query+ The general query string you want to use in your request 
  def self.GeneralSearch(params={})
    key = params[:API_key]
    query = params[:query]

    # Sample Query for "XSS"  http://osvdb.org/api/vulns_by_custom_search/<your_API_key>/?request=XSS&order=osvdb_id
    url = URI.parse( "http://osvdb.org/api/vulns_by_custom_search/#{key}/?request=#{query}&order=osvdb_id" )

    return run_search(:url => url)
  end

  # Run a OSVDB ID Lookup query against the online OSVDB repository. Required 
  # parameters:
  #   +:API_key+ Your OSVDB API key
  #   +:osvdb_id+ The OSVDB ID you are looking for
  def self.IDLookup(params={})
    key = params[:API_key]
    osvdbid = params[:osvdb_id]

    url = URI.parse( "http://osvdb.org/api/find_by_osvdb/#{key}/#{osvdbid}" )

    return run_search(:url => url) 
  end
end


