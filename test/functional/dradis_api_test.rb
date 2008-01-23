require File.dirname(__FILE__) + '/../test_helper'
require 'dradis_controller'

class DradisController; def rescue_action(e) raise e end; end

class DradisControllerApiTest < Test::Unit::TestCase
  def setup
    @controller = DradisController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end


  def test_requestticket
    result = invoke :requestticket
    p result
  end
end
