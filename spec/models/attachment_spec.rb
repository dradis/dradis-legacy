require 'spec_helper'

describe Attachment do
  fixtures :configurations

  before(:each) do
    FileUtils.mkdir_p(Attachment.pwd)
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
    File.exists?(Attachment.pwd + "#{node.id}/#{existing_file_name}").should be_true
    node.destroy
  end

  it "should be able to find attachments by filename" do
    attachment = Attachment.new(existing_file_path, :node_id => '1')
    attachment.save
    attachment = Attachment.find(existing_file_name, :conditions => {:node_id => 1})
    existing_file_name.should eq(attachment.filename)
  end

  it "should recognise Ruby file IO and in particular the <<() method" do
    attachment = Attachment.new(existing_file_name, :node_id => '1')
    file_handle = File.new(existing_file_path,'r')
    content = file_handle.read
    attachment << content
    attachment.save
    attachment_content = Attachment.find(existing_file_name, :conditions => {:node_id => 1}).read
    content.should eq(attachment_content)
  end

  it "should read content in binary"
  # contents of non-ASCII files should be read correctly, see example_with_encoding.txt
  # maybe this is just an issue with comparing strings



  it "should be able to find all attachments for a given node" do
    attachment = Attachment.new(existing_file_path, :node_id => '1')
    attachment.save
    attachment = Attachment.new(Rails.root.join('public', 'images', 'add.gif'), :node_id => '1')
    attachment.save
    attachments = Attachment.find(:all, :conditions => {:node_id => 1})
    attachments.count.should eq(2)
  end

  it "should be re-nameable" do
    attachment = Attachment.new(existing_file_path, :node_id => '1')
    attachment.save
    attachment = Attachment.find(existing_file_name, :conditions => {:node_id => 1})
    attachment.filename = 'newrails.png'
    attachment.save
    assert attachment = Attachment.find('newrails.png', :conditions => {:node_id => 1})
    Attachment.find(:all).count.should eq(1)
  end

  describe "using a tempfile" do
    #
  end

end
