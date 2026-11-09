#!/bin/bash
# Step 3: fix Pillow and install the remaining 3D Diffuser Actor deps.  (ran in tmux window: setup)
#
# PROBLEM 1: `import clip` and `import transformers` both failed with
#   ImportError: libtiff.so.5: cannot open shared object file
# The conda-installed Pillow links against a system libtiff.so.5 that isn't on this machine.
# FIX: replace it with the self-contained pip wheel (pillow 10.4.0, last version for py3.8).
#
# PROBLEM 2: diffusers, open3d and dgl were not installed.
#
# NOT INSTALLED ON PURPOSE: flash-attn. It is only imported by
# diffuser_actor/utils/converter.py, which CALVIN training never calls, and
# FlashAttention-2 does not support the T4 (Turing, sm_75) anyway.
set -e
source "$(dirname "$0")/common.sh"
activate_env

pip install --force-reinstall --no-deps 'pillow==10.4.0'
pip install 'diffusers[torch]==0.29.2' open3d 2>&1 | tee "$LOGS/deps.log" | tail -2
pip install dgl==1.1.3+cu116 -f https://data.dgl.ai/wheels/cu116/repo.html 2>&1 | tee "$LOGS/dgl.log" | tail -2
