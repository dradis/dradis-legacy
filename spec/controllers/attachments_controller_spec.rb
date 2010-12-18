require 'spec_helper'

describe AttachmentsController do
  fixtures :configurations

  describe "as guest" do
    it_should_require_authentication :attachment
  end

  describe "as user" do

    before(:each) do
      login_as_user
    end

    it "should fail if no Node id is passed" do
      get :index
      flash[:error].should_not be_nil
    end

    it "should fail if no file is uploaded"

    it "should pass params to the attachment object"

    it "should save a file without extension"

    it "should show an attachment without extension"

    it "should auto-rename if file name already exists"
  end
end
