require 'spec_helper'

describe SessionsController do
  fixtures :configurations

  describe "as guest" do

    it "should prompt for a new password if the password is 'improvable_dradis'"
    it "should ask the user to log in if they have no session"

    it "should display a friendly message if the password configuration is not set" do
      Configuration.find_by_name('password').destroy if Configuration.exists?(:name => 'password')
      
      get :new

      response.code.should eq('200')
      response.should render_template("sessions/not_ready")
    end

  end

  describe "as user" do
  end
end
