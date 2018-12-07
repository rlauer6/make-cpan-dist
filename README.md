# README

This project is yet another attempt to create a repeatable, __easy to
use__ script for creating CPAN distributions.

Typically, because I use the Redhat Package Manager to create Perl
modules that can be installed as part of my application stacks, I
don't bother with the creation of CPAN distributions.

In order to possibly share some of these modules (or some might say
inflict them on an unwary public ;-) ) and to use a more modern Perl
toolchain (`cpanm`) to vendor libraries for use with AWS Lambdas, I've
recently needed a quick and easy CPAN distribution creation utility.  Hence
this project.

# The Goal

The goal is to take a set of Perl modules and possibly (hopefully)
tests and create a CPAN distribution.

To be clear, __this is not a comprehensive CPAN distribution creation
utility__.  It does the basics, and just the basics to create a CPAN
tar ball.  If you have one or more Perl modules that need to get
packaged up as part of a namespace you own, then this _might_ work for
you.  If your needs are more complex, then this will probably fall
short.  If so, and you are so inclined, I'd appreciate an issue being
opened to let me know why and possibly how I might add new features to
make it more applicable to a wider set of scenarios.  As the kids say,
_pull requests are welcome too_.

# Why is this easier than just building a `Makefile.PL` and doing the normal dance?

Well, maybe it's not. Personally, I like to take a bunch of steps I
seldom will remember and package them in self-contained utilities, so
this approach works for me. YMMV.

If your needs are basic and you don't mind manually adding
dependencies to your `Makefile.PL` then you might find this utility
overkill.  I've nonetheless found it useful, especially as a way to
quickly update the dependency list and version numbers for both the
Perl modules I am packaging and the tests that go along with the
distribution.

# Quick Start

## Installation

_Make sure you have the `autotools` tool chain installed. If you are
using a RedHat derived Linux distribution, install the `autoconf`
package using `yum`. If you are using a Debian based system then you
may have success using `apt` to install the project. This may not be
important to you but the project won't be able to use the project to
create a Debian package as it only supports creation of an rpm. You
should still be able to build and install the utility from source._

```
yum install -y autoconf
git clone https://github.com/rlauer6/make-cpan-dist.git .
autoreconf -i --force
./configure
make & sudo make install
```

_Hint: If you want to install locally, set `--prefix` during the
configure process._

```
./configure --prefix=$HOME/local
make && make install
```

## What did that just do?

After successfully building and installing the project you will have
available two utilities that are used together to build a CPAN
distribution.

* `/usr/local/bin/make-cpan-dist`
* `/usr/local/libexec/make-cpan-dist.pl`

## Creating a CPAN Distribution

There are at least three possible ways to create a CPAN distribution
using the utiities contained in this project, each with varying
degrees of simplicity and flexibility.  The point of the utilties
again, was to provide a simple mechanism right?  So the simplest thing
you can do is run the utility against a `buildspec.yml` file that
describes the distribution you would like to create.  See below...

### The Easy Way

Create a `buildspec.yml` file that looks something like this:

```
project:
  git: https://github.com/rlauer6/perl-Amazon-Credentials.git 
  description: "AWS credentials discoverer"
  author:
    name: Rob Lauer
    mailto: rlauer6@comcast.net
pm_module: Amazon::Credentials
path:
  pm_module: src/main/perl/lib
  tests: src/main/perl/t
```

You specify some project metadata and possibly a pointer to the
project in a git repository that can be cloned.  You must provide the
`pm_module`, `author`, and the `pm_module` and `path` attributes.

The `path` attributes specify the path to the module and the path to
the tests which will be packaged. All files with an extension of `.t`
are assumed to be included in the package.  If your project includes
other Perl modules then they will packaged as well.  Paths are
relative to the root of the project or your current working directory
if you are not specifying a git repository as the source of your
package.

There is no (current) way to include any other files in the
distribution.  So, assuming you have created an appropriate
`buildspec.yml` file, the easy way boils down to this:

```
/usr/local/libexec/make-cpan-dist.pl -b buildspec.yml
```
After executing that statement, you should have a tar ball in your
current working directory.

### The Harder Way

You can also call a bash script directly with specific options to
create the distribution.

```
usage: make-cpan-dist Options

Utility to create a CPAN distribution

Options
-------
-a author
-d description
-h help
-l path to Perl modules
-m module name
-o output directory (default: current directory)
-p preserve Makefile.PL
-r function to list dependencies
-t path to test files
-v more verbose output
-x do not cleanup files

NOCLEANUP=1, PRESERVE_MAKEFILE=1 can also be passed as environment variables.
```

Example:

```
/usr/local/bin/make-cpan-dist -m Amazon::Credentials \
   -a 'Rob Lauer <rlauer6@comcast.net>' \
   -d 'AWS credential discoverer' \
   -t t
   -l lib
```

So far, neither of these methods is particularly hard and can be used
interchangeably as part of you deployment pipeline.  The key to the
"easiness" for me at least, is the fact that the bash script will try
to resolve dependencies using a helper from the `rpm-build` project
(`/usr/lib/rpm/perl.req`).  The dependency resolver is not perfect,
specifically it may get tripped up on some ways your Perl module
utilizes other resources.  In general though, it's good enough.

You can always ask the script to preserve (-p) the `Makefile.PL` that is
generated and start tweaking that yourself.

### The Hardest Way

The hardest way is to provide a file that contains the dependencies
for your module and any tests you have include and completely specify
the options to the `make-cpan-dist.pl` program in all there blood
glory. Provide a file named `requires` that lists the dependencie and
their versions and a file named `tests-require` if you have tests that
require additional modules.  Of course, at this point you might as
well just create your own `Makefile.PL` I guess...

So, just to be transparent, the bash helper script does the following
that you could do manually to create your dependency list.

1. iterate over all of the .pm files in your source tree
  1. run `/usr/lib/rpm/perl.req` and save the output
1. sort the list and get the unique dependencies
1. iterate over the sorted list
  1. get the version number of each module
  1. save the module and verion number to the dependency file
1. repeat for each test (*.t) in the test directory

The result of the above operation is two files (`requires`,
`test-requires`) that are used to populate the template of the
`Makefile.PL` program generated in the Perl script
`make-cpan-dist.pl`.

### Even Harder?

# Author

Rob Lauer  <rlauer6@comcast.net>
