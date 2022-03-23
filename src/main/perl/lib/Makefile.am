SUBDIRS = .

include $(top_srcdir)/directories.inc

perlrun = @ENV@ @PERL@

perlwc = @ENV@ @PERL@

# you should be using perl5libdir as the base target of your perl
# modules, not as simply part of your PERLINCLUDE
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@
ax_perl5_extra_includes = @ax_perl5_extra_includes@

PERLMODULES = \
    File/Process.pm.in

GPERLMODULES = $(PERLMODULES:.pm.in=.pm)
G3MANPAGES = $(GPERLSCRIPTS:.pm=.3man)

filedir = $(perl5libdir)/File
file_DATA = $(GPERLMODULES)

dist_noinst_DATA = $(PERLMODULES)

man3_MANS = $(G3MANPAGES)

@do_subst_command@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

# Please see the notes concerning PERLINCLUDE in the ../bin/Makefile.am file
PERLINCLUDE = \
    -I $(builddir) \
    -I $(builddir)/../lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

$(GPERLMODULES): % : %.in 
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) $(PERLINCLUDE) -wc $@ || { rm $@ && exit 1; }

all:

CLEANFILES = $(GPERLMODULES)

$(G3MANPAGES): %.3man : %.pm
	set -x; \
	target_name="$@"; \
	echo $$target_name; \
	tname=$$(echo "$${target_name}" | sed -e 's/\.3man$$//') ;\
	"$(POD2MAN)"  \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=3man $< "$${target_name}" || touch "$${target_name}"

.PHONY: clean-local
clean-local:
	$(MAKE) clean-generated-man-pages

.PHONY: clean-generated-man-pages
clean-generated-man-pages:
	for f in *.3man; do \
	  echo "$$f"; \
	  rm -f "$$f" ;\
	done

install-data-hook:
	for a in $(G3MANPAGES); do \
	  target_name=$$(echo "$$a" | sed -e 's/\//::/g'); \
	  mv $(DESTDIR)$(mandir)/man3/$$(basename $$a) \
	     $(DESTDIR)$(mandir)/man3/$${target_name}; \
	done

uninstall-local:
	for a in $(G3MANPAGES); do \
	  target_name=$$(echo "$$a" | sed -e 's/\//::/g'); \
	  rm -f $(DESTDIR)$(mandir)/man3/$${target_name}; \
	done
