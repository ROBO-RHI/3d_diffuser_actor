#!/bin/bash
# Single-GPU (T4) variant of train_trajectory_calvin.sh.
# Model hyperparameters match the upstream ABC->D baseline; data paths / batch / iters are overridable:
#   DATA=packaged_debug INSTR=calvin_debug B=30 ITERS=600000 VAL_FREQ=5000 bash scripts/train_trajectory_calvin_1gpu.sh
set -e
cd "$(dirname "$0")/.."

main_dir=${MAIN_DIR:-Planner_Calvin}
DATA=${DATA:-packaged_debug}
INSTR=${INSTR:-calvin_debug}
dataset=./data/calvin/$DATA/training
valset=./data/calvin/$DATA/validation

lr=3e-4
wd=5e-3
dense_interpolation=1
interpolation_length=20
num_history=3
diffusion_timesteps=25
B=${B:-30}
ACC=${ACC:-1}            # gradient accumulation steps
C=192
ngpus=${NGPUS:-1}
backbone=clip
image_size="256,256"
relative_action=1
fps_subsampling_factor=3
lang_enhanced=1
gripper_loc_bounds=tasks/calvin_rel_traj_location_bounds_task_ABC_D.json
gripper_buffer=0.01
ITERS=${ITERS:-600000}
val_freq=${VAL_FREQ:-5000}
quaternion_format=wxyz
NUM_WORKERS=${NUM_WORKERS:-3}

run_log_dir=${RUN_NAME:-$DATA-C$C-B$B-ACC$ACC-lr$lr-DI$dense_interpolation-$interpolation_length-H$num_history-DT$diffusion_timesteps-backbone$backbone-S$image_size-R$relative_action-wd$wd}

export PYTHONPATH=$(pwd):$PYTHONPATH

torchrun --nproc_per_node $ngpus --master_port $((29500 + RANDOM % 1000)) \
    main_trajectory_calvin.py \
    --tasks A B C D \
    --backbone $backbone \
    --dataset $dataset \
    --valset $valset \
    --instructions instructions/$INSTR/ \
    --gripper_loc_bounds $gripper_loc_bounds \
    --gripper_loc_bounds_buffer $gripper_buffer \
    --image_size $image_size \
    --num_workers $NUM_WORKERS \
    --max_episode_length 30 \
    --train_iters $ITERS \
    --embedding_dim $C \
    --use_instruction 1 \
    --rotation_parametrization 6D \
    --diffusion_timesteps $diffusion_timesteps \
    --val_freq $val_freq \
    --val_iters 2 \
    --dense_interpolation $dense_interpolation \
    --interpolation_length $interpolation_length \
    --exp_log_dir $main_dir \
    --batch_size $B \
    --accumulate_grad_batches $ACC \
    --batch_size_val 3 \
    --cache_size 0 \
    --cache_size_val 0 \
    --keypose_only 0 \
    --variations {0..0} \
    --lr $lr \
    --wd $wd \
    --num_history $num_history \
    --cameras front wrist \
    --max_episodes_per_task -1 \
    --relative_action $relative_action \
    --fps_subsampling_factor $fps_subsampling_factor \
    --lang_enhanced $lang_enhanced \
    --quaternion_format $quaternion_format \
    --run_log_dir $run_log_dir
