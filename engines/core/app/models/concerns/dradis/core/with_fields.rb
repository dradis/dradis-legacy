module Dradis
  module Core
    module WithFields
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
        end

        # This method can be implemented by classes including the module to add
        # custom fields to the collection that would normally be returned by
        # parsing the text blob stored in the property.
        def local_fields
          {}
        end
      end

      module ClassMethods
        # Parse the contentsof the field and split it to return a Hash of field
        # name/value pairs. Field / values are defined using this syntax:
        #
        #   #[Title]#
        #   This is the value of the Title field
        #
        #   #[Description]#
        #   Lorem ipsum...
        #
        # If the given field format does not conform to the expected syntax, an
        # empty Hash is returned.
        def with_fields(field)
          define_method :fields do
            begin
              Hash[ *(self.send(field).scan(/#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m).flatten.collect do |str| str.strip end ].merge(local_fields)
            rescue
              # if the note is not in the expected format, just return an empty hash
              {}
            end
          end
        end
      end
    end
  end
end