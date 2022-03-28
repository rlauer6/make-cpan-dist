SUBDIRS = . 

perlrun = @ENV@ perl
bashrun = @BASHRUN@
perlenv = @ENV@ perl
scandeps = @SCANDEPS@

BASHSCRIPTS = \
    make-cpan-dist.in \
    upload2cpan

GBASHSCRIPTS = $(BASHSCRIPTS:.in=)

libexec_SCRIPTS = $(GBASHSCRIPTS)
bin_SCRIPTS = $(GBASHSCRIPTS)

dist_noinst_DATA = $(BASHSCRIPTS)

@do_subst_command@

$(GBASHSCRIPTS): % : %.in
	$(do_subst) $< > $@

CLEANFILES = $(GBASHSCRIPTS)
