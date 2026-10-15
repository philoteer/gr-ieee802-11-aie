# Source from bash to select this experiment's edited receiver, not /usr/local.
_ieee_latency_root="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
_ieee_latency_prefix="$_ieee_latency_root/gr-ieee802-11-latency/local"
_ieee_latency_python="$(/usr/bin/python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')"
export PYTHONPATH="$_ieee_latency_prefix/lib/$_ieee_latency_python/site-packages${PYTHONPATH:+:$PYTHONPATH}"
export LD_LIBRARY_PATH="$_ieee_latency_prefix/lib/$(gcc -dumpmachine)${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
# GRC uses the last definition; put the edited receiver's blocks last.
export GR_CONF_GRC_GLOBAL_BLOCKS_PATH="/usr/share/gnuradio/grc/blocks:/usr/local/share/gnuradio/grc/blocks:$_ieee_latency_root/gr-ieee802-11-latency/grc"
unset _ieee_latency_root _ieee_latency_prefix _ieee_latency_python
