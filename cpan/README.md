# README

This directory contains the `Makefile` for creating a CPAN
distribution of this project.

Note that you can only create a distribution of this project AFTER
installing the project.

First make and install the project as standalone utility which will
install it in the _usual_ places.

```
./bootstrap
./configure
make && sudo make install
cd cpan
make cpan
```

Now you should have a tarball that can be installed as a Perl
distribution.  You may want to first uninstall the project from the
_usual_ places.

```
cd ..
sudo make uninstall
cd cpan
cpanm -v CPAN-Maker-1.5.40.tar.gz
```

