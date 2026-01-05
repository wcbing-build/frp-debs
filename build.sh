#!/bin/sh
set -e

# Check and extract version number
[ $# != 1 ] && echo "Usage:  $0 <latest_releases_tag>" && exit 1
VERSION=$(echo "$1" | sed -n 's|[^0-9]*\([^_]*\).*|\1|p') && test "$VERSION"

# PACKAGE=frp
REPO=fatedier/frp

ARCH_LIST="amd64 arm64"
AMD64_FILENAME=frp_"$VERSION"_linux_amd64.tar.gz
ARM64_FILENAME=frp_"$VERSION"_linux_arm64.tar.gz

prepare() {
    mkdir -p output tmp
    curl -fs https://api.github.com/repos/$REPO/releases/latest | jq -r '.body' | gzip > tmp/changelog.gz
}

build() {
    BASE_DIR="$PACKAGE"_"$ARCH" && rm -rf "$BASE_DIR"
    install -D templates/copyright -t "$BASE_DIR/usr/share/doc/$PACKAGE"
    install -D tmp/changelog.gz -t "$BASE_DIR/usr/share/doc/$PACKAGE"

    # Download and move file
    install -D -m 755 "$FRP_DIR/$PACKAGE" -t "$BASE_DIR/usr/bin"
    install -D "$FRP_DIR/$PACKAGE.toml" -t "$BASE_DIR/etc/frp"

    if [ "$PACKAGE" = "frps" ]; then
        install -D "templates/frps/frps.service" -t "$BASE_DIR/usr/lib/systemd/system"
        install -D -m 755 "templates/frps/postinst" -t "$BASE_DIR/DEBIAN"
        install -D -m 755 "templates/frps/postrm" -t "$BASE_DIR/DEBIAN"
        install -D -m 755 "templates/frps/prerm" -t "$BASE_DIR/DEBIAN"
    fi

    # Package deb
    mkdir -p "$BASE_DIR/DEBIAN"
    SIZE=$(du -sk "$BASE_DIR"/usr | cut -f1)
    echo "Package: $PACKAGE
Version: $VERSION-1
Architecture: $ARCH
Installed-Size: $SIZE
Maintainer: wcbing <i@wcbing.top>
Section: web
Priority: optional
Homepage: https://gofrp.org/
Description: A fast reverse proxy to help you expose a local server
 behind a NAT or firewall to the internet. 
" > "$BASE_DIR/DEBIAN/control"

    dpkg-deb -b --root-owner-group -Z xz "$BASE_DIR" output
}

get_url_by_arch() {
    DOWNLOAD_PREFIX="https://github.com/$REPO/releases/latest/download"
    case $1 in
    "amd64") echo "$DOWNLOAD_PREFIX/$AMD64_FILENAME" ;;
    "arm64") echo "$DOWNLOAD_PREFIX/$ARM64_FILENAME" ;;
    esac
}

prepare

for ARCH in $ARCH_LIST; do
    echo "Building $ARCH package..."
    curl -fsLO "$(get_url_by_arch "$ARCH")"
    FRP_DIR=frp_"$VERSION"_linux_"$ARCH"
    tar -xf "$FRP_DIR".tar.gz
    PACKAGE="frps"
    build
    PACKAGE="frpc"
    build
done

# Create repo files
cd output && apt-ftparchive packages . > Packages && apt-ftparchive release . > Release
