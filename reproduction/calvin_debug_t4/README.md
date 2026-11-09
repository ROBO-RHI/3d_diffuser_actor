# 3D Diffuser Actor on CALVIN (debug dataset, 1× T4): exact reproduction record

This folder records everything that was run to install 3D Diffuser Actor (3DDA), prepare CALVIN data and train one model on a single Tesla T4 between 2026-10-30 and 2026-11-04. It includes the commands, the fixes, the exact package versions, the logs and the results.

> **This is a pipeline test, not a reproduction of the paper.** Training used CALVIN's 1.3 GB *debug* dataset: scene D only, with 9 training and 8 validation language annotations. The paper's ABC→D split is 555 GB zipped and didn't fit on the 96 GB disk. The run shows that the code trains end to end on this hardware. It says nothing about the paper's results. See [Results](#results) and [Comparison with the paper](#comparison-with-the-paper).

## Contents

| Path | What it is |
|---|---|
| [machine_setup/](machine_setup/) | Machine bootstrap done by hand first: NVIDIA driver, Miniconda, apt packages |
| [../../SETUP_Steps/README.md](../../SETUP_Steps/README.md) | First attempt at the upstream install: conda env, cmake 3.18, CALVIN clone. Its pyhash workaround didn't work; see step 02 |
| [setup/](setup/) | Numbered scripts `00`–`09`: every command run after that, in order. Each script's header says what was broken and why the fix works |
| [../../scripts/train_trajectory_calvin_1gpu.sh](../../scripts/train_trajectory_calvin_1gpu.sh) | New single-GPU training script; the run used this |
| [environment/](environment/) | `conda env export`, `pip freeze`, system info, and the commits of every source repo |
| [patches/](patches/) | The two source patches applied outside this repo: pyhash and CALVIN `install.sh` |
| [logs/setup/](logs/setup/) | Raw logs of every install attempt, failed ones included, and the batch-size probes |
| [results/debug_baseline_B12/](results/debug_baseline_B12/) | Training stdout, `hparams.json`, TensorBoard events, and `metrics.csv` (every train/val metric at every validation) |

**Not in git:** model checkpoints (12 × 257 MB, over GitHub's 100 MB file limit), the CALVIN dataset, packaged data (`data/`) and instruction embeddings (`instructions/*.pkl`). Steps 05b–06 regenerate the data, and step 08 regenerates the checkpoints.

## Hardware and software

| | |
|---|---|
| Machine | AWS, Ubuntu 24.04.5, kernel 7.0.0-1014-aws, gcc 13.3.0 |
| GPU | 1× Tesla T4 16 GB, driver 595.99.02 |
| CPU / RAM / disk | 4 vCPU / 15 GB / 96 GB (~71 GB free at start) |
| Env | conda `3d_diffuser_actor`: Python 3.8.20, torch 1.13.1 + CUDA 11.6, cuDNN 8.3.2 |
| Key packages | numpy 1.23.5, pillow 10.4.0, dgl 1.1.3+cu116, diffusers 0.29.2, open3d 0.19.0, transformers 4.46.3, pytorch-lightning 1.8.6, hydra-core 1.1.1, pyhash 0.9.3 (patched) |

Full lists: [environment/pip_freeze.txt](environment/pip_freeze.txt), [environment/conda_env_export.yml](environment/conda_env_export.yml), [environment/system_info.txt](environment/system_info.txt).

### Source versions

| Repo | Commit | Notes |
|---|---|---|
| [nickgkan/3d_diffuser_actor](https://github.com/nickgkan/3d_diffuser_actor) | `4faf00bdf89a3b3d07e266a59a28f9fbd02c7844` | Base of this fork. No upstream Python files were changed |
| [mees/calvin](https://github.com/mees/calvin) | `fa03f01f19c65920e18cf37398a9ce859274af76` | Cloned at `../calvin`, next to this repo. `install.sh` changed `cmake==3.18.4` → `cmake==3.18.4.post1` ([patch](patches/calvin_install_sh.patch)) |
| [mees/calvin_env](https://github.com/mees/calvin_env) | `797142c588c21e76717268b7b430958dbd13bf48` | Submodule, checked out to `main` as the 3DDA README says (CALVIN pins `1431a46`) |
| [openai/CLIP](https://github.com/openai/CLIP) | `d05afc436d78f1c48dc0dbf8e5980a9d471f35f6` | |

## How to reproduce

Directory layout:

```
<PROJ>/
├── 3d_diffuser_actor/   this repo
└── calvin/              git clone --recurse-submodules https://github.com/mees/calvin.git
                         (cd calvin/calvin_env && git checkout main)
```

1. **Machine.** Follow [machine_setup/](machine_setup/): `NVIDIA_INSTALL.md`, `Conda_Install.md`, `Some_More_Setups.md`.
2. **Base env.** Follow [SETUP_Steps/README.md](../../SETUP_Steps/README.md) up to and including `cd calvin && ./install.sh`. Use `cmake==3.18.4.post1`, and **skip** the `CFLAGS=... pip install pyhash` line (it fails) and `flash-attn` (not needed; see below). `calvin_env` and `tacto` install here. `calvin_models` fails on pyhash, and step 02 fixes that.
3. **Run the numbered scripts** in [setup/](setup/), in order:

| Script | What it does | Time |
|---|---|---|
| `00_inspect_machine_and_env.sh` | Read-only checks: GPU, disk, packages, which imports fail | – |
| `01_create_tmux_session.sh` | Creates tmux session `dfa` | – |
| `02_build_pyhash_and_install_calvin_models.sh` | Patches and builds pyhash 0.9.3, then `pip install -e calvin/calvin_models` | ~10 min |
| `03_fix_pillow_and_install_3dda_deps.sh` | Reinstalls pillow 10.4.0; installs diffusers 0.29.2, open3d, dgl 1.1.3+cu116 | ~5 min |
| `04_verify_environment.sh` | Imports everything, runs a dgl GPU op, imports `DiffuserActor` | – |
| `05a_check_dataset_sizes.sh` | Reports CALVIN split sizes; read-only | – |
| `05b_download_calvin_debug_dataset.sh` | Downloads and extracts the debug dataset (1.3 GB) | ~10 min |
| `06_preprocess_instructions_and_package_data.sh` | Adds symlink `calvin → ../calvin`, computes CLIP instruction embeddings, packages episodes | ~5 min |
| `07_probe_batch_size.sh` | 40-iteration runs at B=30 and B=12 | ~10 min |
| `08_launch_training_and_tensorboard.sh` | The training run and TensorBoard, in tmux | 10 h 16 min |
| `09_check_training_status.sh` | Shows progress, metrics, checkpoints, GPU and disk | – |

05b was started right after 01, so the download ran while 02–04 installed.

The exact training command (run from the repo root):

```bash
B=12 ITERS=20000 VAL_FREQ=2000 RUN_NAME=debug_baseline_B12 \
  bash scripts/train_trajectory_calvin_1gpu.sh 2>&1 | tee train_logs/debug_baseline_B12.log
```

## What was broken and how it was fixed

1. **pyhash 0.9.3 doesn't compile with gcc 13**, which blocks `calvin_models`. The error is `attr.h:185: 'uint16_t' in namespace 'std' does not name a type`. The `CFLAGS='-include stdint.h' CXXFLAGS='-include cstdint'` workaround in `SETUP_Steps` doesn't work: distutils compiles the `.cpp` files with `CFLAGS` only, so they get `stdint.h`, which doesn't define `std::uint16_t`. **Fix:** add `#include <cstdint>` to the vendored pybind11 `attr.h` ([patch](patches/pyhash-0.9.3-gcc13-cstdint.patch)) and run `pip install --no-build-isolation` from the patched sdist. The failed and successful builds are in `logs/setup/pyhash*.log` and `calvin_models*.log`.
2. **The conda Pillow needs `libtiff.so.5`, which isn't installed.** That broke `import clip` and `import transformers`. **Fix:** `pip install --force-reinstall --no-deps pillow==10.4.0`. The pip wheel bundles its libraries, and 10.4.0 is the last release for Python 3.8.
3. **Missing packages:** `diffusers[torch]==0.29.2`, `open3d`, `dgl==1.1.3+cu116`.
4. **flash-attn was skipped on purpose.** Only `diffuser_actor/utils/converter.py` imports it, and CALVIN training never calls that file. FlashAttention-2 doesn't support the T4 (sm_75) anyway.
5. **No `unzip`** (installing it needs sudo). The data was extracted with Python's `zipfile`.
6. **Path expectations.** The 3DDA scripts expect `./calvin/dataset/...` inside the repo, so step 06 adds the symlink `calvin → ../calvin`, which is git-ignored. `package_calvin.py` ends with a harmless `pybullet.error: Not connected to physics server` from the env destructor and still exits 0.
7. **The upstream script assumes 6 GPUs.** `scripts/train_trajectory_calvin.sh` runs 6 GPUs at B=30 each, with hard-coded ABC_D paths, `CUDA_LAUNCH_BLOCKING=1`, and evaluation at the end. The new `scripts/train_trajectory_calvin_1gpu.sh` keeps **every model hyperparameter the same** (lr 3e-4, wd 5e-3, C=192, history 3, 25 diffusion steps, CLIP backbone, 256×256, 6D rotation, relative actions, dense interpolation 20, front and wrist cameras, fps subsampling 3, lang_enhanced). The rest can be set with env vars (`B`, `ACC`, `ITERS`, `VAL_FREQ`, `DATA`, `INSTR`, `RUN_NAME`, `MAIN_DIR`, `NGPUS`, `NUM_WORKERS`). It drops `CUDA_LAUNCH_BLOCKING` and the evaluation step.
8. **Batch size on the T4.** B=30 runs out of memory. B=12 fits, with a peak of 13,777 of 15,360 MiB ([probe logs](logs/setup/)). The effective batch is 12, against 6 × 30 = 180 upstream.

## Results

Run `debug_baseline_B12`: B=12, 20,000 iterations, validation and checkpoint every 2,000. It took 10 h 15 min 41 s (1.85 s/it) and exited 0. All numbers are offline: predicted against demonstrated trajectories on held-out debug episodes. No simulator rollouts were run.

| Step | val traj pos L2 (m) | val pos acc <1 cm | val traj rot L1 | val gripper acc | train traj pos L2 | train pos acc <1 cm |
|---|---|---|---|---|---|---|
| 2,000 | 0.029 | 0.340 | 0.072 | 0.821 | 0.013 | 0.657 |
| 4,000 | 0.029 | 0.350 | 0.074 | 0.739 | 0.006 | 0.855 |
| 6,000 | 0.031 | 0.359 | 0.072 | 0.739 | 0.004 | 0.956 |
| 8,000 | 0.031 | 0.317 | 0.098 | 0.700 | 0.004 | 0.953 |
| 10,000 | 0.031 | 0.331 | 0.097 | 0.758 | 0.004 | 0.977 |
| 12,000 | 0.031 | 0.352 | 0.083 | 0.736 | 0.004 | 0.973 |
| 14,000 | 0.031 | 0.346 | 0.091 | 0.681 | 0.005 | 0.973 |
| 16,000 | 0.033 | 0.342 | 0.100 | 0.679 | 0.005 | 0.977 |
| 18,000 | 0.032 | 0.341 | 0.102 | 0.662 | 0.004 | 0.982 |
| 20,000 | 0.036 | 0.320 | 0.097 | 0.746 | 0.005 | 0.974 |

All metrics are in [metrics.csv](results/debug_baseline_B12/metrics.csv). The log prints steps as `Step 1999`, `Step 3999`, …, and checkpoints are named to match (`0001999.pth`, …).

**What the numbers show:**
- **Training error** falls to 4–5 mm, and 97% of predicted points land within 1 cm.
- **Validation error** stays at about 3 cm, with about 33% of points within 1 cm, and slowly gets worse after about 6k steps.
- **Interpretation:** with 9 training demos, the model memorises them. This overfitting is expected and doesn't point to a bug.
- **Noise:** each validation uses only about 15 samples (5 batches of 3), so changes between steps are mostly noise.

**Metric definitions** (`main_trajectory.py`, `compute_metrics`):

| Metric | Definition |
|---|---|
| `traj_pos_l2` | Mean Euclidean position error over the predicted trajectory |
| `traj_pos_acc_001` | Fraction of points within 0.01 m |
| `traj_rot_l1` | Sign-invariant L1 distance between quaternions |
| `traj_gripper` | Open/close accuracy |
| `pos_l2_final`, `rot_l1` | The same errors at the last trajectory point only |

### Known issue: `best.pth` is not the best checkpoint

`main_trajectory.py:287` returns `values.get('val-losses/traj_pos_acc_001')`, but the metrics are logged as `val-losses/mean/...`. The lookup therefore always returns `None`, and `engine.save_checkpoint` overwrites `best.pth` at every validation. In this run, `best.pth` is the step-20,000 model, the same as `last.pth`. Separately, `engine.py:217` keeps the *lowest* value (`new_loss <= best_loss`), which is the wrong direction for an accuracy. Neither line is fixed here. To use an early checkpoint, pick a numbered one such as `0005999.pth`.

## Comparison with the paper

There's no direct comparison: the paper measures something different, at a much larger scale.

| | Paper, CALVIN ABC→D | This run |
|---|---|---|
| Train data | Scenes A, B, C (~18k annotated episodes) | Scene D debug set, 9 episodes |
| Test | 1,000 chains of 5 instructions in the simulator, unseen scene D | Offline trajectory error on 8 debug validation episodes, same scene |
| Compute | 6 GPUs × B=30 × 600k iterations (~108M samples) | 1 T4 × B=12 × 20k iterations (~240k samples, ~0.2%) |
| Headline metric | Average successful chain length **3.27** / 5 | Not measured |

## What a real baseline needs

1. **Disk.** `task_ABC_D` is 555 GB zipped (`task_D_D` is 177 GB), and the packaged data is bigger still. That needs a ≥1 TB volume, or extracting only part of the zip remotely.
2. **GPU.** 600k iterations at 1.85 s/it on one T4 would take about 13 days, with a 15× smaller batch. Use more or bigger GPUs, or set `ACC` for gradient accumulation.
3. **Checkpoint disk use.** Each validation saves a ~257 MB checkpoint, so raise `VAL_FREQ` on long runs.
4. **Evaluation.** Run the simulator evaluation section of `scripts/train_trajectory_calvin.sh` (`online_evaluation_calvin/`). The authors' checkpoint `diffuser_actor_calvin.pth` (HuggingFace `katefgroup/3d_diffuser_actor`) can test the evaluation pipeline without training, but evaluation needs the scene-D validation data from the full dataset.
