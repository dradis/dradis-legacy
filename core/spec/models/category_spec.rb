require 'spec_helper'

describe Category do
  it "requires a name" do
    c = Category.new
    c.should_not be_valid()
    c.name = "Foo"
    c.should be_valid()
  end
end