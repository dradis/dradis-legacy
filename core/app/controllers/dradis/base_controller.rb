module Dradis
  class BaseController < ApplicationController
    layout 'dradis/preauth'
    include Dradis::Concerns::CurrentUser
  end
end