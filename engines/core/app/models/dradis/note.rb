# A Note in dradis is the basic unit of information. It has a :text and an 
# :author field that capture the contents of the Note and the creator.
#
# In Dradis 2.x notes have a fixed set of fields (:text, :author, :category, 
# :node). However, it is expected that in Dradis 3.x it will be possible to 
# configure this list of fields to match the needs of the users.
#
# In the interim, Dradis 2.x Note objects use a special syntax in their :text
# field to define different fields. This syntax is as follows:
#
#   #[Title]#
#   Directory Listings
#   
#   #[Description]#
#   Some directories on the server were configured [...]
#
# The syntax above would result in the call to the fields method to return a 
# Hash with two elements:
#
#   { 
#     'Title' => 'Directory Listings',
#     'Description' => 'Some directories on the server were configured [...]',
#   }
#
#
# This behaviour is extensively used by import/export plugins such as WordExport.
class Note < ActiveRecord::Base
  # Virtual attribute:
  #   * Set by the NotesController when modifying a note
  #   * Used by the RevisionObserver to track record changes
  attr_accessor :updated_by

  belongs_to :category
  belongs_to :node

  validates_presence_of :category, :node

  # Parse a Note's :text field and splits it to return a Hash of field name/value
  # pairs as described in the class description above.
  #
  # If the :text field format does not conform to the expected syntax, an empty
  # Hash is returned.
  def fields
    begin
      Hash[ *self.text.scan(/#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m).flatten.collect do |str| str.strip end ]
    rescue
      # if the note is not in the expected format, just return an empty hash
      {}
    end
  end
end
