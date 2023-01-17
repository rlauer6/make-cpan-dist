MAKE_CPAN_DIST = make-cpan-dist.pl

DISTRIBUTION = File-Process

goals = t lib/File cpan

.phony: upload

all: $(goals)
	$(MAKE) $(filter t, lib/File, $(goals))
	$(MAKE) cpan

lib/File:
	test -d lib || mkdir lib; \
	cd lib; \
	ln -sf ../../src/main/perl/lib/File File

t:
	test -d t || ln -sf ../src/main/perl/lib/t

export MODULE_LIST = $(shell find -L lib -type f -name '*.pm')

export VERSION = $(shell perl -I lib -MFile::Process -e 'print "$$File::Process::VERSION";' )

TARBALL = File-Process-$(VERSION).tar.gz

cpan: $(TARBALL)
	echo $(TARBALL)

BUILDSPEC = buildspec.yml

$(TARBALL): buildspec.yml $(MODULE_LIST)
	set -x;
	$(MAKE_CPAN_DIST) -b $<

clean:
	rm -f $(TARBALL)

upload: $(TARBALL)
	export PAUSE_USER=BIGFOOT; \
	export EMAIL=bigfoot@cpan.org; \
	bash -c /usr/local/bin/upload2cpan $(TARBALL)


