#!/bin/bash
# Step 5a: check how big the CALVIN splits are before downloading anything.
#
# Result on 2026-11-03:
#   task_ABC_D            555.3 GB   (zipped; the upstream baseline)
#   task_D_D              177.4 GB
#   calvin_debug_dataset    1.3 GB   <- the only one that fits in ~71 GB free disk
#
# Also checked whether the 3DDA authors publish *packaged* CALVIN data on
# HuggingFace (would skip the raw download). They don't: the model repo only has
# Peract_packaged.zip (44.75 GB, RLBench), checkpoints incl. diffuser_actor_calvin.pth
# (0.19 GB), and instructions.zip (0.88 GB).

for f in task_ABC_D task_D_D calvin_debug_dataset; do
    echo -n "$f: "
    curl -sI --max-time 20 "http://calvin.cs.uni-freiburg.de/dataset/$f.zip" | grep -i content-length
done

curl -s --max-time 20 "https://huggingface.co/api/models/katefgroup/3d_diffuser_actor/tree/main" \
  | python -c "import json,sys; [print(f\"{x['path']:45s} {x.get('size',0)/1e9:8.2f} GB\") for x in json.load(sys.stdin)]"
