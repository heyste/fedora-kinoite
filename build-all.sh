#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo "REGISTRY: ${REGISTRY}"
IMAGE_NAME=${IMAGE_NAME:-kinoite}
echo "IMAGE_NAME: ${IMAGE_NAME}"
IMAGE_TAG=$(date +'%Y%m%d-%H%M')
echo "IMAGE_TAG: ${IMAGE_TAG}"

cd fedora-kinoite
podman build -t ${REGISTRY}/${IMAGE_NAME}:$IMAGE_TAG -f Containerfile .
podman push ${REGISTRY}/${IMAGE_NAME}:$IMAGE_TAG
podman images | grep $IMAGE_TAG
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
		IMAGE_REPO=${REGISTRY} \
		IMAGE_NAME=${IMAGE_NAME} \
		IMAGE_TAG=${IMAGE_TAG} \
		VARIANT=Server \
		FLATPAK_REMOTE_REFS="$FLATPAK_ECLIPSE $FLATPAK_SONIC_PI" \
		FLATPAK_REMOTE_URL="https://flathub.org/repo/flathub.flatpakrepo"

echo $ISO_TMPDIR
ls -lh $ISO_TMPDIR
