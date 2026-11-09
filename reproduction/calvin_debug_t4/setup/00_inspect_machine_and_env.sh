#!/bin/bash
# Step 0: look at the machine and the existing (partially installed) env.
# Read-only. This is how the problems below were found.
source "$(dirname "$0")/common.sh"

echo "== GPU / disk / RAM / CPUs"
nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv
df -h / | tail -1
free -g | head -2
nproc
gcc --version | head -1          # gcc 13: too new for pyhash's vendored pybind11 (see 02)

echo "== conda env"
conda env list
activate_env
python -V
python -c "import torch; print(torch.__version__, torch.version.cuda, torch.cuda.is_available())"
pip list 2>/dev/null | grep -iE "torch|calvin|tacto|pyhash|dgl|flash|diffusers|open3d|numpy|hydra|lightning|transformers|cmake|pillow"

echo "== which modules import?"
for m in clip tap diffusers dgl open3d calvin_agent calvin_env blosc transformers pyhash; do
    python -c "import $m" 2>/dev/null && echo "  $m ok" || echo "  $m MISSING/BROKEN"
done

echo "== which third-party modules does 3DDA actually import? (flash_attn only in an unused converter)"
cd "$DDA"
grep -rhoE "^\s*(import|from) [a-zA-Z_0-9]+" --include=*.py . | awk '{print $2}' | sort | uniq -c | sort -rn | head -40
grep -rn "flash" --include=*.py . | head
