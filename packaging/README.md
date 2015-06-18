Packaging Dradis with Traveling Ruby
====================================

Run any of these tasks:

```
rake package
rake pacage:osx
rake package:linux:x86
rake package:linux:x86_64
```

When the task finishes you will find your packages in Dradis root as tar.gz files.

Note that you need to run this with ruby 2.1. Since Dradis uses 1.9.3 right now, you will probably want to set up a `.rvmrc` or `.ruby-version` file in this directory and use a separate gemset.
