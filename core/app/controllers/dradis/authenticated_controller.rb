module Dradis
  class AuthenticatedController < BaseController
    before_filter :login_required
    # FIXME: this layout is in a different gem!
    layout 'dradis/extjs'
    # layout 'dradis/preauth'
  end
end