# require 'spec_helper'
# 
# describe Attachment do
#   fixtures :configurations
# 
#   before(:each) do
#   end
# 
#   it "should copy the source file into the attachments folder" do
#     node = Node.create!(:label => 'rspec test')
# 
#     attachment = Attachment.new( Rails.root.join('public', 'images', 'rails.png'), :node_id => node.id )
#     attachment.save
#     File.exists?(Attachment.pwd + "#{node.id}/rails.png").should be_true
# 
#     node.destroy
#   end
# 
#   it "should be able to find attachments by filename"
#   it "should be able to find all attachments for a given node"
#   it "should recognise Ruby file IO and in particular the <<() method"
#   it "should be re-nameble"
# end

# TestUnit

# require File.dirname(__FILE__) + '/../test_helper'
# 
# class AttachmentTest < ActiveSupport::TestCase
#   
#   require 'fileutils'
# 
#   def setup
#     FileUtils.mkdir(Attachment.pwd) if !File.exists?(Attachment.pwd)
#   end
# 
#   def teardown
#     FileUtils.rm_rf(Attachment.pwd) if File.exists?(Attachment.pwd)
#   end
# 
#   # Test if the actual file is created in the expected place
#   def test_should_create_new_file
#     attachment = Attachment.new( Rails.root.join('public', 'images', 'rails.png', :node_id => '1')
#     attachment.save
#     assert File.exists?(Attachment.pwd + "/1/rails.png")
#   end
# 
#   # Confirm that an attachment can be found by filename and node_id
#   def test_should_find_file_by_file_name
#     attachment = Attachment.new( Rails.root.join('public', 'images', 'rails.png', :node_id => '1')
#     attachment.save
#     attachment = Attachment.find("rails.png", :conditions => {:node_id => 1})
#     assert_equal "rails.png", attachment.filename
#   end
# 
#   def test_should_create_new_file_from_file_io
#     attachment = Attachment.new("rails.png", :node_id => '1')
#     file_handle = File.new(Rails.root.join('public', 'images', 'rails.png'),'r')
#     content = file_handle.read
#     attachment << content
#     attachment.save
#     attachment_content = Attachment.find("rails.png", :conditions => {:node_id => 1}).read
#     assert_equal content, attachment_content
#   end
# 
#   def test_should_get_all_attachments_for_node
#     attachment = Attachment.new( Rails.root.join('public', 'images', 'rails.png', :node_id => '1')
#     attachment.save
#     attachment = Attachment.new( Rails.root.join('public', 'images', 'add.gif', :node_id => '1')
#     attachment.save
#     attachments = Attachment.find(:all, :conditions => {:node_id => 1})
#     assert_equal 2, attachments.count
#   end
# 
#   def test_should_rename_filename
#     attachment = Attachment.new( Rails.root.join('public', 'images', 'rails.png', :node_id => '1')
#     attachment.save
#     attachment = Attachment.find('rails.png', :conditions => {:node_id => 1})
#     attachment.filename = 'newrails.png'
#     attachment.save
#     assert attachment = Attachment.find('newrails.png', :conditions => {:node_id => 1})
#     assert_equal 1, Attachment.find(:all).count
#   end
# 
# end
