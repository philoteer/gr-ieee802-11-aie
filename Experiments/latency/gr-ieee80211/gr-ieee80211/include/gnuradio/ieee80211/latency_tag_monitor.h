/* SPDX-License-Identifier: AGPL-3.0-or-later */
#ifndef INCLUDED_IEEE80211_LATENCY_TAG_MONITOR_H
#define INCLUDED_IEEE80211_LATENCY_TAG_MONITOR_H

#include <gnuradio/sync_block.h>
#include <gnuradio/ieee80211/api.h>

namespace gr {
namespace ieee80211 {

/*! \brief Native IQ side tap forwarding frame_start/frame_end dictionaries.
 *
 * The events message port emits (boundary key, original dictionary) pairs.
 * The source's timestamp_ns is preserved even if this side tap runs late.
 * There is no IQ output or Python streaming callback.
 */
class IEEE80211_API latency_tag_monitor : virtual public gr::sync_block
{
public:
    typedef std::shared_ptr<latency_tag_monitor> sptr;
    static sptr make();
};

} // namespace ieee80211
} // namespace gr
#endif
