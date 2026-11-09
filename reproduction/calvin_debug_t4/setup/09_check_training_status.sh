#!/bin/bash
# Quick status check for the running experiment. Safe to run any time.
source "$(dirname "$0")/common.sh"
cd "$DDA"

echo "== progress"
tr '\r' '\n' < train_logs/debug_baseline_B12.log | grep -E "it/s\]|s/it\]" | tail -1
echo "== latest validation metrics"
tr '\r' '\n' < train_logs/debug_baseline_B12.log | grep -E "^val-loss" | tail -10
echo "== checkpoints"
ls -lh train_logs/Planner_Calvin/debug_baseline_B12/*.pth 2>/dev/null
echo "== GPU / disk"
nvidia-smi --query-gpu=memory.used,utilization.gpu --format=csv,noheader
df -h / | tail -1
echo "== processes"
ps aux | grep -E 'torchrun|main_trajectory|tensorboard' | grep -v grep | awk '{print $2, $11, $12, $13}'
