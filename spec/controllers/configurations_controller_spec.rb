require 'spec_helper'

describe ConfigurationsController do
  fixtures :configurations

  describe "as guest" do
    it_should_require_authentication :configuration
  end

  describe "as user" do

    before(:each) do
      login_as_user
    end

    it "should display the configuration manager" do
      get :index

      response.should be_success
    end
    
    it "should create a new, namespaced setting" do
      post :create, :config => { :name => 'spec:configuration', :value => 'abc123' }, :format => :js
      
      response.code.should == "201"
    end

    it "should change the value of a setting" do
      config = Configuration.create!(:name => "spec:configuration", :value => "abc123")
      
      put :update, :id => config.id, :config => { :value => 'abc456' }, :format => :js

      response.should be_success
      config.reload.value.should == 'abc456'
    end

    it "should find a configuration by its id" do
      config = Configuration.create!(:name => "spec:configuration", :value => "abc123")
      
      get :show, :id => config.id, :format => :xml
      
      response.should be_success
      assigns[:config].id.should == config.id
    end

    it "should find a configuration by name" do
      config = Configuration.create!(:name => "spec:configuration", :value => "abc123")

      get :show, :id => config.name, :format => :xml

      response.should be_success
      assigns[:config].id.should == config.id
    end

  end
end
