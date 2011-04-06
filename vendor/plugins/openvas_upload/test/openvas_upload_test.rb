require 'test/unit'

# require Rails testing framework
require File.dirname(__FILE__) + '/../../../../test/test_helper'

# require this plugin
$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../init'


class OpenvasUploadTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def test_this_plugin
    flunk
  end
end
