# Source from bash to load this experiment's edited GR-WiFi receiver.
_grwifi_latency_root="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
_grwifi_latency_prefix="$_grwifi_latency_root/gr-ieee80211/local"
_grwifi_latency_python="$(/usr/bin/python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')"
export PYTHONPATH="$_grwifi_latency_prefix/lib/$_grwifi_latency_python/site-packages${PYTHONPATH:+:$PYTHONPATH}"
export LD_LIBRARY_PATH="$_grwifi_latency_prefix/lib/$(gcc -dumpmachine)${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
# GRC loads the last definition, so place the edited receiver's definitions last.
export GR_CONF_GRC_GLOBAL_BLOCKS_PATH="/usr/share/gnuradio/grc/blocks:/usr/local/share/gnuradio/grc/blocks:$_grwifi_latency_root/gr-ieee80211/grc"
unset _grwifi_latency_root _grwifi_latency_prefix _grwifi_latency_python
