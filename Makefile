COMMIT = $(shell (cd "$(SRCDIR)" && git rev-parse HEAD))

# Ensure "install" isn't the default
.PHONY: all
all:
	@echo "Usage: make install [DESTDIR=...]"
	@exit 1

.PHONY: install
install:
	install -D -m 0644 -t $(DESTDIR)/usr/lib/dracut/modules.d/35ignition-edge \
		dracut/35ignition-edge/coreos-enable-network.service \
		dracut/35ignition-edge/coreos-teardown-initramfs.service \
		dracut/35ignition-edge/ignition-ostree-mount-var.service \
		dracut/35ignition-edge/ignition-setup-user.service
	install -D -m 0755 -t $(DESTDIR)/usr/lib/dracut/modules.d/35ignition-edge \
		dracut/35ignition-edge/module-setup.sh \
		dracut/35ignition-edge/coreos-enable-network.sh \
		dracut/35ignition-edge/coreos-teardown-initramfs.sh \
		dracut/35ignition-edge/ignition-ostree-mount-var.sh \
		dracut/35ignition-edge/ignition-setup-user.sh
	install -D -m 0644 -t $(DESTDIR)/usr/lib/systemd/system systemd/ignition-firstboot-complete.service


RPM_SPECFILE=rpmbuild/SPECS/ignition-edge-$(COMMIT).spec
RPM_TARBALL=rpmbuild/SOURCES/ignition-edge-$(COMMIT).tar.gz

$(RPM_SPECFILE):
	mkdir -p $(CURDIR)/rpmbuild/SPECS
	(echo "%global commit $(COMMIT)"; git show HEAD:ignition-edge.spec) > $(RPM_SPECFILE)

$(RPM_TARBALL):
	mkdir -p $(CURDIR)/rpmbuild/SOURCES
	git archive --prefix=ignition-edge-$(COMMIT)/ --format=tar.gz HEAD > $(RPM_TARBALL)

.PHONY: srpm
srpm: $(RPM_SPECFILE) $(RPM_TARBALL)
	rpmbuild -bs \
		--define "_topdir $(CURDIR)/rpmbuild" \
		$(RPM_SPECFILE)

.PHONY: rpm
rpm: $(RPM_SPECFILE) $(RPM_TARBALL)
	rpmbuild -bb \
		--define "_topdir $(CURDIR)/rpmbuild" \
		$(RPM_SPECFILE)
