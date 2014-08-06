# This class is used to store configuration options in the back-end database.
# Each Configuraiton object has a :name and a :value. Some configuration 
# parameters can be accessed through the helper methods provided in this class.
class Configuration < ActiveRecord::Base
  validates_presence_of :name, :value
  validates_uniqueness_of :name

  def Configuration.exists?(*attrs)
    self.table_exists? && super(*attrs)
  end

  # Retrieve the value of the configuration setting whose name is 'revision'
  def Configuration.revision
    Configuration.find_or_create_by_name('revision').value
  end
  
  # Helper method to retrieve the value of the 'revision' setting and increment
  # it by one.
  def Configuration.increment_revision
    revision = Configuration.find_or_create_by_name('revision')
    revision.value = revision.value.to_i + 1
    revision.save
  end
  
  # Retrieves the current password (stored in the 'password' setting)
  def Configuration.password
    Configuration.exists?(:name => 'password') ? Configuration.find_by_name('password').value : nil
  end

  # Retrieve the name of the Node used to associate file uploads.
  def Configuration.uploadsNode
    Configuration.find_by_name('uploads_node').value
  end
end
