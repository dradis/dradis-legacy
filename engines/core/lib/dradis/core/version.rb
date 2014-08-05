require_relative 'gem_version'

module Dradis
  module Core
    # Returns the version of the currently loaded Core as a
    # <tt>Gem::Version</tt>.
    def self.version
      gem_version
    end
  end
end
