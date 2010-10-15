require File.dirname(__FILE__) + '/../test_helper'

module Plugins::Upload
  module DummyUpload
    def self.import()
      raise 'This upload always fails!'
    end 
  end
end

class UploadControllerTest < ActionController::TestCase
  def test_processingexception
    job_id = Time.now.to_i

    # 1st start the background processing of the upload
    Delayed::Job::enqueue( 'DummyUpload', '/tmp/nonexistent', job_id )
    sleep 3

    get(:status, {:after => 0, :item_id => job_id})

    assert assigns[:logs].collect(&:text).includes?('This upload always fails!')
  end
end
