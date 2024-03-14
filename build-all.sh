#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

TIMESTAMP=$(date +'%Y%m%d-%H%M')
cd fedora-kinoite
podman build -t registry.msi.heyste.nz/kinoite:$TIMESTAMP -f Containerfile .
podman push registry.msi.heyste.nz/kinoite:$TIMESTAMP
podman images | grep $TIMESTAMP
cd -

ISO_TMPDIR=$(mktemp -d /tmp/iso-$TIMESTAMP-XXXX)
echo $ISO_TMPDIR
cd $ISO_TMPDIR

FLATPAK_SONIC_PI="app/net.sonic_pi.SonicPi/x86_64/stable runtime/org.kde.Platform/x86_64/5.15-23.08"
FLATPAK_ECLIPSE="app/org.eclipse.Java/x86_64/stable runtime/org.gnome.Platform/x86_64/45"

sudo podman run --rm --privileged \
                --volume .:/github/workspace/build \
		docker.io/heyste/build-container-installer:latest \
		VERSION=39  \
		IMAGE_REPO=registry.msi.heyste.nz \
		IMAGE_NAME=kinoite \
		IMAGE_TAG=$TIMESTAMP \
		VARIANT=Server \
		FLATPAK_REMOTE_REFS="$FLATPAK_ECLIPSE $FLATPAK_SONIC_PI" \
		FLATPAK_REMOTE_URL="https://flathub.org/repo/flathub.flatpakrepo"

echo $ISO_TMPDIR
ls -lh $ISO_TMPDIR
