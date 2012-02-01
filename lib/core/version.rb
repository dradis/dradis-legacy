=begin
**
** version.rb
** 20/APR/2009
**
** Desc:
**   Contains the version information for the current release of the framework. 
**
** License:
**   See dradis.rb or LICENSE.txt for copyright and licensing information.
**
=end

module Core #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 2
    MINOR = 10
    TINY  = 0

    STRING = [MAJOR, MINOR, TINY].join('.')
    def VERSION.string
      "Dradis Framework v#{STRING}";
    end
    def VERSION.show
      puts VERSION.string; exit(0); 
    end    
  end
end
