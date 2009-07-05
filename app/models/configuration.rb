class Configuration < ActiveRecord::Base
  validates_presence_of :name, :value

  def Configuration.revision
    Configuration.find_by_name('revision').value
  end
  
  def Configuration.increment_revision
    revision = Configuration.find_by_name('revision')
    revision.value = revision.value.to_i + 1
    revision.save
  end
  
  def Configuration.password
    Configuration.find_by_name('password').value
  end

  def Configuration.uploadsNode
    Configuration.find_by_name('uploads_node').value
  end
end
