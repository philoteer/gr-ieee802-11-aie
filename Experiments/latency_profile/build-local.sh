#!/usr/bin/env bash
set -euo pipefail
root="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
module="$root/gr-mlir_aie-profile/gr-mlir_aie"
cmake -S "$module" -B "$module/build-profile" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$module/local" \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 -DENABLE_DOXYGEN=OFF
cmake --build "$module/build-profile" --parallel "${PROFILE_BUILD_JOBS:-2}"
cmake --install "$module/build-profile"
