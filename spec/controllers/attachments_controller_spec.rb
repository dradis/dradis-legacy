require 'spec_helper'

describe AttachmentsController do

  describe "as guest" do
    it_should_require_authentication
  end

  describe "as user" do
    before(:each) do
      login_as_user
    end

    it "should pass params to the attachment object"

    it "should save a file without extension"

    it "should show an attachment without extension"

    it "should auto-rename if file name already exists"
  end
end
