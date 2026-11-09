#!/bin/bash
# Step 6: produce the two inputs the training script expects but which didn't exist:
#   instructions/calvin_debug/{training,validation}.pkl   CLIP embeddings of the language annotations
#   data/calvin/packaged_debug/{training,validation}/D+0/ann_*.dat   packaged episodes
# (ran in tmux window: prep)
#
# The 3DDA scripts use paths like ./calvin/dataset/..., i.e. they expect CALVIN
# *inside* the repo. Ours sits next to it, so add a symlink.
#
# package_calvin.py renders point clouds through the CALVIN pybullet env (EGL on the T4).
# It ends with a harmless "pybullet.error: Not connected to physics server" from the
# env's __del__. Exit code is still 0.
set -e
source "$(dirname "$0")/common.sh"
activate_env
cd "$DDA"

ln -sfn ../calvin calvin
export PYTHONPATH=$(pwd):$PYTHONPATH
R=./calvin/dataset/calvin_debug_dataset

for s in training validation; do
    python data_preprocessing/preprocess_calvin_instructions.py \
        --output instructions/calvin_debug/$s.pkl \
        --model_max_length 16 \
        --annotation_path $R/$s/lang_annotations/auto_lang_ann.npy

    python data_preprocessing/package_calvin.py \
        --split $s \
        --root_dir $R \
        --save_path ./data/calvin/packaged_debug
done
echo PREP_DONE

find instructions/calvin_debug data/calvin/packaged_debug -type f
