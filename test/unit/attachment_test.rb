require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < ActiveSupport::TestCase
  
  require 'fileutils'

  def setup
    FileUtils.mkdir(Attachment.pwd) if !File.exists(Attachment.pwd)
  end

  def teardown
    FileUtils.rm_rf(Attachment.pwd) if File.exists(Attachment.pwd)
  end

  # Test if the actual file is created in the expected place
  def test_should_create_new_file
    @attachment = Attachment.new("#{RAILS_ROOT}/public/images/rails.png", :node_id => '1')
    @attachment.save
    assert File.exists?(Attachment.pwd + "/1/1.rails.png")
  end
end