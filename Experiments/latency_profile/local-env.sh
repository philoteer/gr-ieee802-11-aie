# Source before starting GNU Radio Companion or running generated scripts.
_profile_root="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
_profile_prefix="$_profile_root/gr-mlir_aie-profile/gr-mlir_aie/local"
_profile_python="$(/usr/bin/python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')"
export PYTHONPATH="$_profile_root:$_profile_prefix/lib/$_profile_python/site-packages${PYTHONPATH:+:$PYTHONPATH}"
export LD_LIBRARY_PATH="$_profile_prefix/lib/$(gcc -dumpmachine):$_profile_prefix/lib:$_profile_root/../../gr-foo-modified/build/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export GR_CONF_GRC_GLOBAL_BLOCKS_PATH="/usr/share/gnuradio/grc/blocks:/usr/local/share/gnuradio/grc/blocks:$_profile_root/gr-mlir_aie-profile/gr-mlir_aie/grc"
unset _profile_root _profile_prefix _profile_python
