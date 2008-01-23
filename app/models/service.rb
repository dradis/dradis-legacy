class Service < ActiveRecord::Base
  belongs_to :host
  belongs_to :protocol
  has_many :notes, :as => :annotatable, :dependent => :destroy
  
  validates_numericality_of :port
  validates_presence_of :host, :protocol
  
  def to_label
    return "#{self.name} (#{self.protocol.name}/#{self.port})"
  end
end
