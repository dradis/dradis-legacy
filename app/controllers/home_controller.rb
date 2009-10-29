class HomeController < ApplicationController
  layout 'postauth'
  before_filter :login_required
  
  def index
  end
  
end
