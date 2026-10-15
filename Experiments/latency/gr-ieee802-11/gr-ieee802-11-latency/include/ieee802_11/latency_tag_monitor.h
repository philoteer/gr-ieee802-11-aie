/* SPDX-License-Identifier: GPL-3.0-or-later */
#ifndef INCLUDED_IEEE802_11_LATENCY_TAG_MONITOR_H
#define INCLUDED_IEEE802_11_LATENCY_TAG_MONITOR_H

#include <gnuradio/sync_block.h>
#include <ieee802_11/api.h>

namespace gr {
namespace ieee802_11 {

/*! \brief Native IQ side tap forwarding annotated boundaries as messages.
 *
 * Input: complex float32 IQ carrying frame_start/frame_end dictionaries.
 * Output: events messages, pairs of (boundary key, original dictionary).
 * The source's timestamp_ns is preserved; delivery never retimestamps an event.
 * No IQ output or Python streaming callback is involved.
 */
class IEEE802_11_API latency_tag_monitor : virtual public gr::sync_block
{
public:
    typedef std::shared_ptr<latency_tag_monitor> sptr;
    static sptr make();
};

} // namespace ieee802_11
} // namespace gr
#endif
