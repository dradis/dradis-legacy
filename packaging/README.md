# Packaging Dradis with Traveling Ruby


## Before you start

Make sure you're running these instructions in Ruby 2.1:

```
bundle exec ruby -v
```

Also, whilst not strictly required you could check if there is a new version of (Traveling Ruby)[http://phusion.github.io/traveling-ruby/] we can use.



## The meat and potatoes


Run any of this tasks:

```
bundle exec rake package
```

Alternatively you can run individual tasks for the different supported platforms:

```
bundle exec rake package:osx
bundle exec rake package:linux:x86
bundle exec rake package:linux:x86_64
```

When the task finishes you will find your packages in Dradis root as tar.gz files.

