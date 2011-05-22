Welcome to Dradis
=================

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
  * [SureCheck](http://www.wildcroftsecurity.com/)
  * [Vuln::DB](http://securityroots.com/vulndb/)
  * [w3af](http://w3af.sourceforge.net/)
  * [wXf](https://github.com/WebExploitationFramework/wXf)


Getting started
---------------

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

And browse to https://localhost:3004 to start using Dradis

Getting help
------------

* http://dradisframework.org/
* [Community Forums](http://dradisframework.org/community/)
* [Found a bug?](https://github.com/dradis/dradisframework/issues)
* IRC: **#dradis** `irc.freenode.org`

Contributing
------------



License
-------

Dradis Framework is released under [GNU General Public License version 2.0](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
