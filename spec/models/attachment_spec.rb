require 'spec_helper'

describe Attachment do
  fixtures :configurations

  before(:each) do
  end

  it "should copy the source file into the attachments folder" do
    node = Node.create!(:label => 'rspec test')

    attachment = Attachment.new( Rails.root.join('public', 'images', 'rails.png'), :node_id => node.id )
    attachment.save
    File.exists?(Attachment.pwd + "#{node.id}/rails.png").should be_true

    node.destroy
  end

  it "should be able to find attachments by filename"
  it "should be able to find all attachments for a given node"
  it "should recognise Ruby file IO and in particular the <<() method"
  it "should be re-nameble"
end
