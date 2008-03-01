class Configuration < ActiveRecord::Base
  validates_presence_of :name, :value
  
  def Configuration.increment_revision
    revision = Configuration.get_revision
    revision.value = revision.value.to_i + 1
    revision.save
  end
  
  def Configuration.get_revision
    Configuration.find(:first, :conditions => { :name => 'revision'} )
  end
end
