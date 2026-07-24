#-*- mode: gnumakefile; -*-

.PHONY: install
install: $(TARBALL)
	cpanm -l $(HOME) $<
