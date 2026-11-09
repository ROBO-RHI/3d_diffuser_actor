#!/bin/bash
# Step 5b: download + extract the CALVIN debug dataset.  (ran in tmux window: download,
# started right after step 1 so it downloaded while steps 2-4 ran)
#
# Contents after extraction (calvin/dataset/calvin_debug_dataset/):
#   training/    2777 files, 9 language annotations, scene D only
#   validation/  1681 files, 8 language annotations
#
# NOTE: `unzip` is not installed on this machine (and needs sudo), so the
# archive is extracted with Python's zipfile instead.
set -e
source "$(dirname "$0")/common.sh"
cd "$CALVIN/dataset"

wget -q --show-progress http://calvin.cs.uni-freiburg.de/dataset/calvin_debug_dataset.zip
python -c "import zipfile; zipfile.ZipFile('calvin_debug_dataset.zip').extractall('.')"
rm calvin_debug_dataset.zip
echo EXTRACT_DONE

# sanity check
activate_env
D=$CALVIN/dataset/calvin_debug_dataset
ls "$D/training" | wc -l; ls "$D/validation" | wc -l
python -c "
import numpy as np
for s in ['training', 'validation']:
    a = np.load('$D/' + s + '/lang_annotations/auto_lang_ann.npy', allow_pickle=True).item()
    print(s, len(a['info']['indx']), 'annotations')
print(np.load('$D/training/scene_info.npy', allow_pickle=True).item())
"
