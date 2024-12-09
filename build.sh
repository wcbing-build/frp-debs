#!/bin/sh

# PACKAGE="frp"
REPO="fatedier/frp"

VERSION="$(cat tag)"

ARCH="amd64 arm64"
AMD64_FILENAME="frp_"$VERSION"_linux_amd64.tar.gz"
ARM64_FILENAME="frp_"$VERSION"_linux_arm64.tar.gz"

get_url_by_arch() {
    case $1 in
    "amd64") echo "https://github.com/$REPO/releases/latest/download/$AMD64_FILENAME" ;;
    "arm64") echo "https://github.com/$REPO/releases/latest/download/$ARM64_FILENAME" ;;
    esac
}

build() {
    BASE_DIR="$PACKAGE"_"$VERSION"-1_"$1"
    cp -r templates_"$PACKAGE" "$BASE_DIR"
    sed -i "s/Architecture: arch/Architecture: $1/" "$BASE_DIR/DEBIAN/control"
    sed -i "s/Version: version/Version: $VERSION-1/" "$BASE_DIR/DEBIAN/control"
    mv frp_"$VERSION"_linux_$i/$PACKAGE "$BASE_DIR/usr/bin/$PACKAGE"
    chmod 755 "$BASE_DIR/usr/bin/$PACKAGE"
    mv frp_"$VERSION"_linux_"$i"/$PACKAGE.toml "$BASE_DIR/etc/frp/$PACKAGE.toml"
    dpkg-deb --build --root-owner-group "$BASE_DIR"
}

for i in $ARCH; do
    echo "Building $i package..."
    curl -sLO "$(get_url_by_arch $i)"
    tar -xzf frp_"$VERSION"_linux_"$i".tar.gz
    PACKAGE="frps"
    build "$i"
    PACKAGE="frpc"
    build "$i"
done

# Create repo files
apt-ftparchive packages . > Packages
apt-ftparchive release . > Release
