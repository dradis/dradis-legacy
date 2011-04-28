require 'spec_helper'

describe AttachmentsController do

  def mock_uploader(file, type = 'image/png')
    uploader = ActionDispatch::Http::UploadedFile.new({:filename => file.path, :type => type, :tempfile => file })
    def uploader.read
      File.read(path)
    end
    def uploader.size
      File.stat(path).size
    end
    uploader
  end


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
      upload = mock_uploader File.new('public/images/rails.png')

      post :create, :attachment_file => upload, :node_id => @node.id

      response.should be_success
      @node.attachments.should have(1).item
      @node.attachments.first.filename.should == 'rails.png'
    end

    it "should fail if no file is uploaded"

    it "should pass params to the attachment object"

    it "should save a file without extension"

    it "should show an attachment without extension"

    it "should auto-rename if file name already exists"
  end
end
