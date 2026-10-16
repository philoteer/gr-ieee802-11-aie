/* SPDX-License-Identifier: AGPL-3.0-or-later */
// Linux/GNU Radio 3.10 validation probe; never loaded by production flowgraphs.
// Independently observe ingress/final demodulator tags and packet publication.
#include <gnuradio/block.h>
#include <gnuradio/basic_block.h>
#include <pmt/pmt.h>
#include <dlfcn.h>
#include <time.h>
#include <array>
#include <cstring>
#include <mutex>
#include <map>
#include <string>

namespace {
std::array<std::array<uint64_t, 5>, 4096> stamps{};
std::map<uint64_t, uint64_t> equalized_events;
std::mutex guard;
uint64_t now_ns()
{
    timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return uint64_t(ts.tv_sec) * 1000000000ULL + ts.tv_nsec;
}
}

extern "C" void latency_probe_reset()
{
    std::lock_guard<std::mutex> lock(guard);
    for (auto& frame : stamps)
        frame.fill(0);
    equalized_events.clear();
}

extern "C" uint64_t latency_probe_get(unsigned frame, unsigned event)
{
    std::lock_guard<std::mutex> lock(guard);
    return stamps.at(frame).at(event);
}

void gr::block::add_item_tag(unsigned int port, const gr::tag_t& tag)
{
    using fn = void (*)(gr::block*, unsigned int, const gr::tag_t&);
    static auto original = reinterpret_cast<fn>(
        dlsym(RTLD_NEXT, "_ZN2gr5block12add_item_tagEjRKNS_5tag_tE"));
    if (name() == "demod" && pmt::eq(tag.key, pmt::intern("phy_equalized_ns"))) {
        const auto observed = now_ns();
        std::lock_guard<std::mutex> lock(guard);
        equalized_events.emplace(pmt::to_uint64(tag.value), observed);
    }
    if (name() == "sigmf_tag_injector" && pmt::is_dict(tag.value) &&
        (pmt::eq(tag.key, pmt::intern("frame_start")) ||
         pmt::eq(tag.key, pmt::intern("frame_end")))) {
        auto label = pmt::dict_ref(tag.value, pmt::intern("frame_id"), pmt::PMT_NIL);
        auto time = pmt::dict_ref(tag.value, pmt::intern("timestamp_ns"), pmt::PMT_NIL);
        if (pmt::is_symbol(label) && pmt::is_uint64(time)) {
            auto text = pmt::symbol_to_string(label);
            if (text.rfind("wifi-frame-", 0) == 0) {
                auto index = std::stoul(text.substr(11));
                auto event = pmt::eq(tag.key, pmt::intern("frame_start")) ? 0 : 1;
                std::lock_guard<std::mutex> lock(guard);
                stamps.at(index).at(event) = pmt::to_uint64(time);
            }
        }
    }
    original(this, port, tag);
}

void gr::basic_block::message_port_pub(pmt::pmt_t port, pmt::pmt_t msg)
{
    const auto published = now_ns();
    using fn = void (*)(gr::basic_block*, pmt::pmt_t, pmt::pmt_t);
    static auto original = reinterpret_cast<fn>(dlsym(
        RTLD_NEXT, "_ZN2gr11basic_block16message_port_pubESt10shared_ptrIN3pmt8pmt_baseEES4_"));
    if (name() == "decode" && pmt::eq(port, pmt::intern("out")) &&
        pmt::is_pair(msg) && pmt::is_blob(pmt::cdr(msg))) {
        auto data = pmt::cdr(msg);
        auto bytes = static_cast<const uint8_t*>(pmt::blob_data(data));
        // format(1), length(2), MAC header(24), unique payload prefix + ID.
        if (pmt::blob_length(data) >= 49 && bytes[0] <= 2 &&
            std::memcmp(bytes + 27, "WIFI-LATENCY:", 13) == 0) {
            auto index = std::stoul(std::string(reinterpret_cast<const char*>(bytes + 40), 8));
            auto completed = pmt::dict_ref(pmt::car(msg), pmt::intern("phy_equalized_ns"),
                                            pmt::PMT_NIL);
            std::lock_guard<std::mutex> lock(guard);
            stamps.at(index)[2] = published;
            stamps.at(index)[3] = pmt::to_uint64(completed);
            stamps.at(index)[4] = equalized_events.at(pmt::to_uint64(completed));
        }
    }
    original(this, port, msg);
}
