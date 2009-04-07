require 'test/unit'

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../init'

# This class contains test cases for the WikiMedia import plugin
class WikiImportTest < Test::Unit::TestCase

  # At some point in the import process we need to translate from 
  # wiki-formatted text into our standard format for notes (see
  # Note#fields).
  def test_wiki_to_dradis_fields
    flunk
  end
end
