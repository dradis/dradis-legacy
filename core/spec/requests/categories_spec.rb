require 'spec_helper'

describe "Categories requests" do
  #it_should_behave_like "login-required resource", dradis.categories_path(format: :json)

  describe "ExtJS :json format" do
    it "returns the categories collection in the :data parameter of the JSON respons" do
      categories = []
      2.times{ categories << FactoryGirl.create(:category).name }

      login_as 'rspec'
      visit dradis.categories_path(format: :json)
      current_path.should eq(dradis.categories_path(format: :json))
      page.status_code.should eq(200)
      page.response_headers.should have_key('Content-Type')
      page.response_headers['Content-Type'].should eq('application/json; charset=utf-8')

      body = nil
      expect { body = MultiJson.decode(page.source, :symbolize_keys => true) }.to_not raise_error
      body.should have_key(:data)
      body[:data].each do |json_category|
        categories.should include(json_category[:name])
      end
    end
  end
end