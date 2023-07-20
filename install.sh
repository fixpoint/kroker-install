#!/bin/sh

set -e

check_command() {
  if ! command -v $1 >/dev/null; then
    echo "Error: $1 is required to install Kroker." 1>&2
    exit 1
  fi
}

find_arch() {
  arch="$(uname -m)"
  case $arch in
    x86_64) echo "amd64";;
    arm64 | aarch64) echo "arm64";;
    *)
      echo "Error: $arch is not supported." 1>&2
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

kroker_install="${KROKER_INSTALL:-$HOME/.kroker}"

if [ -d "$kroker_install" ]; then
  echo "KROKER_INSTALL ($kroker_install) directory already exists."
  read -n1 -p "Do you want to overwrite it? [y/N]: " yn
  case "$yn" in
    [yY])
      ;;
    *)
      echo "Cancel" 1>&2
      exit 1
  esac
fi
mkdir -p "${kroker_install}"

# List download URLs
download_urls=$(list_download_urls)

if [ "$KROKER_VERSION" != "" ]; then
  download_url=$(echo "$download_urls" | grep -e "$KROKER_VERSION" | head -1)
  if [ "$download_url" = "" ]; then
    # The specified KROKER_VERSION seems not correct
    echo "Error: KROKER_VERSION ($KROKER_VERSION) is not valid version of Kroker" 1>&2
    exit 1
  fi
else
  download_url=$(echo "$download_urls" | head -1)
fi

curl --fail --location --progress-bar --output "${kroker_install}/tmp-kroker.tar.xz" "$download_url"

tar xvf "${kroker_install}/tmp-kroker.tar.xz" -C "${kroker_install}" --strip-components 1

docker load < "${kroker_install}/kroker.tar"

rm "${kroker_install}/tmp-kroker.tar.xz"

echo "================================================================================"
echo "Kroker was installed successfully to $kroker_install"
echo "Register Kroker to Kompira by following command."
echo
echo "  docker compose run kroker setup"
echo
echo "See README.md or README-ja.md for more details."
echo "================================================================================"
