#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: NPU Intra-Block Latency Profile
# Description: Host-side stage timing inside the locally built NPU PHY block.
# GNU Radio version: 3.10.9.2

from gnuradio import blocks
import pmt
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import mlir_aie
import foo
import ieee802_11


def snipfcn_profile_start(self):
    import profiler_support
    self.profile_session = profiler_support.ProfileSession(self, self.output_dir)

def snipfcn_create_output_directory(self):
    __import__('pathlib').Path(self.output_dir).mkdir(parents=True, exist_ok=True)

def snipfcn_profile_finish(self):
    self.profile_session.finish()


def snippets_main_after_init(tb):
    snipfcn_profile_start(tb)

def snippets_main_after_stop(tb):
    snipfcn_profile_finish(tb)

def snippets_init_before_blocks(tb):
    snipfcn_create_output_directory(tb)


class npu_intra_kernel(gr.top_block):

    def __init__(self, num_samples=0):
        gr.top_block.__init__(self, "NPU Intra-Block Latency Profile", catch_exceptions=True)

        ##################################################
        # Parameters
        ##################################################
        self.num_samples = num_samples

        ##################################################
        # Variables
        ##################################################
        self.data_dir = data_dir = str(__import__('pathlib').Path(globals().get('__file__', 'Experiments/latency_profile/npu_intra_kernel.py')).resolve().parents[2] / 'AI-model-CNN-Channel-est' / 'data')
        self.output_dir = output_dir = str(__import__('pathlib').Path(__import__('os').environ.get('PROFILE_OUTPUT_DIR', str(__import__('pathlib').Path(globals().get('__file__', 'Experiments/latency_profile/npu_intra_kernel.py')).resolve().parent / 'results'))) / 'intra')
        self.kernel_dir = kernel_dir = str(__import__('pathlib').Path(data_dir).parents[1] / 'Experiments' / 'xclbin_default' / 'LS')
        self.freq = freq = 2.417e9
        self.file_path = file_path = data_dir + "/raw_capture/room_20260927.sigmf"

        ##################################################
        # Blocks
        ##################################################
        snippets_init_before_blocks(self)
        self.mlir_aie_sigmf_tag_injector_0 = mlir_aie.sigmf_tag_injector(file_path + '-meta', 8, 'rx_freq', 0)
        self.mlir_aie_mlir_aie_80211_phy_0 = mlir_aie.mlir_aie_80211_phy(kernel_dir + '/final.xclbin', kernel_dir + '/insts.bin', 'MLIR_AIE', 16384, freq, 2, 16, '')
        self.mlir_aie_complex64_to_cint16_0 = mlir_aie.complex64_to_cint16(False)
        self.ieee802_11_parse_mac_0 = ieee802_11.parse_mac(False, False)
        self.ieee802_11_decode_mac_0 = ieee802_11.decode_mac(False, False)
        self.foo_wireshark_connector_0 = foo.wireshark_connector(127, False)
        self.blocks_stream_to_vector_0 = blocks.stream_to_vector(gr.sizeof_char*1, 48)
        self.blocks_interleaved_short_to_complex_0 = blocks.interleaved_short_to_complex(False, False,32768)
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_short*1, file_path + '-data', False, 0, (2 * num_samples))
        self.blocks_file_source_0.set_begin_tag(pmt.PMT_NIL)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_char*1, output_dir + '/decoded.pcap', False)
        self.blocks_file_sink_0.set_unbuffered(True)


        ##################################################
        # Connections
        ##################################################
        self.msg_connect((self.ieee802_11_decode_mac_0, 'out'), (self.foo_wireshark_connector_0, 'in'))
        self.msg_connect((self.ieee802_11_decode_mac_0, 'out'), (self.ieee802_11_parse_mac_0, 'in'))
        self.connect((self.blocks_file_source_0, 0), (self.blocks_interleaved_short_to_complex_0, 0))
        self.connect((self.blocks_interleaved_short_to_complex_0, 0), (self.mlir_aie_sigmf_tag_injector_0, 0))
        self.connect((self.blocks_stream_to_vector_0, 0), (self.ieee802_11_decode_mac_0, 0))
        self.connect((self.foo_wireshark_connector_0, 0), (self.blocks_file_sink_0, 0))
        self.connect((self.mlir_aie_complex64_to_cint16_0, 0), (self.mlir_aie_mlir_aie_80211_phy_0, 0))
        self.connect((self.mlir_aie_mlir_aie_80211_phy_0, 0), (self.blocks_stream_to_vector_0, 0))
        self.connect((self.mlir_aie_sigmf_tag_injector_0, 0), (self.mlir_aie_complex64_to_cint16_0, 0))


    def get_num_samples(self):
        return self.num_samples

    def set_num_samples(self, num_samples):
        self.num_samples = num_samples

    def get_data_dir(self):
        return self.data_dir

    def set_data_dir(self, data_dir):
        self.data_dir = data_dir
        self.set_kernel_dir(str(__import__('pathlib').Path(self.data_dir).parents[1] / 'Experiments' / 'xclbin_default' / 'LS'))
        self.set_file_path(self.data_dir + "/raw_capture/room_20260927.sigmf")

    def get_output_dir(self):
        return self.output_dir

    def set_output_dir(self, output_dir):
        self.output_dir = output_dir
        self.blocks_file_sink_0.open(self.output_dir + '/decoded.pcap')

    def get_kernel_dir(self):
        return self.kernel_dir

    def set_kernel_dir(self, kernel_dir):
        self.kernel_dir = kernel_dir

    def get_freq(self):
        return self.freq

    def set_freq(self, freq):
        self.freq = freq
        self.mlir_aie_mlir_aie_80211_phy_0.set_nominal_frequency(self.freq)

    def get_file_path(self):
        return self.file_path

    def set_file_path(self, file_path):
        self.file_path = file_path
        self.blocks_file_source_0.open(self.file_path + '-data', False)



def argument_parser():
    description = 'Host-side stage timing inside the locally built NPU PHY block.'
    parser = ArgumentParser(description=description)
    parser.add_argument(
        "-n", "--num-samples", dest="num_samples", type=intx, default=0,
        help="Set Input complex samples (0 = entire file) [default=%(default)r]")
    return parser


def main(top_block_cls=npu_intra_kernel, options=None):
    if options is None:
        options = argument_parser().parse_args()
    tb = top_block_cls(num_samples=options.num_samples)
    snippets_main_after_init(tb)
    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()
        snippets_main_after_stop(tb)
        sys.exit(0)

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    tb.start()

    tb.wait()
    snippets_main_after_stop(tb)

if __name__ == '__main__':
    main()
