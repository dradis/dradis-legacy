# This controller presents the user with the 'First Time' wizard that would
# walk them through the features of the framework.
#
# It would usually not be invoked directly but through the
# ApplicationController#show_first_time_wizard before_filter
class WizardController < ApplicationController
  layout 'wizard'

  def index
  end

  def check_version
    'http://dradisframework.org/latest.txt'
  end
end
