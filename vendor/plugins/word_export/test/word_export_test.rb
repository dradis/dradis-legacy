require 'test/unit'

# require Rails testing framework
require File.dirname(__FILE__) + '/../../../../test/test_helper'

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../init'

class WordExportTest < Test::Unit::TestCase

  # Simple test to check the paragraph formation facility. A simple text with no
  # run or paragraph attributes
  def test_simpletext_noprops
    expected = '<w:p><w:r><w:t>test text</w:t></w:r></w:p>'
    assert_equal(expected, WordExport::Processor.word_paragraph_for('test text', {}).to_s)
  end
end
