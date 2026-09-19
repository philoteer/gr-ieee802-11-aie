# AGENTS.md (stage39)

The repository-wide agent instructions live at `../AGENTS.md`. Read that file
before working here: it maps the kernel/test/utils files, documents the
`xchesscc` build limits (`JOBS` never above 2, one build at a time), the
`test/` + `utils/` + `grcc` correctness workflow, and the kernel profiling
method.

The learned demapper is compile-time selectable with `ENGINE=AI` plus `MODEL`
(`MLP_16X16` or `MLP_16`). Architectures live in `kernel/engine/model/`,
including the selector `frame_equalizer_model.h` and one
`frame_equalizer_model_<name>.h` per model; `utils/frame_equalizer_ai/`
trains/exports them with `--model`, and each Makefile lists the names in
`SUPPORTED_MODELS`.

Never update comments, docstrings, or documentation while making functional
changes unless explicitly asked; comment churn makes diffs hard to review.
