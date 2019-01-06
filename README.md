# README

This project is yet another attempt to create a repeatable, __easy to
use__ script for creating CPAN distributions.

Typically, because I use the Redhat Package Manager to create Perl
modules that can be installed as part of my application stacks, I
don't bother with the creation of CPAN distributions.

In order to possibly share some of these modules (or some might say
inflict them on an unwary public ;-) ) and to use a more modern Perl
toolchain (`cpanm`) to vendor libraries for use with AWS Lambdas, I've
recently needed a quick and easy CPAN distribution creation utility.
Hence this project.

After installing the project you'll find more information by reading the man page.

```
man cpan-dist
```

# The Goal

The goal is to take a set of Perl modules and possibly (hopefully)
tests and _automatically_ create a CPAN distribution.  The _automatic_
part is key, as I'd like this to simply be the tail end of a CI/CD
pipeline for various projects.

To be clear, __this is not a comprehensive CPAN distribution creation
utility__ and almost certainly will not work for more complex Perl
modules.  It does the basics, and just the basics to create a CPAN tar
ball.  If you have one or more Perl modules that need to get packaged
up as part of a namespace you own, then this _might_ work for you.  If
your needs are more complex, then this will probably fall short.

If so, _and you are so inclined_, I'd appreciate an issue being opened
to let me know why and possibly how I might add new features to make
it more applicable to a wider set of scenarios.  As the kids say,
_pull requests are welcome too_.

# Why is this easier than just building a `Makefile.PL` and doing the normal dance?

Well, to be upfront about it, __maybe it's not__. Personally, I like
to take a bunch of steps I seldom will remember and package them in
self-contained utilities so that processes can be automated and
forgotten about. I guess this this approach works for me, but as
always YMMV. As I mentioned, I'm also using this utility as a
component of a CI/CD pipeline.

If after looking at this project you are shaking your head and wagging
your finger, then count yourself among those who have opined that I
tend to take something simple and make it complicated.  OTOH, most
things really are complicated if you are patient and perhaps
persistent enough to peel the onion.  TIMTOWTDI though.

If your needs are basic and you don't mind manually adding
dependencies to your `Makefile.PL` then you might find this utility
overkill at best and completely unnecessary at worst.  I've
nonetheless found it useful, especially as a way to quickly update the
dependency list and version numbers for both the Perl modules I am
packaging and the tests that go along with the distribution.  Did I
mention I'm using this as part of a CI/CD pipeline?

# Quick Start

## Installation

Make sure you have the `autotools` toolchain installed. If you are
using a RedHat derived Linux distribution, install the `autoconf`
package using `yum`. If you are using a Debian based system then you
may have success using `apt` to install the necessary dependencies.

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

## Why did you _autoconfiscate_ a project that has just 1 Perl script and 1 bash script?

Before we go any further, I'll bet I need to answer that question.  So, in no particular order...

* Habit
* Automation malleability
* Familiarity with the toolchain
* Standardization of my development process
* Flexibility to add more automation with `make` as a project organically matures
* Ubiquity of the toolchain
* Potential portability (nothing is 100% portable, but we can try)

...automate, automate, automate...so you can do something like this
after creating automation scripts that create CPAN distribution files:

```
SUBDIRS = .

CPAN_DIST_MAKER=/usr/local/libexec/make-cpan-dist.pl

cpan: buildspec.yml
        $(CPAN_DIST_MAKER) -b $<

.PHONY: cpan

clean-local:
        rm -f *.tar.gz
```
...and then of course:

```
make cpan
```

I also leverage _autoconfiscation_ templates to create things like man
pages from Perl scripts and of course the installation process is made
simpler when you can rely on some degree of portability and
standardization of your toolchain. Many disagree and hate `autoconf` -
I get it - but it's not a holy war.

## Perl Dependencies

To use these scripts you'll also need a way to _resolve Perl module
dependencies_.  The script will use, by default, Red Hat's utility
that is bundled in its `rpm-build` package (`/usr/lib/rpm/perl.req`).
I find that this utility does a fairly good job of figuring out the
__direct__ dependencies.  In fact, it does a much better job than
`scandeps.pl` or any of the other dependency resolvers you might
stumble across.  That's not to say that it is fool proof or even a
good dependency checker for Perl.  That is a subject of a long blog
post I think I should write some day.

If you are running on a Debian based system you can grab
`/usr/lib/rpm/perl.req` from the `rpm` package apparently.

If you don't have access to that utility, but have another favorite
Perl module dependency resolver (don't we all?) then you can use that
by providing it on the command line (-r) of the bash helper script
(`make-cpan-dist`). The function you specify should simply provide a
list of Perl modules one per line and output that to STDOUT.

You can also use `scandeps.pl` by specifying the -s option to the
helper script.

```
make-cpan-dist -a 'Rob Lauer <rlauer6@comcast.net>' \
   -m MyFunc -R no -l . -d "my function" \
   -s
```

...or try `Devel::Modlist` which will give about the same results as `scandeps.pl`

Create a bash function...`dep_resolver`?...then give it a go.

```
cat <<eof > dep_resolver
#!/bin/bash

perl -MDevel::Modlist=nocore \$1.pm 2>&1 | awk '{ print \$1}'
eof
chmod +x dep_resolver
make-cpan-dist -a 'Rob Lauer <rlauer6@comcast.net>' \
   -m MyFunc -R no -l . -d "my function" \
   -r dep_resolver
```

## What Next?

After successfully building and installing the project you will have
available two utilities that are used together to build a CPAN
distribution.

* `/usr/local/bin/make-cpan-dist`
* `/usr/local/libexec/make-cpan-dist.pl`

## Creating a CPAN Distribution

There are at least three possible ways to create a CPAN distribution
using the utiities contained in this project, each with varying
degrees of simplicity and flexibility.  As a reminder, the point of
these utilities is to provide a __simple__ solution right?  So the
_simplest_ thing you can do is run the utility against a `buildspec.yml`
file that describes the distribution you would like to create.  See
below...

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
`pm_module`, `author`, `pm_module` and `path` attributes.

The `path` attributes specify the path to the module and the path to
the tests which will be packaged. All files with an extension of `.t`
are assumed to be included in the package if you have specified a test
path.  If your project includes other Perl modules somewhere in the
Perl module path then they will be packaged as well.  Paths are relative
to the root of the project or your current working directory if you
are not specifying a git repository as the source of your
package.

So, assuming you have created an appropriate
`buildspec.yml` file, the easy way boils down to this:

```
/usr/local/libexec/make-cpan-dist.pl -b buildspec.yml
```

After executing that statement, you should have a tar ball in your
current working directory. WooHoo!

#### Advanced Options

The YAML `buildspec.yml` file can contain some additional options to
control what and how things get packaged.

* use the `recurse` option to add additional Perl modules from your project path.

   If you want to add additional Perl modules to the distribution,
   just make sure they are under the directory path of your core
   module and the `recurse` option is set to `yes`.
   
   ```
   path:
     recurse: yes
   ```

* to use a different module dependency checker than the default
  (`/usr/lib/rpm/perl.req`) set the `resolver` option under the
  `dependencies` section. A value of `scandeps` will use `scandeps.pl`
  or set the name of an executable that will simply output
  a list of Perl module names.

   ```
   dependencies:
     resolver: scandeps
   ```

* to manually specify a list of dependencies, set the `path` option under the
  `dependencies` section to the path to a file that contains a list of
  Perl modules. If the name of the file is `cpanfile` then it is
  assumed to be a `cpanfile` formatted list, otherwise the list should
  be a simple listing of module names.
  
### The Harder Way

A slighly harder way is to call the helper bash script directly with
specific options to create the distribution.

```
usage: make-cpan-dist Options

Utility to create a CPAN distribution

Options
-------
-a author      - author (ex: Anonymouse <anonymouse@example.org>)
-d description - description to be included CPAN
-D file        - use file as the dependency list
-h             - help
-f file        - file containing a list of extra files to include
-l path        - path to Perl modules
-m name        - module name
-o dir         - output directory (default: current directory)
-p             - preserve Makefile.PL
-P file        - file that contains a list of modules to be packaged
-r pgm         - script or program to list dependencies
-s             - use scandeps.pl to find dependncies
-R yes/no      - recurse directories for files to package (default: yes)
-t path        - path to test files
-v             - more verbose output
-x do not cleanup files

NOCLEANUP=1, PRESERVE_MAKEFILE=1 can also be passed as environment variables.
```

Example:

Assume my source tree looks something like this:

```
.
├── lib
│   └── Foo
│       └── Bar.pm
└── t
```

...then go ahead and give this a try:

```
/usr/local/bin/make-cpan-dist -m Amazon::Credentials \
   -a 'Rob Lauer <rlauer6@comcast.net>' \
   -d 'AWS credential discoverer' \
   -t t
   -l lib
```

So far, neither of these methods is particularly hard and can be used
interchangeably as part of you deployment pipeline.  The key to the
"easiness" part, at least for me, is the fact that the bash script
will try to resolve dependencies using the helper from the `rpm-build`
project (`/usr/lib/rpm/perl.req`) and find the Perl module version for
each of those dependencies.  The __dependency resolver is not
perfect__, specifically it may get tripped up on some ways your clever
Perl module utilizes other resources.  In general though, _it's good
enough_, however you can always ask the script to preserve (-p) the
`Makefile.PL` that is generated and start tweaking that yourself. You
could also open an issue and I'll try to tackle it. You could also
make a pull request. ;-)

### The Hardest Way

The hardest way to create a CPAN distribution using this utility is to
provide a file that contains the dependencies for your module by
creating one yourself.  As long as we are doing things the hard way,
create another dependency file for the tests you have included and
then invoke the Perl script directly by providing all of the necessary
options.

Provide a file named `requires` that lists the dependencie and their
versions and a file named `tests-require` if you have tests that
require additional modules.

```
Amazon::Signature4,1.02
```

Of course, at this point you might as well just create your own
`Makefile.PL` I guess...OTOH hand if you are big on automation (you
should be) and creating `make` files (what? nobody uses `make`
anymore?) then put your dependency files under source control and make
them dependencies for your `make` rules.  ;-)

So, just to be transparent, the bash helper script does the following,
all of which you can of course do manually to create your dependency
list.

1. iterate over all of the .pm files in your source tree
   1. run `/usr/lib/rpm/perl.req` and save the output
1. sort the list and get the unique dependencies
1. iterate over the sorted list
   1. get the version number of each module
   1. save the module and version number to the dependency file
1. repeat for each test (*.t) in the test directory

The result of the above operation is the two files (`requires`,
`test-requires`) you'll need to provide to the script.  The contents
of the files are then used to populate the template for the
`Makefile.PL` program generated in the Perl script
`make-cpan-dist.pl`.

# Finally

I hope you find this useful. If I can make it more useful, let me know.

# Author

Rob Lauer  <rlauer6@comcast.net>
