require 'spec_helper'

describe 'ProjectManagement plugin' do
  describe 'Template upload' do
    it "restores the node positions from the template" do
      fixture_file = "spec/fixtures/files/with_positions.xml"
      Node.count.should eq(0)
      Note.count.should eq(0)
      lambda{ ProjectTemplateUpload::import( :file => fixture_file ) }.should_not raise_error
      Node.count.should eq(9)
      Note.count.should eq(3)
      node = Node.find_by_label('branch #1')
      node.should_not be_nil()
      node.notes.count.should eq(1)
      node.notes.first.text.should eq('two')
      node.position.should eq(2)
    end

    it "gracefully handles imports without positions (pre v2.9)" do
      fixture_file = "spec/fixtures/files/no_positions.xml"
      Node.count.should eq(0)
      Note.count.should eq(0)
      lambda{ ProjectTemplateUpload::import( :file => fixture_file ) }.should_not raise_error
      Node.count.should eq(9)
      Note.count.should eq(3)
      node = Node.find_by_label('branch #1')
      node.should_not be_nil()
      node.notes.count.should eq(1)
      node.notes.first.text.should eq('two')
      node.position.should eq(0)
    end
  end
end