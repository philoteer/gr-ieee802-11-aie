/* SPDX-License-Identifier: AGPL-3.0-or-later */
#include <gnuradio/ieee80211/latency_tag_monitor.h>
#include <gnuradio/gr_complex.h>
#include <gnuradio/io_signature.h>
#include <pmt/pmt.h>

namespace gr {
namespace ieee80211 {

class latency_tag_monitor_impl : public latency_tag_monitor
{
    const pmt::pmt_t d_start = pmt::intern("frame_start");
    const pmt::pmt_t d_end = pmt::intern("frame_end");
    const pmt::pmt_t d_events = pmt::intern("events");

public:
    latency_tag_monitor_impl()
        : gr::sync_block("latency_tag_monitor",
                         gr::io_signature::make(1, 1, sizeof(gr_complex)),
                         gr::io_signature::make(0, 0, 0))
    {
        message_port_register_out(d_events);
        set_tag_propagation_policy(TPP_DONT);
    }

    int work(int count, gr_vector_const_void_star&, gr_vector_void_star&) override
    {
        std::vector<tag_t> tags;
        get_tags_in_window(tags, 0, 0, count);
        for (const auto& tag : tags) {
            if ((pmt::eq(tag.key, d_start) || pmt::eq(tag.key, d_end)) &&
                pmt::is_dict(tag.value)) {
                message_port_pub(d_events, pmt::cons(tag.key, tag.value));
            }
        }
        return count;
    }
};

latency_tag_monitor::sptr latency_tag_monitor::make()
{
    return gnuradio::make_block_sptr<latency_tag_monitor_impl>();
}

} // namespace ieee80211
} // namespace gr
