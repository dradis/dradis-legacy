require 'spec_helper'

describe NotesController do
  fixtures :configurations

  describe "as guest" do
    it_should_require_authentication :note
  end

  describe "as user" do

    before(:each) do
      login_as_user
    end

    it "should fail if no Node id is passed" 

  end
end
