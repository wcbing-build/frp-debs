#!/bin/sh

REPO="fatedier/frp"
LOCAL_REPO="wcbing-build/frp-debs"

get_github_latest_tag() {
    curl -sw "%{redirect_url}" "https://github.com/$1/releases/latest" |
        sed -n 's|.*/releases/tag/[^0-9]*\([^_]*\).*|\1|p'
}

LOCAL_VERSION=$(get_github_latest_tag "$LOCAL_REPO")
if [ -z "$LOCAL_VERSION" ]; then
    echo "Error: Can't get version tag from $LOCAL_REPO."
    LOCAL_VERSION="0"
fi

VERSION=$(get_github_latest_tag "$REPO")
if [ -z "$VERSION" ]; then
    echo "Error: Can't get version tag from $REPO."
    echo 0 > tag
    exit 1
elif [ "$LOCAL_VERSION" = "$VERSION" ]; then
    echo "No update."
    echo 0 > tag
    exit 0
fi

echo "$VERSION" > tag
echo "Update to $VERSION from $LOCAL_VERSION."
