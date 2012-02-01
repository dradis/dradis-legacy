Welcome to Dradis
=================

[![Build Status](https://secure.travis-ci.org/dradis/dradisframework.png)](https://secure.travis-ci.org/dradis/dradisframework)

Dradis is an open source framework to enable effective information sharing, 
specially during security assessments.

Our goals:

* Share the information effectively.
* Easy to use, easy to be adopted. Otherwise it would present little benefit over other systems.
* Flexible: with a powerful and simple extensions interface. 
* Small and portable. You should be able to use it while on site (no outside connectivity). It should be OS independent (no two testers use the same OS).

Some of the features:

* Platform independent
* Easy report generation: in Word, HTML, etc.
* Markup support for the notes: styles, images, links, etc. 
* Integration with existing systems and tools:
  * [Burp Scanner](http://portswigger.net/burp/scanner.html)
  * [Metasploit](http://www.metasploit.com/)
  * [Nessus](http://www.nessus.org/products/nessus)
  * [NeXpose](http://www.rapid7.com/products/nexpose-community-edition.jsp)
  * [Nikto](http://cirt.net/nikto2)
  * [Nmap](http://nmap.org)
  * [OpenVAS](http://www.openvas.org/)
  * [OSVDB](http://osvdb.org)
  * [Retina](http://www.eeye.com/products/retina/retina-network-scanner)
  * [SureCheck](http://www.wildcroftsecurity.com/)
  * [VulnDB](http://vulndbhq.com)
  * [w3af](http://w3af.sourceforge.net/)
  * [wXf](https://github.com/WebExploitationFramework/wXf)
  * [Zed Attack Proxy](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project)


Getting started (stable release)
--------------------------------

In http://dradisframework.org/downloads.html you will find a Windows installer
and .tar.gz and .tar.bz2 packages.

Uncompress, verify and prepare the environment:

    $ tar xvvjf dradis-vX.Y.Z.tar.bz2
    $ cd dradis-vX.Y/
    $ ./verify.sh
      # follow instructions / install dependencies
    $ ./reset.sh

Once the environment is ready, you can start the server with:

    $ ./start.sh

And browse to https://localhost:3004 to start using Dradis. If you need to bind
to a different address (so others can connect to your instance) or another port
number, you can use the -b and -p switches respectively:

    $ ./start.sh -b 10.0.0.123 -p 443


Getting started (git release)
-----------------------------

First, clone the repo:

    $ mkdir dradis-git
    $ cd dradis-git/
    $ git clone https://github.com/dradis/dradisframework.git server

Then download the verify, reset and start scripts to your dradis-git/ folder:

    $ curl -O https://raw.github.com/dradis/meta/master/verify.sh
    $ curl -O https://raw.github.com/dradis/meta/master/reset.sh
    $ curl -O https://raw.github.com/dradis/meta/master/start.sh
    $ chmod +x *.sh
    $ ./verify.sh
      # follow instructions / install dependencies
    $ ./reset.sh

Dradis runs on top of Ruby on Rails so you need an extra step to make sure all
the JavaScript files and stylesheets are served swiftly:

    $ cd server/
    $ RAILS_ENV=production bundle exec rake assets:precompile
    $ cd ..

Once the environment is ready, you can start the server with:

    $ ./start.sh

And browse to https://localhost:3004 to start using Dradis.

If you would like to make Dradis accessible to other people on the network:

    $ ./start.sh -b 0.0.0.0 -p 443

The `-b` option defines Dradis' bind address and the `-p` option can be used to change the port.


Getting help
------------

* http://dradisframework.org/
* Dradis Guides: http://guides.dradisframework.org
* [Community Forums](http://dradisframework.org/community/)
* IRC: **#dradis** `irc.freenode.org`


Contributing
------------

* Join the developer discussion at: [dradis-devel](https://lists.sourceforge.net/mailman/listinfo/dradis-devel)
* [Report a bug](https://github.com/dradis/dradisframework/issues)
* Help with the [Dradis Guides](https://github.com/dradis/dradisguides) project or submit your guide.
* Submit a patch:
  * Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
  * Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
  * Fork the project
  * Start a feature/bugfix branch
  * Commit and push until you are happy with your contribution
  * Make sure to add tests for it. This is important so we don't break it in a future version unintentionally.
  * Review our [Contributor's Agreement](https://github.com/dradis/dradisframework/wiki/Contributor%27s-agreement). Sending us a pull request means you have read and accept to this agreement
  * Send us a [pull request](http://help.github.com/pull-requests/)


License
-------

Dradis Framework is released under [GNU General Public License version 2.0](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
