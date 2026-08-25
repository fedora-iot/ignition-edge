#!/bin/bash
set -euo pipefail

set +euo pipefail
. /usr/lib/dracut-lib.sh
set -euo pipefail

dracut_func() {
    # dracut is not friendly to set -eu
    set +euo pipefail
    "$@"; local rc=$?
    set -euo pipefail
    return $rc
}

# If networking hasn't been requested yet, request it.
if ! dracut_func getargbool 0 'rd.neednet'; then
    echo "rd.neednet=1" > /etc/cmdline.d/40-coreos-neednet.conf

    # Hack: we need to rerun the NM cmdline hook because we run after
    # dracut-cmdline.service because we need udev. We should be able to move
    # away from this once we run NM as a systemd unit. See also:
    # https://github.com/coreos/fedora-coreos-config/pull/346#discussion_r409843428
    set +euo pipefail
    # dracut 110+ removed compatibility symlink at /usr/lib; check both locations
    if [ -f /var/lib/dracut/hooks/cmdline/99-nm-config.sh ]; then
        . /var/lib/dracut/hooks/cmdline/99-nm-config.sh
    elif [ -f /usr/lib/dracut/hooks/cmdline/99-nm-config.sh ]; then
        . /usr/lib/dracut/hooks/cmdline/99-nm-config.sh
    else
        echo "Error: 99-nm-config.sh hook not found" >&2
    fi
    set -euo pipefail
fi
