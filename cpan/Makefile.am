SUBDIRS = .

CPAN_DIST_MAKER=make-cpan-dist.pl

package_version=@PACKAGE_VERSION@
package=@PACKAGE@

# builds the distribution tarball and renames based on package version
cpan: buildspec.yml
	cd $(top_srcdir); \
	$(MAKE)

	test -n "$$DEBUG" && set -x; \
	test -n "$$DEBUG" && DEBUG="--debug"; \
	test -e requires && REQUIRES="-r requires"; \
	test -n "$(NOCLEANUP)" && NOCLEANUP="--no-cleanup"; \
	test -n "$(DRYRUN)" && DRYRUN="--dryrun"; \
	test -n "$(SCANDEPS)" && SCANDEPS="-s"; \
	test -n "$(NOVERSION)" && NOVERSION="-n"; \
	PROJECT_ROOT="--project-root $$(readlink -f ..)"; \
	$(CPAN_DIST_MAKER) $$PROJECT_ROOT $$REQUIRES $$DRYRUN \
	   $$SCANDEPS $$NOVERSION $$NOCLEANUP $$DEBUG -b $< || false

# handle n.m.r-b version format (but don't use this anymore!)
	if test -n "$$(echo $(package_version) | grep '\-')"; then \
		echo $$package_version; \
		package_version=$(package_version); package=$(package); \
		tarball=$${package##perl-}-$${package_version%%-*}.tar.gz; \
		test -e "$$tarball" && mv $$tarball $${package##perl-}-$$package_version.tar.gz; \
	fi

.PHONY: cpan

CLEANFILES = \
    extra-files \
    provides \
    resources 

clean-local:
	for a in $(CLEANFILES); do \
	  rm -f $$a || true; \
	done
	rm -f *.tar.gz
	rm -f *.tmp
	find . -maxdepth 1 -name 'CPAN-Maker*' -type d -exec rm -rf {} \;

