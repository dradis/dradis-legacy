module ControllerMacros

  def self.included(base)
    base.extend(ClassMethods)
    base.fixtures(:configurations)
  end

  module ClassMethods
    # Get all actions for specified controller
    def get_all_actions(controller_name)
      controller_class = Module.const_get(controller_name.to_s.pluralize.capitalize + "Controller")
      controller_class.public_instance_methods(false).reject{ |action| ['rescue_action'].include?(action) || (action =~ /_one_time_conditions/) }
    end


    # This method goes through the controller actions and creates a new spec to
    # ensure they all require authentication.
    def it_should_require_authentication(controller, options={})
      except= options[:except] || []
      actions_to_test= get_all_actions(controller).reject{ |a| except.include?(a) }
      actions_to_test += options[:include] if options[:include]
      actions_to_test.each do |action|
        it "should require authentication for :#{action}" do
          get action 
          response.should redirect_to(login_path)
          flash[:notice].should == 'Access denied.'
        end
      end
    end

    def it_should_require_parent_resource_id(controller, options={})
      except= options[:except] || []
      actions_to_test= get_all_actions(controller).reject{ |a| except.include?(a) }
      actions_to_test += options[:include] if options[:include]
      actions_to_test.each do |action|
        it "should require parent resource id for :#{action}" do
          get action 
          response.should redirect_to(root_path)
          flash[:error].should_not be_nil
        end
      end

      if options.key?(:parent_id)
        if actions_to_test.include?(:index)
          it "should list all the nested resources if the associated parent resource id is passed"
        end
      end
    end
  end

  # Macro to emulate user login
  def login_as_user
    session[:user_id] = 'rspec_user'
  end
end
