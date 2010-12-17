module ControllerMacros

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    # This method goes through the controller actions and creates a new spec to
    # ensure they all require authentication.
    def it_should_require_authentication
      it "should require authentication for :show" do
        get :show, :id => 1
        response.should redirect_to(login_path)
        flash[:notice].should == 'Access denied.'
      end
    end
  end

  # Macro to emulate user login
  def login_as_user
    session[:user_id] = 'rspec_user'
  end
end
