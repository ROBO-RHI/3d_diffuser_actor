#!/bin/bash
# Step 4: smoke test. Every import the CALVIN pipeline needs, a dgl GPU op,
# and the DiffuserActor model import.
# Expected: "torch 1.13.1 True numpy 1.23.5 pillow 10.4.0 dgl 1.1.3+cu116",
#           "dgl fps on gpu: torch.Size([1, 10])", "DiffuserActor import ok"
source "$(dirname "$0")/common.sh"
activate_env
cd "$DDA"

python -c "
import torch, numpy, PIL, clip, transformers, diffusers, dgl, dgl.geometry, open3d, pyhash, calvin_env, calvin_agent, pybullet
print('torch', torch.__version__, torch.cuda.is_available(), 'numpy', numpy.__version__, 'pillow', PIL.__version__, 'dgl', dgl.__version__)
x = torch.rand(1, 500, 3).cuda()
print('dgl fps on gpu:', dgl.geometry.farthest_point_sampler(x, 10).shape)
from diffuser_actor.trajectory_optimization.diffuser_actor import DiffuserActor
print('DiffuserActor import ok')
" 2>&1 | grep -v Warning
