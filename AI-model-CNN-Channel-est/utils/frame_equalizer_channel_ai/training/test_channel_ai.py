"""Unit tests for persisted corpora and integer export parity."""

import json
import re
from pathlib import Path
import sys

import numpy as np
import torch

PROJECT_ROOT = Path(__file__).resolve().parents[3]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from utils.frame_equalizer_channel_ai.common.dataset import (
    ChannelCorpus,
    OCCUPIED,
    corpus_digest,
    snr_feature_q15,
)
from utils.frame_equalizer_channel_ai.training import cli
from utils.frame_equalizer_channel_ai.training.model import _augment_inputs, train_model
from utils.frame_equalizer_channel_ai.common.corpora import load_corpus
from utils.frame_equalizer_channel_ai.verification import cli as verification
from utils.frame_equalizer_channel_ai.training.exporter import export_float_updater, export_trained_cnn
from utils.frame_equalizer_channel_ai.common.model import ChannelEstimator
from utils.frame_equalizer_channel_ai.training import updater


def _sample_corpus(samples: int) -> ChannelCorpus:
    inputs_q15 = np.zeros((samples, 6, 64), dtype=np.int32)
    inputs_q15[:, 4] = OCCUPIED.astype(np.int32)[None, :] * 32767
    observations = np.zeros((samples, 2, 64, 2), dtype=np.int32)
    snr_ratio_x16 = np.full(samples, 32, dtype=np.uint64)
    ls = np.zeros((samples, 64, 2), dtype=np.int32)
    ls[:, OCCUPIED, 0] = 16000
    truth = ls.copy()
    target_q15 = np.zeros_like(ls)
    normalization_shift = np.zeros(samples, dtype=np.int32)
    return ChannelCorpus(inputs_q15, observations, snr_ratio_x16, ls, truth,
                         target_q15, normalization_shift)


def test_saved_corpus_round_trip(tmp_path: Path):
    corpus = _sample_corpus(8)
    path = tmp_path / "train.npz"
    corpus.save(path)
    restored = ChannelCorpus.load(path)
    assert corpus_digest(corpus) == corpus_digest(restored)


def test_source_name_loads_from_synthetic_directory(tmp_path: Path):
    corpus = _sample_corpus(2)
    corpus.save(tmp_path / "synthetic_original" / "test.npz")
    loaded = load_corpus(tmp_path, "original", "test")
    assert corpus_digest(corpus) == corpus_digest(loaded)


def test_training_uses_saved_splits(tmp_path: Path):
    dataset_directory = tmp_path / "datasets"
    for source, split_sizes in (
        ("synthetic_original", {"train": 3, "validation": 1, "test": 1}),
        ("synthetic_gnuradio", {"train": 2, "validation": 1, "test": 1}),
    ):
        for split, samples in split_sizes.items():
            _sample_corpus(samples).save(dataset_directory / source / f"{split}.npz")

    args = cli.parser().parse_args([
        "train", "--epochs", "1", "--batch-size", "2",
        "--dataset", "both",
        "--dataset-dir", str(dataset_directory),
        "--checkpoint", str(tmp_path / "checkpoint.pt"),
        "--report", str(tmp_path / "report.json"),
        "--header", str(tmp_path / "weights.h"),
        "--cpu-header", str(tmp_path / "cpu_weights.h"),
        "--artifact-prefix", str(tmp_path / "weights"),
    ])

    args.func(args)
    settings = json.loads((tmp_path / "report.json").read_text())["settings"]
    assert settings["dataset"] == "both"
    assert (settings["train_samples"], settings["validation_samples"],
            settings["test_samples"]) == (5, 2, 2)
    gate_args = verification.parser().parse_args([
        "gate", "--weights", str(tmp_path / "weights.npz"),
        "--dataset", "both", "--dataset-dir", str(dataset_directory),
        "--report", str(tmp_path / "gate.json"),
    ])
    gate_args.func(gate_args)
    gate = json.loads((tmp_path / "gate.json").read_text())["gate_snr_ratio_x16"]
    export_args = cli.parser().parse_args([
        "export", "--checkpoint", str(tmp_path / "checkpoint.pt"),
        "--header", str(tmp_path / "weights.h"),
        "--cpu-header", str(tmp_path / "cpu_weights.h"),
        "--artifact-prefix", str(tmp_path / "weights"),
        "--gate-snr-ratio-x16", str(gate),
    ])
    export_args.func(export_args)
    with np.load(tmp_path / "weights.npz", allow_pickle=False) as weights:
        assert int(weights["gate_snr_ratio_x16"]) == gate
        source = (tmp_path / "cpu_weights.h").read_text()
        payload = torch.load(tmp_path / 'checkpoint.pt', weights_only=False)
        cpu_gate = payload['metadata']['cpu_gate_snr_ratio_x16']
        assert f"kGateSnrRatioX16 = {cpu_gate}ull" in source
        assert 'kWeightSource = "trained_float32"' in source
        for index in range(1, 4):
            values = re.search(rf"kW{index}\[\d+\] = \{{(.*?)\}};", source, re.S)[1]
            actual = np.asarray([float(v.rstrip('f')) for v in values.replace('\n', '').split(',')], dtype=np.float32)
            expected = payload['state_dict'][f'layers.{index - 1}.weight'].numpy().ravel()
            np.testing.assert_array_equal(actual, expected)
            assert not np.array_equal(actual, weights[f'w{index}'].ravel() / 128.0)
    evaluation = verification.parser().parse_args([
        "evaluate", "--weights", str(tmp_path / "weights.npz"),
        "--dataset", "both", "--dataset-dir", str(dataset_directory),
        "--checkpoint", str(tmp_path / "checkpoint.pt"),
        "--report", str(tmp_path / "evaluation.json"),
    ])
    evaluation.func(evaluation)
    assert json.loads((tmp_path / "evaluation.json").read_text())["dataset_matches_checkpoint"]


def test_early_stopping_restores_best_validation_weights():
    corpus = _sample_corpus(4)
    first, _, _, _ = train_model(corpus, corpus, 1, 2, 0.002, 40, noise_std=0)
    stopped, losses, validation_losses, best_epoch = train_model(
        corpus, corpus, 10, 2, 0.002, 40, patience=2, min_delta=1, noise_std=0)
    assert len(losses) == len(validation_losses) == 3
    assert best_epoch == 1
    for name, value in first.state_dict().items():
        assert torch.equal(value, stopped.state_dict()[name])


def test_cnn_gate_minimizes_mse_instead_of_evm():
    corpus = _sample_corpus(2)
    corpus.truth[:, OCCUPIED, 0] = np.asarray([100, 10000])[:, None]
    corpus.ls[:, OCCUPIED, 0] = np.asarray([80, 11100])[:, None]
    corpus.snr_ratio_x16[:] = [32, 320000]
    prediction = corpus.truth.copy()
    prediction[:, OCCUPIED, 0] = np.asarray([110, 9000])[:, None]
    gate, result = verification.select_estimate_gate(prediction, corpus)
    assert gate == np.iinfo(np.uint64).max
    assert result['mean_frame_mse'] == 250025.0
    assert verification.metrics(corpus.ls[1:], corpus.truth[1:])['equalization_evm'] < \
        verification.metrics(prediction[1:], corpus.truth[1:])['equalization_evm']
    candidates = [0] + [int(round(32 * 10 ** (db / 10)))
                        for db in np.arange(0, 40.5, 0.5)] + [gate]
    for threshold in candidates:
        estimate = prediction.copy()
        use_ls = corpus.snr_ratio_x16 >= threshold
        estimate[use_ls] = corpus.ls[use_ls]
        mse = np.mean((estimate[:, OCCUPIED].astype(np.float64) -
                       corpus.truth[:, OCCUPIED]) ** 2)
        assert result['mean_frame_mse'] <= mse


def test_noise_augmentation_is_reproducible_and_training_only():
    corpus = _sample_corpus(4)
    _, clean_losses, _, _ = train_model(corpus, corpus, 2, 2, 0.002, 40, noise_std=0)
    augmented, losses, validation_losses, _ = train_model(
        corpus, corpus, 2, 2, 0.002, 40, noise_std=0.15)
    repeated, repeated_losses, repeated_validation, _ = train_model(
        corpus, corpus, 2, 2, 0.002, 40, noise_std=0.15)
    assert losses != clean_losses
    assert losses == repeated_losses and validation_losses == repeated_validation
    for name, value in augmented.state_dict().items():
        assert torch.equal(value, repeated.state_dict()[name])


def test_augmentation_only_changes_lts_planes():
    inputs = torch.zeros((3, 6, 64))
    inputs[:, 4:] = 0.5
    assert _augment_inputs(inputs, 0, torch.Generator().manual_seed(3)) is inputs
    augmented = _augment_inputs(inputs, 0.1, torch.Generator().manual_seed(3))
    repeated = _augment_inputs(inputs, 0.1, torch.Generator().manual_seed(3))
    assert torch.equal(augmented, repeated)
    assert torch.count_nonzero(augmented[:, :4]) > 0
    assert torch.equal(augmented[:, 4:], inputs[:, 4:])
    assert torch.count_nonzero(inputs[:, :4]) == 0


def test_snr_feature_is_logarithmic_and_bounded():
    values = snr_feature_q15(np.asarray(
        (16, 32, 64, 320, 3200, 32000, 320000), dtype=np.uint64))
    assert np.array_equal(values, (0, 0, 2465, 8013, 16181, 24541, 32767))
    assert values[0] == 0
    assert np.all(np.diff(values[1:]) > 0)
    assert values[-1] == 32767


def test_updater_augmentation_preserves_snr_and_inputs():
    inputs = torch.zeros((3, 61))
    inputs[:, 60] = 0.5
    assert _augment_inputs(inputs, 0, torch.Generator().manual_seed(3), 60) is inputs
    augmented = _augment_inputs(inputs, 0.02, torch.Generator().manual_seed(3), 60)
    repeated = _augment_inputs(inputs, 0.02, torch.Generator().manual_seed(3), 60)
    assert torch.equal(augmented, repeated)
    assert torch.count_nonzero(augmented[:, :52]) > 0
    assert torch.count_nonzero(augmented[:, 52:60]) > 0
    assert torch.equal(augmented[:, 60], inputs[:, 60])
    assert torch.count_nonzero(inputs[:, :60]) == 0


def test_float_updater_export_preserves_group_layout(tmp_path):
    rng = np.random.default_rng(42)
    first = rng.integers(-128, 128, (4, 64, 16), dtype=np.int8)
    second = rng.integers(-128, 128, (4, 16, 32), dtype=np.int8)
    header = tmp_path / 'updater.h'
    export_float_updater((first, second), 32000, header)
    source = header.read_text()
    expected = (first[:, :61].transpose(0, 2, 1), second[:, :, :26].transpose(0, 2, 1))
    for index, weight in enumerate(expected, 1):
        values = re.search(rf"kW{index}\[\d+\] = \{{(.*?)\}};", source, re.S)[1]
        actual = np.asarray([float(v.rstrip('f')) for v in values.replace('\n', '').split(',')])
        np.testing.assert_array_equal(actual, weight.ravel() / 128.0)


def test_native_float_export_preserves_small_and_unquantizable_weights(tmp_path):
    model = ChannelEstimator()
    with torch.no_grad():
        model.layers[0].weight.view(-1)[:3] = torch.tensor([-1.1234567, 1e-15, 0.0034567])
    header = tmp_path / 'native.h'
    export_trained_cnn(model, 32000, header)
    source = header.read_text()
    values = re.search(r'kW1\[\d+\] = \{(.*?)\};', source, re.S)[1]
    actual = np.asarray([float(v.rstrip('f')) for v in values.replace('\n', '').split(',')], dtype=np.float32)
    np.testing.assert_array_equal(actual, model.layers[0].weight.detach().numpy().ravel())


def test_updater_training_checkpoint_reexports_both_backends(tmp_path, monkeypatch):
    rng = np.random.default_rng(45)
    data = (rng.integers(-16000, 16000, (8, 4, 61), dtype=np.int16),
            rng.integers(-500, 500, (8, 4, 26), dtype=np.int16),
            np.zeros((8, 52, 2), dtype=np.int32), np.full(8, 1600, dtype=np.uint64))
    monkeypatch.setattr(updater, 'load_cnn_header', lambda path: None)
    monkeypatch.setattr(updater, 'load_splits', lambda *args, **kwargs:
                        ({name: [None] for name in ('train', 'val', 'test')},
                         {name: {} for name in ('train', 'val', 'test')}))
    monkeypatch.setattr(updater, 'assemble', lambda *args: data)
    calls = []
    def augment(batch, noise_std, generator, signal_features):
        calls.append((batch.clone(), noise_std, signal_features))
        return _augment_inputs(batch, noise_std, generator, signal_features)
    monkeypatch.setattr(updater, '_augment_inputs', augment)
    args = updater.parser().parse_args([
        '--epochs', '1', '--checkpoint', str(tmp_path / 'updater.pt'),
        '--cnn-header', str(tmp_path / 'cnn.h'), '--header', str(tmp_path / 'q.h'),
        '--cpu-header', str(tmp_path / 'float.h'), '--report', str(tmp_path / 'report.json')])
    args.cnn_header.write_text('test')
    updater.train(args)
    assert len(calls) == 4
    assert all(noise == 0.02 and features == 60 for _, noise, features in calls)
    assert all(len(batch) == len(data[0]) for batch, _, _ in calls)
    expected = (args.header.read_bytes(), args.cpu_header.read_bytes())
    models, metadata = updater.load_checkpoint(args.checkpoint)
    assert len(models) == 4 and 'cpu_gate_snr_ratio_x16' in metadata
    assert metadata['noise_std'] == 0.02
    updater.train(args)
    repeated_models, repeated_metadata = updater.load_checkpoint(args.checkpoint)
    for model, repeated in zip(models, repeated_models):
        for name, value in model.state_dict().items():
            assert torch.equal(value, repeated.state_dict()[name])
    assert metadata['validation_loss_by_group'] == repeated_metadata['validation_loss_by_group']
    args.export_checkpoint = args.checkpoint
    updater.train(args)
    assert expected == (args.header.read_bytes(), args.cpu_header.read_bytes())
    source = args.cpu_header.read_text()
    values = re.search(r'kW1\[\d+\] = \{(.*?)\};', source, re.S)[1]
    actual = np.asarray([float(v.rstrip('f')) for v in values.replace('\n', '').split(',')], dtype=np.float32)
    want = np.stack([model.layers[0].weight.detach().numpy() for model in models]).ravel()
    np.testing.assert_array_equal(actual, want)
