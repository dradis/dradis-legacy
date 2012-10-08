require 'spec_helper'

describe Dradis::Category do
  it "requires a name" do
    c = Dradis::Category.new
    c.should_not be_valid()
    c.name = "Foo"
    c.should be_valid()
  end
end