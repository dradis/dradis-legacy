require 'spec_helper'

describe Node do
  before(:each) do
    @node = Node.new
  end

  it "shouldn't be valid without a label" do
    @node.should_not be_valid
    @node.should have(1).error_on(:label)
    @node.errors[:label].first.should == "can't be blank"
    @node.label = 'rspec node'
    @node.should be_valid
  end
  
  it "should delete all nested nodes when deleted" do
    parent = Factory.create(:node)

    3.times do 
      parent.children << Factory.create(:node)
    end

    child_ids = parent.children.map(&:id)

    parent.destroy

    child_ids.each do |id|
      lambda{ Node.find(id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it "should delete all associated notes when deleted" do
    node = Factory.create(:node)

    3.times do 
      node.notes << Factory.create(:note)
    end

    note_ids = node.notes.map(&:id)

    node.destroy

    note_ids.each do |id|
      lambda{ Note.find(id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it "should delete all associated attachments"
  it "should delete it's corresponding attachment subfolder when deleted"
end
