module Dradis
  class AuthenticatedController < BaseController
    before_filter :login_required
  end
end