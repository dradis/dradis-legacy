module Dradis
  class BaseController < ApplicationController
    layout 'dradis/application'
    include Dradis::Concerns::CurrentUser
  end
end