#!/bin/bash
# Step 1: create the tmux session everything runs in.
# Attach later with:  tmux attach -t dfa
#
# Final window layout:
#   setup        - pip installs (steps 02-04)
#   prep         - language embeddings + data packaging (step 06)
#   train        - the training run (step 08)
#   tensorboard  - TensorBoard on :6006 (step 08)
# A temporary "download" window was used for step 05 and killed afterwards.
source "$(dirname "$0")/common.sh"

tmux new-session -d -s dfa -n download -c "$CALVIN/dataset"
tmux new-window  -t dfa    -n setup    -c "$PROJ"
tmux ls
