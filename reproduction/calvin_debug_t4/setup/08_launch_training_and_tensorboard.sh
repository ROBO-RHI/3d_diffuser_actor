#!/bin/bash
# Step 8: launch the debug-data baseline run and TensorBoard inside tmux.
#
# Run:   B=12, 20,000 iters, validate + checkpoint every 2,000 iters
# Output: 3d_diffuser_actor/train_logs/Planner_Calvin/debug_baseline_B12/
#         3d_diffuser_actor/train_logs/debug_baseline_B12.log   (stdout)
# Each checkpoint is ~257 MB, so 10 numbered checkpoints + best/last ~= 3 GB.
source "$(dirname "$0")/common.sh"

tmux new-window -t dfa -n train -c "$DDA" 2>/dev/null || true
tmux send-keys -t dfa:train \
  "source ~/miniconda3/etc/profile.d/conda.sh && conda activate $ENV_NAME && clear; \
B=12 ITERS=20000 VAL_FREQ=2000 RUN_NAME=debug_baseline_B12 bash scripts/train_trajectory_calvin_1gpu.sh 2>&1 \
| tee train_logs/debug_baseline_B12.log; echo TRAIN_EXIT=\${PIPESTATUS[0]}" Enter

tmux new-window -d -t dfa -n tensorboard -c "$DDA"
tmux send-keys -t dfa:tensorboard \
  "source ~/miniconda3/etc/profile.d/conda.sh && conda activate $ENV_NAME && tensorboard --logdir train_logs --port 6006 --bind_all" Enter

tmux kill-window -t dfa:download 2>/dev/null || true
tmux select-window -t dfa:train
tmux list-windows -t dfa
