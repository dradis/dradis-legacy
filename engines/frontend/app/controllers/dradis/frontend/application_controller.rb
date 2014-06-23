# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

module Dradis
  module Frontend
    class ApplicationController < ActionController::Base
      helper :all # include all helpers, all the time

      # Prevent CSRF attacks by raising an exception.
      # For APIs, you may want to use :null_session instead.
      protect_from_forgery

      # Include the Authentication concern. Used by AuthenticatedController
      include Dradis::Frontend::Authentication
    end
  end
end