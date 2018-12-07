SUBDIRScd = .

include $(top_srcdir)/directories.inc

perlrun = @PERL@

if RPM_BUILD_MODE
perlwc = \# 
else
perlwc = @PERL@
endif

# you should be using perl5libdir as the base target of your perl
# modules, not as simply part of your PERLINCLUDE
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@
ax_perl5_extra_includes = @ax_perl5_extra_includes@

# this is where we will install perl scripts
libexecdir = @libexecdir@

PERLSCRIPTS = \
    make-cpan-dist.pl.in

GPERLSCRIPTS = $(PERLSCRIPTS:.pl.in=.pl)
G1MANPAGES = $(GPERLSCRIPTS:.pl=.1man)

libexec_SCRIPTS = $(GPERLSCRIPTS)
dist_noinst_DATA = $(PERLSCRIPTS)

man1_MANS = $(G1MANPAGES)

@do_subst_command@

#
# A NOTE ABOUT `PERLINCLUDE'
# --------------------------
#
# In most cases you'll want to use a -I "somepath" when compiling the
# perl script (perl -wc $@) to make sure the perl scripts or modules
# you are building can find the necessary modules you are using in the
# script. You'll note below that this template includes 3 default
# include paths.
# 
# YMMV, depending upon your build tree and other factors, however you
# should not be tricked into assuming your build is working when you
# are in fact using include paths OUTSIDE your build tree and you have
# previously installed the package you are building!
#
# Additionally, you should be aware of the difference between
# $(srcdir) and $(builddir) as they relate to VPATH builds when doing
# `make distcheck'
#
# You will also note that $(perl5libdir) is LAST in this order to
# further insulate you from being duped into thinking that you are
# using the newly built perl modules when in fact you might be
# using those already installed.
# 
# Note further that $(builddir)../lib is included as a perl include path on the
# assumption that your project most likely (but not always) builds
# perl modules as well.
#
# Lastly, the order of the build is therefore important.  You'll want
# to build the src/main/perl/lib first, so these perl modules are
# available to you as you build your perl scripts.  Accordingly,
# src/main/perl/Makefile.am is told to recurse the directories as
# follows:
#
# SUBDIRS = . lib bin
# 
# Laying out your build tree is not a mindless task and you should
# consider the intradependencies of the components within the project
# when making those decisions.   Of course, it's not rocket science
# either. ;-)
# 

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

PERLINCLUDE = \
    -I $(builddir) \
    -I $(builddir)/../lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

$(GPERLSCRIPTS): % : %.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) $(PERLINCLUDE) -wc $@ || { rm $@ && exit 1; }

all:

CLEANFILES = $(GPERLSCRIPTS) $(G1MANPAGES)

$(G1MANPAGES): %.1man : %.pl
	target_name="$@" ;\
	tname=$$(echo "$${target_name}" | sed -e 's/\.1man$$//') ;\
	"$(POD2MAN)" $< \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=1man > "$${target_name}"

.PHONY: clean-local
clean-local:
	$(MAKE) clean-generated-man-pages


.PHONY: clean-generated-man-pages
clean-generated-man-pages:
	for mpath in $(G1MANPAGES); do \
	rm -f "$${mpath}" ;\
	test $$? -eq 0 || exit 1 ;\
	done

if DISTCHECK_HACK
else
endif

if RPM_BUILD_MODE
else
install-data-hook:
endif
