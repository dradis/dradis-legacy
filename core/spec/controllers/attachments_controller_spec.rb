require 'spec_helper'

describe AttachmentsController do
  describe "as guest" do
    it_should_require_authentication :attachment
  end

  describe "as user" do

    before(:each) do
      login_as_user
      @node = Factory.create(:node)
    end
    after(:each) do
      @node.destroy
    end

    it_should_require_parent_resource_id(:attachment)

    it "should save an uploaded file as an attachment" do
      post :create, :attachment_file => fixture_file_upload('/files/rails.png', 'image/png'), :node_id => @node.id

      response.should be_success
      @node.attachments.should have(1).item
      @node.attachments.first.filename.should == 'rails.png'
    end

    pending "should fail if no file is uploaded"

    pending "should pass params to the attachment object"

    pending "should save a file without extension"

    pending "should show an attachment without extension"

    pending "should auto-rename if file name already exists"
  end
end
