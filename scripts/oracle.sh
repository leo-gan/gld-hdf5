#!/usr/bin/env bash
# Optional checks against h5dump, ncdump, and bpls. Missing tools are skipped.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
if command -v pixi >/dev/null 2>&1 && [[ -d "$root/.pixi" ]]; then
  MOJO=(pixi run mojo)
elif command -v mojo >/dev/null 2>&1; then
  MOJO=(mojo)
else
  echo "mojo not found" >&2
  exit 1
fi
"${MOJO[@]}" run -I src examples/write_samples.mojo
if command -v h5dump >/dev/null 2>&1; then
  h5dump /tmp/gld-hdf5-oracle-f64.h5
  h5dump -H -p /tmp/gld-hdf5-oracle-f64.h5
else
  echo "h5dump not on PATH; skipped"
fi
if command -v ncdump >/dev/null 2>&1; then
  ncdump /tmp/gld-hdf5-oracle-classic.nc
  ncdump -k /tmp/gld-hdf5-oracle-classic.nc
else
  echo "ncdump not on PATH; skipped"
fi
if command -v bpls >/dev/null 2>&1; then
  echo "bpls (expected to fail on the pure-Mojo metadata subset):"
  bpls -lad /tmp/gld-hdf5-oracle-step.bp || true
else
  echo "bpls not on PATH; skipped"
fi
