class Ticket < ActiveRecord::Base
  validates_presence_of :ip, :valid_until, :value
end
