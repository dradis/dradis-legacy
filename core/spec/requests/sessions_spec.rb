require 'spec_helper'

describe "Sessions" do
  fixtures :configurations

  describe "as guest" do
    pending "should prompt for a new password if the password is 'improvable_dradis'"
    pending "should ask the user to log in if they have no session"

    it "should display a friendly message if the password configuration is not set" do
      Dradis::Configuration.find_by_name('password').destroy if Dradis::Configuration.exists?(:name => 'password')
      
      get login_path

      response.code.should eq('200')
      response.should render_template("sessions/not_ready")
    end

  end
end
