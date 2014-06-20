module Dradis
  module Core
    module Version
      MAJOR = 3
      MINOR = 0
      TINY  = 0
      PRE = nil

      STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

      def self.string
        "Dradis Framework v#{STRING}";
      end
      def self.show
        puts self.string; exit(0);
      end
    end
  end
end