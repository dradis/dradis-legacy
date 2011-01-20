require 'spec_helper'

describe Core::Configurator do

  before(:each) do
    @config_1 = Configuration.create :name => "spec:test1", :value => "abc"
    @config_2 = Configuration.create :name => "spec:test2", :value => "def"
    @config_3 = Configuration.create :name => "some:other", :value => "ghi"
  end

  it "should allow the namespace to be overridden" do
    configuration = Class.new(Core::Configurator)

    configuration.namespace.should_not == "spec"
    configuration.configure(:namespace => 'spec')
    configuration.namespace.should == "spec"
  end

  it "should be possible to find configurations defined within the selected namespace" do
    configuration = Class.new(Core::Configurator).configure(:namespace => 'spec')
    
    configuration.try(:test1).should == "abc"
    configuration.try(:test2).should == "def"
  end
  
  it "shouldn't be possible to find another namespace's configurations" do
    configuration = Class.new(Core::Configurator).configure(:namespace => 'spec')

    configuration.try(:other).should be_nil
  end

  it "should respond_to? a key which is not set, but has a default value" do
    configuration = Class.new(Core::Configurator).configure(:namespace => 'spec') do
      setting :something, :default => 'test'
    end

    configuration.respond_to?(:something).should be_true
  end

  it "should return a default value for a key which is not set" do
    configuration = Class.new(Core::Configurator).configure(:namespace => 'spec') do
      setting :something, :default => 'test'
    end

    configuration.try(:something).should == 'test'
  end

  it "should collect all configurables" do
    count = Core::Configurator.configurables.count

    configuration_1 = Class.new(Core::Configurator).configure(:namespace => 'spec') do
      setting :something, :default => 'test'
    end
    
    Core::Configurator.configurables.should include(configuration_1)
    Core::Configurator.configurables.count.should == count + 1
  end

  it "should return all configurations" do
    configuration = Class.new(Core::Configurator).configure(:namespace => 'specs') do
      setting :something, :default => 'test'
    end

    Configuration.create(:name => "specs:something", :value => "xyz")

    configuration.settings.count.should == 1
    configuration.settings.first.value.should == "xyz"
  end

  it "should return default values as configurations" do
    configuration = Class.new(Core::Configurator).configure(:namespace => 'specs') do
      setting :something, :default => 'test'
    end

    configuration.settings.count.should == 1
    configuration.settings.first.value.should == "test"
  end
  
  it "should return ad-hoc configurations" do
    configuration = Class.new(Core::Configurator).configure(:namespace => 'specs') do
      setting :something, :default => 'test'
    end

    Configuration.create(:name => "specs:else", :value => "xyz")

    configuration.settings.count.should == 2
  end

  it "should return a hash of all settings from the current namespace" do
    configuration = Class.new(Core::Configurator).configure(:namespace => 'specs') do
      setting :something, :default => 'test'
    end

    configuration.to_hash.keys.should include('specs:something')
    configuration.to_hash['specs:something'].should == "test"
  end

end
