require 'spec_helper'

describe Evidence do
  it "needs to be tied to an Issue" do
    node = FactoryGirl.create(:node)
    issue = FactoryGirl.create(:issue)
    evidence = Evidence.new(:node_id => node.id)

    evidence.should_not be_valid
    evidence.issue = issue
    evidence.should be_valid
    evidence.save
    evidence.reload
    evidence.issue.should eq(issue)
  end
  it "needs to be tied to a Node" do
    node = FactoryGirl.create(:node)
    issue = FactoryGirl.create(:issue)
    evidence = Evidence.new(:issue_id => issue.id)

    evidence.should_not be_valid
    evidence.node = node
    evidence.should be_valid
    evidence.save
    evidence.reload
    evidence.node.should eq(node)
  end
  it "provides access to the Node label's as a virtual field" do
    issue = FactoryGirl.create(:issue)
    node = FactoryGirl.create(:node)
    evidence = Evidence.new(:node_id => node.id, :issue_id => issue.id, :content => "#[Output]#\nResistance is futile\n\n")

    evidence.fields['Label'].should eq(node.label)
  end
end
