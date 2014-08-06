require 'spec_helper'

describe Note do
  before(:each) do
    @category = Category.create!(:name => "test_category")
    @node     = Node.create!(:label => 'rspec test')
    @note     = Note.new
  end

  it "shouldn't fail when text, cat and node are passed" do
    @note.should_not be_valid
    @note.text = 'rspec text'
    @note.node = @node
    @note.category = @category

    @note.should be_valid
  end

  it "should not allow a new note without a valid category" do
    # we are just concerned with :category in this case
    @note.text = 'rspec text'
    @note.node = @node

    @note.should_not be_valid
    @note.should have(1).error_on(:category)
    @note.errors[:category].first.should == "can't be blank"
    @note.category = @category
    @note.should be_valid
  end

  it "should not allow a new note without a valid node" do
    # we are just concerned with the :node field in this case
    @note.text = 'rspec text'
    @note.category = @category
    
    @note.should_not be_valid
    @note.should have(1).error_on(:node)
    @note.errors[:node].first.should == "can't be blank"
    @note.node = @node
    @note.should be_valid
  end

  it "should split a text field into a name/value hash" do
    note = Factory.create(:note)
    note.text =<<EON
#[Title]#
RSpec Title

#[Description]#
Nothing to see here, move on!
EON
    note.save

    note.fields.should have(2).values
    note.fields.keys.should include('Title')
    note.fields.keys.should include('Description')
    note.fields['Title'].should == "RSpec Title"
    note.fields['Description'].should == "Nothing to see here, move on!"
  end
end
