MAKE_CPAN_DIST = make-cpan-dist.pl

DISTRIBUTION = File-Process

goals = t lib/File/Process.pm cpan

.phony: upload

all: $(goals)
	$(MAKE) $(filter t, lib/File, $(goals))
	$(MAKE) cpan

lib/File/Process.pm:
	test -d lib/File || mkdir -p lib/File; \
	if ! test -e ../src/main/perl/lib/File/Process.pm; then \
	   cd ..; \
	  $(MAKE); \
	  cd -; \
	fi; \
	cp  ../src/main/perl/lib/File/Process.pm lib/File/Process.pm

t:
	test -d t || ln -sf ../src/main/perl/lib/t

export MODULE_LIST = $(shell find -L lib -type f -name '*.pm')

export VERSION = $(shell perl -I lib -MFile::Process -e 'print "$$File::Process::VERSION";' )

TARBALL = File-Process-$(VERSION).tar.gz

cpan: $(TARBALL) lib/File/Process.pm
	echo $(TARBALL)

BUILDSPEC = buildspec.yml

$(TARBALL): buildspec.yml $(MODULE_LIST) test-requires requires
	set -x;
	$(MAKE_CPAN_DIST) -b $<

clean:
	rm -f *.tar.gz

upload: $(TARBALL)
	export PAUSE_USER=BIGFOOT; \
	export EMAIL=bigfoot@cpan.org; \
	bash -c /usr/local/bin/upload2cpan $(TARBALL)


