%define dracutlibdir %{_prefix}/lib/dracut
%global         forgeurl https://github.com/fedora-iot/ignition-edge
%global debug_package %{nil}

Version:        99

%forgemeta -v -i

Name:           ignition-edge

Release:        1%{?dist}
Summary:        Ignition glue for the edge

# Upstream license specification: Apache-2.0
License:        ASL 2.0

URL:            %{forgeurl}

Source0:        %{forgesource}

BuildRequires: systemd

%global _description %{expand:
dracut module and firstboot systemd services
}

%description %{_description}

%prep
%forgesetup

%build

%install
%make_install

%files
%{dracutlibdir}/modules.d/35ignition-edge
%{dracutlibdir}/modules.d/10coreos-sysctl
%{dracutlibdir}/modules.d/99emergency-shell-setup
%{dracutlibdir}/modules.d/99journal-conf
%{_unitdir}/ignition-firstboot-complete.service

%post
%systemd_post ignition-firstboot-complete.service

%preun
%systemd_preun ignition-firstboot-complete.service

%postun
%systemd_postun_with_restart ignition-firstboot-complete.service

%changelog
# let's skip this for now
