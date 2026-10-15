/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Handwritten binding; no generated docstring/hash dependency.
 * BINDTOOL_GEN_AUTOMATIC(0)
 * BINDTOOL_USE_PYGCCXML(0)
 * BINDTOOL_HEADER_FILE(latency_tag_monitor.h)
 * BINDTOOL_HEADER_FILE_HASH(0)
 */
#include <pybind11/pybind11.h>
#include <ieee802_11/latency_tag_monitor.h>

namespace py = pybind11;

void bind_latency_tag_monitor(py::module& m)
{
    using gr::ieee802_11::latency_tag_monitor;
    py::class_<latency_tag_monitor, gr::sync_block, gr::block, gr::basic_block,
               std::shared_ptr<latency_tag_monitor>>(m, "latency_tag_monitor")
        .def(py::init(&latency_tag_monitor::make));
}
