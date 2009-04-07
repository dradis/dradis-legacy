require 'test/unit'

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

Disable directory listings if possible."
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

Disable directory listings if possible."
EON

  # At some point in the import process we need to translate from 
  # wiki-formatted text into our standard format for notes (see
  # Note#fields).
  def test_wiki_to_dradis_fields
    assert_equal( DRADIS_NOTE, WikiImport::fields_from_wikitext(WIKI_PAGE) ) 
  end

  # Connect to a remote wiki, search for a specific string and parse the output
  # into the format expected by the framework.
  def test_pull_from_wiki
    expected = [ {:title => 'Directory Listings', :description => DRADIS_NOTE} ]

    assert_equals( expected, WikiImport::Filters::FullTextSearch.run() )
  end
end
