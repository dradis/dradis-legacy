module Plugins
  # The Plugins::Export module will be filled in with functionality by the 
  # different export plugins installed in this dradis instance. The 
  # ExportController will expose this functionality through an standarised
  # interface.
  module Export
  end
end

# The ExportContoller will be the centralised point from which all the 
# functionality exposed by plugins is made available to the user.
class ExportController < ApplicationController
  include Plugins::Export
  before_filter :prepare_params, :except => [:list]

  private
  def prepare_params
  end
end
