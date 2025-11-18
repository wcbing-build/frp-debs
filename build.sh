#!/bin/sh

# PACKAGE="frp"
REPO="fatedier/frp"

# Processing again to avoid errors of remote incoming 
VERSION=$(echo $1 | sed -n 's|[^0-9]*\([^_]*\).*|\1|p')

ARCH="amd64 arm64"
AMD64_FILENAME="frp_"$VERSION"_linux_amd64.tar.gz"
ARM64_FILENAME="frp_"$VERSION"_linux_arm64.tar.gz"

build() {
    BASE_DIR="$PACKAGE"_"$VERSION"-1_"$1"
    cp -r templates_"$PACKAGE" "$BASE_DIR"
    sed -i "s/Architecture: arch/Architecture: $1/" "$BASE_DIR/DEBIAN/control"
    sed -i "s/Version: version/Version: $VERSION-1/" "$BASE_DIR/DEBIAN/control"
    mv frp_"$VERSION"_linux_$i/$PACKAGE "$BASE_DIR/usr/bin/$PACKAGE"
    chmod 755 "$BASE_DIR/usr/bin/$PACKAGE"
    mv frp_"$VERSION"_linux_"$i"/$PACKAGE.toml "$BASE_DIR/etc/frp/$PACKAGE.toml"
    dpkg-deb -b --root-owner-group -Z xz "$BASE_DIR" output
}

get_url_by_arch() {
    DOWNLOAD_PERFIX="https://github.com/$REPO/releases/latest/download"
    case $1 in
    "amd64") echo "$DOWNLOAD_PERFIX/$AMD64_FILENAME" ;;
    "arm64") echo "$DOWNLOAD_PERFIX/$ARM64_FILENAME" ;;
    esac
}

mkdir output

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
cd output
apt-ftparchive packages . > Packages
apt-ftparchive release . > Release
