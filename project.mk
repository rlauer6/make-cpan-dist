#-*- mode: gnumakefile; -*-

.PHONY: install
install: $(TARBALL)
	cpanm -n -v -l $(HOME) $<
