#!/usr/bin/env bash
# Precompile published packages into /tmp/mojo-hdf5-pkg.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
out="${MOJO_HDF5_PKG:-/tmp/mojo-hdf5-pkg}"
mkdir -p "$out"
if command -v pixi >/dev/null 2>&1 && [[ -d "$root/.pixi" ]]; then
  MOJO=(pixi run mojo)
elif command -v mojo >/dev/null 2>&1; then
  MOJO=(mojo)
else
  echo "mojo not found; run scripts/ci-setup.sh" >&2
  exit 1
fi
"${MOJO[@]}" precompile -I src src/runtime -o "$out/runtime.mojoc"
"${MOJO[@]}" precompile -I src src/wire -o "$out/wire.mojoc"
"${MOJO[@]}" precompile -I src src/schema -o "$out/schema.mojoc"
"${MOJO[@]}" precompile -I src src/hdf5 -o "$out/hdf5.mojoc"
"${MOJO[@]}" build -I src src/codegen/cli.mojo -o "$out/gld-hdf5gen-mojo"
echo "wrote $out"
