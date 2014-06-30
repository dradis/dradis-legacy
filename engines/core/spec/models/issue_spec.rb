require 'spec_helper'

describe Issue do
  it "is assigned to the Category.issue category" do
    node = FactoryGirl.create(:node)
    issue = Issue.new do |i|
      i.node = node
    end
    issue.should be_valid()
    issue.save
    issue.category.should eq(Category.issue)
  end
  it "affects many nodes through :evidence" do
    issue = FactoryGirl.create(:issue)
    issue.affected.should be_empty

    host = FactoryGirl::create(:node, :label => '10.0.0.1', :type_id => Node::Types::HOST)
    host.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => "#[EvidenceBlock1]#\nThis apache is old!")

    issue.reload
    issue.affected.should_not be_empty
    issue.affected.first.should eq(host)
  end
  it "deletes associated Evidence" do
    issue = FactoryGirl.create(:issue)
    evidence = FactoryGirl.create(:evidence, :issue => issue)
    issue.evidence.count.should eq(1)
    issue.destroy
    Evidence.exists?(evidence.id).should eq(false)
  end

  # NOTE: the idea of having an Affected field appended to the automagically was
  # to allow the Affected field content control in AdvancedWordExport to work in
  # the same way the other fields do. However, this introduces a cascading SQL
  # problem every time we access any field, so we've moved the functionality to
  # retrieve the affected hosts to:
  #   AdvancedWordExport::Processors::Ooxml::Processor::populate_field - fields.rb#257
  #
  #it "provides access to the list of Affected fields as another note field" do
  #  issue = FactoryGirl.create(:issue)
  #  node1 = FactoryGirl.create(:node)
  #  node1.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => 'Foo')
  #  node2 = FactoryGirl.create(:node)
  #  node2.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => 'Bar')
  #  issue.reload
  #  issue.fields['Affected'].should eq([node1, node2].collect(&:label).to_sentence)
  #end
  #it "The Affected field contains each host only once" do
  #  issue = FactoryGirl.create(:issue)
  #  node1 = FactoryGirl.create(:node)
  #  node1.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => 'Foo')
  #  node1.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => 'Bar')
  #  node2 = FactoryGirl.create(:node)
  #  node2.evidence.create(:author => 'rspec', :issue_id => issue.id, :content => 'BarFar')
  #  issue.reload
  #  issue.fields['Affected'].should eq([node1, node2].collect(&:label).to_sentence)
  #end
end