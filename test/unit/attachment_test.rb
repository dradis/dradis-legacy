require_relative '../test_helper'

class AttachmentTest < ActiveSupport::TestCase
  
  require 'fileutils'

  def setup
    FileUtils.mkdir_p(Attachment.pwd) if !File.exists?(Attachment.pwd)
  end

  def teardown
    FileUtils.rm_rf(Attachment.pwd) if File.exists?(Attachment.pwd)
  end

  def existing_file_name
    'example.txt'
  end

  # An example file that is already in the file system
  def existing_file_path
    Rails.root.join('test', 'unit', existing_file_name)
  end

  def test_has_a_pwd
    assert_instance_of Pathname, Attachment.pwd
  end

  # Test if the actual file is created in the expected place
  def test_should_create_new_file
    attachment = Attachment.new(existing_file_path, :node_id => '1')
    attachment.save
    filename = File.join(Attachment.pwd, "/1/" + existing_file_name)
    assert File.exists?(filename)
  end

  # Confirm that an attachment can be found by filename and node_id
  def test_should_find_file_by_file_name
    attachment = Attachment.new( existing_file_path, :node_id => '1')
    attachment.save
    attachment = Attachment.find(existing_file_name, :conditions => {:node_id => 1})
    assert_equal existing_file_name, attachment.filename
  end

  def test_should_create_new_file_from_file_io
    attachment = Attachment.new(existing_file_name, :node_id => '1')
    file_handle = File.new(existing_file_path,'r')
    content = file_handle.read
    attachment << content
    attachment.save
    attachment_content = Attachment.find(existing_file_name, :conditions => {:node_id => 1}).read
    assert_equal content, attachment_content
  end

  def xtest_should_read_content_in_binary
    # contents of non-ASCII files should be read correctly, see example_with_encoding.txt
    # maybe this is just an assert issue
  end

  def test_should_get_all_attachments_for_node
    attachment = Attachment.new(existing_file_path, :node_id => '1')
    attachment.save
    attachment = Attachment.new( Rails.root.join('public', 'images', 'add.gif'), :node_id => '1')
    attachment.save
    attachments = Attachment.find(:all, :conditions => {:node_id => 1})
    assert_equal 2, attachments.count
  end

  def test_should_rename_filename
    attachment = Attachment.new(existing_file_path, :node_id => '1')
    attachment.save
    attachment = Attachment.find(existing_file_name, :conditions => {:node_id => 1})
    attachment.filename = 'newrails.png'
    attachment.save
    assert attachment = Attachment.find('newrails.png', :conditions => {:node_id => 1})
    assert_equal 1, Attachment.find(:all).count
  end

end
