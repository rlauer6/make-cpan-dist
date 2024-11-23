SUBDIRS = . src

MDUTILS = @MDUTILS@

ACLOCAL_AMFLAGS = -I autotools

README.md: README.md.in
	$(MDUTILS) $< > $@

dist_noinst_DATA = \
    ChangeLog \
    README.md.in \
    README.md
