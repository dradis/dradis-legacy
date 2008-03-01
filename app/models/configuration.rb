class Configuration < ActiveRecord::Base
  validates_presence_of :name, :value
  
  def Configuration.increment_revision
    revision = Configuration.find(:first, :conditions => { :name => 'revision'} )
    revision.value = revision.value.to_i + 1
    revision.save
  end
end
