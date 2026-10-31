#!/bin/sh
# Install sts with your normal git access to Blitzscale-19 (no token needed):
#   rm -rf /tmp/sts-install && git clone -q --depth 1 -b release git@github.com:Blitzscale-19/syncToStage.git /tmp/sts-install && sh /tmp/sts-install/install.sh; rm -rf /tmp/sts-install
# Change the install dir with STS_INSTALL_DIR=/usr/local/bin
set -eu

release_repository_url="${STS_REPO_URL:-git@github.com:Blitzscale-19/syncToStage.git}"
install_dir="${STS_INSTALL_DIR:-$HOME/.local/bin}"

case "$(uname -s)" in
  Linux)  os_part="unknown-linux-musl" ;;
  Darwin) os_part="apple-darwin" ;;
  *) echo "sts: unsupported OS $(uname -s) (on Windows, use WSL)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64 | amd64)  arch_part="x86_64" ;;
  arm64 | aarch64) arch_part="aarch64" ;;
  *) echo "sts: unsupported CPU $(uname -m)" >&2; exit 1 ;;
esac

archive_name="sts-${arch_part}-${os_part}.tar.gz"

temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT

release_dir="$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)"
if [ -z "$release_dir" ] || [ ! -f "${release_dir}/${archive_name}" ]; then
  release_dir="${temporary_dir}/release"
  echo "sts: fetching the release branch from ${release_repository_url}"
  git clone -q --depth 1 -b release "$release_repository_url" "$release_dir"
fi

version="$(cat "${release_dir}/VERSION" 2>/dev/null || echo unknown)"
echo "sts: installing ${archive_name} (${version})"

expected_checksum="$(cut -d ' ' -f 1 "${release_dir}/${archive_name}.sha256")"
if command -v sha256sum >/dev/null 2>&1; then
  actual_checksum="$(sha256sum "${release_dir}/${archive_name}" | cut -d ' ' -f 1)"
else
  actual_checksum="$(shasum -a 256 "${release_dir}/${archive_name}" | cut -d ' ' -f 1)"
fi
if [ "$expected_checksum" != "$actual_checksum" ]; then
  echo "sts: checksum mismatch, aborting" >&2
  exit 1
fi

tar -xzf "${release_dir}/${archive_name}" -C "$temporary_dir"
mkdir -p "$install_dir"
install -m 755 "${temporary_dir}/sts" "${install_dir}/sts"

echo "sts: installed to ${install_dir}/sts"
case ":$PATH:" in
  *":${install_dir}:"*) ;;
  *) echo "sts: add ${install_dir} to your PATH, e.g. echo 'export PATH=\"${install_dir}:\$PATH\"' >> ~/.zshrc" ;;
esac
echo "sts: next, create ~/.config/sts/config.toml and run 'sts -c' to check it; update later with 'sts -U'"
