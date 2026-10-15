# Source this file from bash before using grcc or gnuradio-companion.
_latency_root="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
_latency_prefix="$_latency_root/gr-mlir_aie/local"
_latency_python="$(/usr/bin/python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')"
export PYTHONPATH="$_latency_prefix/lib/$_latency_python/site-packages${PYTHONPATH:+:$PYTHONPATH}"
export LD_LIBRARY_PATH="$_latency_prefix/lib/$(gcc -dumpmachine)${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
# GRC loads the last definition of a block; GRC_BLOCKS_PATH alone is overridden
# by the installed /usr/local definitions on this host.
export GR_CONF_GRC_GLOBAL_BLOCKS_PATH="/usr/share/gnuradio/grc/blocks:/usr/local/share/gnuradio/grc/blocks:$_latency_root/gr-mlir_aie/grc"
unset _latency_root _latency_prefix _latency_python
