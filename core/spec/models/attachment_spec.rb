require 'spec_helper'

describe Dradis::Attachment do
  # fixtures :configurations

  before(:each) do
    FileUtils.mkdir(Dradis::Attachment.pwd) if !File.exists?(Dradis::Attachment.pwd)
  end
  after(:each) do
    FileUtils.rm_rf(Dradis::Attachment.pwd) if File.exists?(Dradis::Attachment.pwd)
  end

  let(:node){Dradis::Node.create!(label: 'rspec test')}

  it "copies the source file into the attachments folder" do
    attachment = Dradis::Attachment.new(Rails.root.join('spec', 'fixtures', 'files', 'rails.png'), node_id: node.id)
    attachment.save
    File.exists?(Dradis::Attachment.pwd + "#{node.id}/rails.png").should be_true

    node.destroy
  end

  it "finds attachments by filename" do
    attachment = Dradis::Attachment.new(Rails.root.join('spec', 'fixtures', 'files', 'rails.png'), node_id: node.id)
    attachment.save

    attachment = Dradis::Attachment.find('rails.png', conditions: {node_id: node.id})
    attachment.filename.should eq('rails.png')
  end

  it "finds all attachments for a given node" do
    attachment1 = Dradis::Attachment.new(Rails.root.join('spec', 'fixtures', 'files', 'rails.png'), node_id: node.id)
    attachment1.save

    attachment2 = Dradis::Attachment.new(Rails.root.join('spec', 'fixtures', 'files', 'add.gif'), node_id: node.id)
    attachment2.save

    attachments = Dradis::Attachment.find(:all, conditions: {node_id: node.id})
    attachments.count.should eq(2)
  end

  it "recognizes Ruby file IO and in particular the <<() method" do
    source = Rails.root.join('spec', 'fixtures', 'files', 'rails.png')

    attachment = Dradis::Attachment.new('rails.png', node_id: node.id)
    attachment << File.read(source)
    attachment.save

    destination = Dradis::Attachment.find('rails.png', conditions: {node_id: node.id})
    destination.size.should eq(source.size)
    FileUtils.compare_file(source,destination).should be_true()
  end

  it "can be renamed" do
    attachment = Dradis::Attachment.new(Rails.root.join('spec', 'fixtures', 'files', 'rails.png'), node_id: node.id)
    attachment.save

    attachment = Dradis::Attachment.find('rails.png', conditions: {node_id: node.id})
    attachment.filename = 'newrails.png'
    attachment.save

    attachment = Dradis::Attachment.find('newrails.png', conditions: {node_id: node.id})
    Dradis::Attachment.find(:all).count.should eq(1)
  end

end
