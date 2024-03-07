#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

TIMESTAMP=$(date +'%Y%m%d-%H%M')
cd fedora-kinoite
docker build -t registry.msi.heyste.nz/kinoite:$TIMESTAMP -f Containerfile .
docker push registry.msi.heyste.nz/kinoite:$TIMESTAMP
cd -

ISO_TMPDIR=$(mktemp -d /tmp/iso-$TIMESTAMP-XXXX)
echo $ISO_TMPDIR
cd $ISO_TMPDIR

docker images | grep $TIMESTAMP

docker run --rm --privileged \
           --volume .:/isogenerator/output \
           --add-host registry.msi.heyste.nz:192.168.111.202 \
           -e VERSION=39 \
           -e IMAGE_REPO=registry.msi.heyste.nz \
           -e IMAGE_NAME=kinoite \
           -e IMAGE_TAG=$TIMESTAMP \
           -e VARIANT=Kinoite \
           ghcr.io/ublue-os/isogenerator:39

echo $ISO_TMPDIR
ls -lh $ISO_TMPDIR
