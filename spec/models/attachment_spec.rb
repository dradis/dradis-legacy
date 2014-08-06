require 'spec_helper'

describe Attachment do
  fixtures :configurations

  before(:each) do
    FileUtils.mkdir_p(Attachment.pwd)
    Node.stub(:exists?) { |id| id.to_i == 1 }
  end

  after(:each) do
    FileUtils.rm_rf(Attachment.pwd) if File.exists?(Attachment.pwd)
  end

  def existing_file_name
    'example.txt'
  end

  # An example file that is already in the file system
  def existing_file_path
    Rails.root.join('test', 'unit', existing_file_name)
  end

  it "works in its own subdirectory" do
    Attachment.pwd.should be_a_kind_of(Pathname)
  end

  it "should copy the source file into the attachments folder" do
    node = Node.create!(:label => 'rspec test')
    attachment = Attachment.new(existing_file_path, :node_id => node.id)
    attachment.save
    created = Attachment.pwd + "#{node.id}/#{existing_file_name}"
    File.exists?(created).should be_true
    node.destroy
  end

  it "should be able to find attachments by filename" do
    attachment = Attachment.new(existing_file_path, :node_id => '1')
    attachment.save
    attachment = Attachment.find(
        existing_file_name, :conditions => {:node_id => 1})
    existing_file_name.should eq(attachment.filename)
  end

  it "should recognise Ruby file IO and in particular the <<() method" do
    attachment = Attachment.new(existing_file_name, :node_id => '1')
    file_handle = File.new(existing_file_path,'r')
    content = file_handle.read
    attachment << content
    attachment.save
    attachment_content = Attachment.find(
        existing_file_name, :conditions => {:node_id => 1}).read
    content.should eq(attachment_content)
  end

  it "should read content in binary"
  # contents of non-ASCII files should be read correctly,
  # see example_with_encoding.txt
  # maybe this is just an issue with comparing strings

  it "should be re-nameable" do
    attachment = Attachment.new(existing_file_path, :node_id => '1')
    attachment.save
    attachment = Attachment.find(existing_file_name, :conditions => {:node_id => 1})
    attachment.filename = 'newrails.png'
    attachment.save
    attachment = Attachment.find('newrails.png', :conditions => {:node_id => 1})
    Attachment.find(:all).count.should eq(1)
  end

  describe "initialization" do
    describe "using a tempfile" do
      it "creates the tempfile" do
        filename = "abc.temp"
        path = File.join(Rails.root, 'tmp', filename)
        FileUtils.rm path, :force => true
        attachment = Attachment.new(:tempfile => filename)
        attachment.tempfile.should == "abc.temp"
        File.exist?(path).should be_true
      end
    end
  end

  describe "#save" do

    before(:each) do
      @attachment = Attachment.new :node_id => 2000, :tempfile => "abcde.temp"
    end

    context "with existing file" do
      it "does not require a Node"
    end

    context "when file does not exist" do

      it "requires an existing Node" do
        error_message = /Node with ID=2000 does not exist/
        lambda { @attachment.save }.should raise_error error_message
      end

    end

  end

  describe "#delete" do
    it "works"
  end

  describe "#find" do
    before(:each) do
      attachment = Attachment.new(existing_file_path, :node_id => '1')
      attachment.save
      attachment = Attachment.new(
          Rails.root.join('public', 'images', 'add.gif'), :node_id => '1')
      attachment.save
    end

    it "with :all returns all attachments for a given node" do
      attachments = Attachment.find(:all, :conditions => {:node_id => 1})
      attachments.map(&:filename).should eq(["add.gif", "example.txt"])
    end

    it "with :first returns the first attachment" do
      attachment = Attachment.find(:first, :conditions => {:node_id => 1})
      attachment.filename.should eq("add.gif")
    end

    it "with :last returns the last attachment" do
      attachment = Attachment.find(:last, :conditions => {:node_id => 1})
      attachment.filename.should eq("example.txt")
    end

    describe "without a node_id" do
      it "returns attachments from all nodes"
    end

    describe "with node_id and filename" do
      it "returns the attachment of the same filename" do
        attachment = Attachment.find("add.gif", :conditions => {:node_id => 1})
        attachment.filename.should eq("add.gif")
      end

      it "fails if the file does not exist" do
        error_message = /Could not find Attachment with filename nosuchfile.txt/
        lambda {
          Attachment.find("nosuchfile.txt", :conditions => {:node_id => 1})
        }.should raise_error error_message
      end

      it "fails without a node_id" do
        error_message = /You need to supply a node id in the condition parameter/
        lambda {
          Attachment.find("add.gif", :conditions => {})
        }.should raise_error error_message
      end

    end

  end



end
