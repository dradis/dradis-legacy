Welcome to Dradis
=================

[![Build Status](https://secure.travis-ci.org/dradis/dradisframework.png)][travis][![Dependency Status](https://gemnasium.com/dradis/dradisframework.png)][gemnasium]

[travis]: https://secure.travis-ci.org/dradis/dradisframework
[gemnasium]: https://gemnasium.com/dradis/dradis

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

Installing Ruby and RVM
-----------------------

On Debian-based operating systems (Ubuntu, BackTrack, etc.) use this script:

    $ bash < <(curl -s https://raw.github.com/dradis/meta/master/install.sh)

The script:
  1. Checks for system-level dependencies (git, openssl, etc.)
  2. Installs [RVM](http://beginrescueend.com/rvm/install/) and Ruby 1.9.3. It detects and reuses your existing RVM too.

[View install.sh source](https://github.com/dradis/meta/blob/master/install.sh)

(This script also downloads a copy of this repo, which was fine in 2.x but no longer used in 3.x, ignore or delete it)


Installation (during 3.0 preparation)
-------------------------------------
Once you have Ruby 1.9.3 in your system you can install the Dradis gem:

```
$ git clone git://github.com/dradis/dradisframework.git
$ git checkout -b dradis3.x remotes/origin/dradis3.x
$ cd core/
$ rake build
$ cd pkg/
$ gem install dradis_core-3.0.0.beta.gem
```


Installation (after 3.0 release)
--------------------------------

Once you have Ruby 1.9.3 in your system you can install the Dradis gem:

    $ gem install dradis



Running
-------

In order to start using Dradis you need to deploy it in a folder of your choosing:

    $ dradis new ~/dradis

And you're ready to start the server:

    $ cd ~/dradis/
    $ bundle exec rails server

Now you can browse to https://localhost:3004 to start using Dradis.

If you would like to make Dradis accessible to other people on the network:

    $ bundle exec rails server -b 0.0.0.0 -p 443

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
