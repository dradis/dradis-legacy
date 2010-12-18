require 'spec_helper'

describe NotesController do
  fixtures :configurations

  describe "as guest" do
    it_should_require_authentication :note
  end

  describe "as user" do

    before(:each) do
      login_as_user
    end

    it "should fail if no Node id is passed" do
      get :index
      response.should redirect_to(root_path)
      flash[:error].should_not be_nil
    end

  end
end
