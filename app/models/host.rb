class Host < ActiveRecord::Base
  has_many :services, :dependent => :destroy
  has_many :notes, :as => :annotatable, :dependent => :destroy
  
  validates_presence_of :address
  validates_uniqueness_of :address
  
  def to_label
    return self.address
  end
  
  #def to_xml
  #  super(:include=>:service)
  #end
end
