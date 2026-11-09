#!/bin/bash
# Step 7: short 40-iteration runs to find a batch size that fits the 16 GB T4,
# and confirm the full train -> validate -> checkpoint loop works.  (ran in tmux window: train)
#
# Results:
#   B=30 (upstream per-GPU batch, on 6 big GPUs)  -> CUDA OOM
#   B=12                                           -> works, peak 13,777 MiB of 15,360 MiB,
#                                                     steady state ~2.3 s/it
# The probe output dir (train_logs/probe) was deleted afterwards.
source "$(dirname "$0")/common.sh"
activate_env
cd "$DDA"

MEMLOG=$LOGS/probe_gpu_mem.txt

for BS in 30 12; do
    : > "$MEMLOG"
    # sample GPU memory in the background while the probe runs
    ( while true; do nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits >> "$MEMLOG"; sleep 2; done ) &
    SAMPLER=$!

    B=$BS ITERS=40 VAL_FREQ=20 MAIN_DIR=probe RUN_NAME=probe_b$BS \
        bash scripts/train_trajectory_calvin_1gpu.sh 2>&1 | tee "$LOGS/probe_b$BS.log"
    echo "B=$BS exit=${PIPESTATUS[0]}"

    kill $SAMPLER
    echo "B=$BS peak MiB: $(sort -n "$MEMLOG" | tail -1)"
done

# steady-state speed
tr '\r' '\n' < "$LOGS/probe_b12.log" | grep -E "^\s*[0-9]+%.*it" | awk 'NR%4==0'

rm -rf train_logs/probe
