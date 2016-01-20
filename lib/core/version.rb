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
    MAJOR = 3
    MINOR = 0
    TINY  = 0
    PRE   = 'rc3'

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

    def VERSION.string
      "Dradis Framework v#{STRING}";
    end
    def VERSION.show
      puts VERSION.string; exit(0); 
    end    
  end
end
