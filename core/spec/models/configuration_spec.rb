require 'spec_helper'

describe Configuration do
  before(:each) do
    @config = Configuration.new
  end
  
  it "shouldn't be valid without a name" do
    # we are just concerned with :name in this case
    @config.value = 'rspec value'

    @config.should_not be_valid
    @config.should have(1).error_on(:name)
    @config.errors[:name].first.should == "can't be blank"
    @config.name = 'rspec config'
    @config.should be_valid
  end

  it "shouldn't be valid without a value" do
    # we are just concerned with :value in this case
    @config.name = 'rspec config'

    @config.should_not be_valid
    @config.should have(1).error_on(:value)
    @config.errors[:value].first.should == "can't be blank"
    @config.value = 'rspec value'
    @config.should be_valid
  end

  it "shouldn't be allowed to duplicate an already existing name" do
    @config.name = 'rspec name'
    @config.value = 'rspec value'
    @config.save

    @config2 = Configuration.new(:name => 'rspec name', :value => 'rspec value')
    @config2.should_not be_valid
    @config2.should have(1).error_on(:name)
    @config2.errors[:name].first.should == "has already been taken"

    @config.destroy
  end
end
