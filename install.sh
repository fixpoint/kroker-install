#!/bin/sh
set -e

usage() {
  cat <<EOF
$1: install kroker package

Usage: $1 [-v VERSION] [-d DEST] [-y]
  -v  Install VERSION Kroker instead
  -d  Install Kroker to DEST (Default: $HOME/.kroker)
  -y  Continue installation even the DEST is not empty

EOF
  exit 2
}

check_command() {
  if ! command -v $1 >/dev/null; then
    echo "$1 is required to install Kroker." 1>&2
    exit 1
  fi
}

find_arch() {
  arch="$(uname -m)"
  case $arch in
    x86_64) echo "amd64";;
    arm64 | aarch64) echo "arm64";;
    *)
      echo "$arch is not supported." 1>&2
      exit 1;;
  esac
}

list_download_urls() {
  curl -sSL "https://support.kompira.jp/2000/11/16/kroker-archive/" \
    | grep -o 'https[^"]*.tar.xz' \
    | grep -e $(find_arch) \
    | sort -rV
}

# Check required commands
check_command curl
check_command grep
check_command sort
check_command uname
check_command tar
check_command docker

# Parse flags
kroker_overwrite=""
kroker_version=""
kroker_dest="$HOME/.kroker"
while getopts "hyd:v:" arg; do
  case "$arg" in
    h) usage "$0";;
    y) kroker_overwrite="1";;
    d) kroker_dest="$OPTARG";;
    v) kroker_version="$OPTARG";;
  esac
done

if [ "$kroker_overwrite" != "1" ] && [ -d "$kroker_dest" ] && [ "$(ls -A $kroker_dest)" != "" ]; then
  echo "The destination directory ($kroker_dest) is not empty." 1>&2
  echo "Use '$0 -d DEST' to change directory or '$0 -y' to allow overwrite." 1>&2
  exit 1
fi

# List download URLs
download_urls=$(list_download_urls)

if [ "$kroker_version" != "" ]; then
  download_url=$(echo "$download_urls" | grep -e "$kroker_version" | head -1)
  if [ "$download_url" = "" ]; then
    # The specified KROKER_VERSION seems not correct
    echo "Kroker version specified ($kroker_version) is not valid" 1>&2
    exit 1
  fi
else
  download_url=$(echo "$download_urls" | head -1)
fi

curl --fail --location --progress-bar --output "$kroker_dest/tmp-kroker.tar.xz" "$download_url"

tar xvf "$kroker_dest/tmp-kroker.tar.xz" -C "$kroker_dest" --strip-components 1

docker load < "$kroker_dest/kroker.tar"

rm "$kroker_dest/tmp-kroker.tar.xz"

echo "================================================================================"
echo "Kroker was installed successfully to $kroker_dest"
echo "Register Kroker to Kompira by following command."
echo
echo "  docker compose run kroker setup"
echo
echo "See README.md or README-ja.md for more details."
echo "================================================================================"
