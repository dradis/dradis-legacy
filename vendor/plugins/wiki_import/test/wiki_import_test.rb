require 'test/unit'

# require Rails testing framework
require File.dirname(__FILE__) + '/../../../../test/test_helper'

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../init'

# We need mocha (http://mocha.rubyforge.org/) to stub out Net::HTTP in the test
# otherwise people testing this library would need to install a MediaWiki on 
# their own!
$:.unshift File.dirname(__FILE__) + '/vendor/mocha-0.9.5/lib'
require 'mocha'

# This class contains test cases for the WikiMedia import plugin
class WikiImportTest < Test::Unit::TestCase
  # Reference strings for assertions
  WIKI_PAGE=<<EOW#nodoc
=Title=
Directory Listings

=Impact=
Low

=Probability=
Low

=Description=
Some directories on the server were configured with directory listing enabled. 

This may leak information about the website by revealing files that it uses 
without requiring the application context in which they are accessed. 

=Recommendation=

Disable directory listings if possible.
EOW
  DRADIS_NOTE=<<EON#nodoc
#[Title]#
Directory Listings

#[Impact]#
Low

#[Probability]#
Low

#[Description]#
Some directories on the server were configured with directory listing enabled. 

This may leak information about the website by revealing files that it uses 
without requiring the application context in which they are accessed. 

#[Recommendation]#

Disable directory listings if possible.
EON

  WIKI_API_RESPONSE=<<EOX
<?xml version="1.0"?><api><query><pages><page pageid="2" ns="0" title="Directory Listings"><revisions><rev>=Title=
Directory Listings

=Impact=
Low

=Probability=
Low

=Description=
Some directories on the server were configured with directory listing enabled. 

This may leak information about the website by revealing files that it uses 
without requiring the application context in which they are accessed. 

=Recommendation=

Disable directory listings if possible.
</rev></revisions></page></pages></query></api>
EOX


  # At some point in the import process we need to translate from 
  # wiki-formatted text into our standard format for notes (see
  # Note#fields).
  def test_wiki_to_dradis_fields
    assert_equal( DRADIS_NOTE, WikiImport::fields_from_wikitext(WIKI_PAGE) ) 
  end

  # Connect to a remote wiki, search for a specific string and parse the output
  # into the format expected by the framework.
  def test_pull_from_wiki
    params = { :query => 'directory' }

    # mocha stubs for Net::HTTP. WIKI_API_RESPONSE contains a fictional 
    # response by a MediaWiki server. This will be parsed by the filter to 
    # produce a dradis-formated note
    response = mock
    response.expects(:body).returns(WIKI_API_RESPONSE)
    http = mock
    http.expects(:get).returns(response)
    Net::HTTP.stubs(:start).yields( http )

    expected = [ {:title => 'Directory Listings', :description => DRADIS_NOTE} ]
    assert_equal( expected, WikiImport::Filters::FullTextSearch.run(params) )
  end
end
