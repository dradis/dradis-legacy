module Dradis
  module Core
    # Returns the version of the currently loaded Core as a <tt>Gem::Version</tt>
    def self.gem_version
      Gem::Version.new VERSION::STRING
    end

    module VERSION
      MAJOR = 3
      MINOR = 0
      TINY = 0
      PRE = nil

      STRING = [MAJOR, MINOR, TINY, PRE].compact.join(".")
    end
  end
end