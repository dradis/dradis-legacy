module Dradis
  class BaseController < ApplicationController
    include Dradis::Concerns::CurrentUser
  end
end