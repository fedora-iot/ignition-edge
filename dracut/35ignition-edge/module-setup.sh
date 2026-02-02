#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

depends() {
    echo systemd network fips ignition
}

install_ignition_unit() {
    local unit="$1"; shift
    local target="${1:-ignition-complete.target}"; shift
    local instantiated="${1:-$unit}"; shift
    inst_simple "$moddir/$unit" "$systemdsystemunitdir/$unit"
    # note we `|| exit 1` here so we error out if e.g. the units are missing
    # see https://github.com/coreos/fedora-coreos-config/issues/799
    systemctl -q --root="$initdir" add-requires "$target" "$instantiated" || exit 1
}

install() {
    inst_multiple \
        basename \
        diff \
        lsblk \
        sed \
        grep \
        realpath \
        sgdisk \
        setfiles

    inst_simple "$moddir/ignition-edge-generator" \
        "$systemdutildir/system-generators/ignition-edge-generator"

    inst_script "$moddir/ignition-setup-user.sh" \
        "/usr/sbin/ignition-setup-user"
    install_ignition_unit ignition-setup-user.service

    inst_script "$moddir/coreos-relabel" \
        "/usr/sbin/coreos-relabel"

    inst_script "$moddir/coreos-teardown-initramfs.sh" \
        "/usr/sbin/coreos-teardown-initramfs"
    install_ignition_unit coreos-teardown-initramfs.service

    # for x in mount populate; do
    for x in mount; do
        install_ignition_unit ignition-ostree-${x}-var.service
        inst_script "$moddir/ignition-ostree-${x}-var.sh" "/usr/sbin/ignition-ostree-${x}-var"
    done

    inst_simple "$moddir/coreos-enable-network.sh" \
        "/usr/sbin/coreos-enable-network"
    install_ignition_unit "coreos-enable-network.service"
}
