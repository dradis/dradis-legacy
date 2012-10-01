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

    it_should_require_parent_resource_id(:notes)
  end
end
