module Dradis
  class AuthenticatedController < BaseController
    before_filter :login_required
    layout 'dradis/application'
  end
end