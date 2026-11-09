# Shared paths, sourced by every numbered script.
#
# Expected layout (the same as on the original machine):
#   <PROJ>/3d_diffuser_actor/   this repo
#   <PROJ>/calvin/              https://github.com/mees/calvin, cloned next to it
#
# These scripts originally ran from /home/ubuntu/ROBOT_LEARNING_PROJECT/CLAUDE_SETUP_3d_Diffuser_actor/
# with PROJ hard-coded to /home/ubuntu/ROBOT_LEARNING_PROJECT. Here PROJ is derived from
# this file's location, so the scripts work wherever the repo is cloned. Override any
# variable by exporting it before running a script.
_HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DDA=${DDA:-$(cd "$_HERE/../../.." && pwd)}
PROJ=${PROJ:-$(dirname "$DDA")}
CALVIN=${CALVIN:-$PROJ/calvin}
LOGS=${LOGS:-$PROJ/setup_logs}          # build logs, pyhash build dir, probe logs
ENV_NAME=${ENV_NAME:-3d_diffuser_actor}

activate_env() {
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate "$ENV_NAME"
}

mkdir -p "$LOGS"
