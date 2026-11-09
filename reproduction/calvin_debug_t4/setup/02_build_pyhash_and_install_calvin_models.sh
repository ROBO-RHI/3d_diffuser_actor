#!/bin/bash
# Step 2: fix pyhash, then install calvin_models.  (ran in tmux window: setup)
#
# PROBLEM: `pip install -e calvin/calvin_models` fails because its dependency
# pyhash 0.9.3 does not compile with gcc 13:
#   src/pybind11/include/pybind11/attr.h:185: error: 'uint16_t' in namespace 'std' does not name a type
# pyhash vendors an old pybind11 that relies on <cstdint> being pulled in transitively.
#
# WHAT DIDN'T WORK (the workaround in 3d_diffuser_actor/SETUP_Steps):
#   CFLAGS='-include stdint.h' CXXFLAGS='-include cstdint' pip install pyhash
# distutils compiles pyhash's .cpp files with CFLAGS only, so the C++ files get
# `-include stdint.h`, which does not define std::uint16_t. Same error.
#
# FIX: download the pyhash sdist, add `#include <cstdint>` to the vendored
# pybind11 attr.h, and pip install from that patched directory.
set -e
source "$(dirname "$0")/common.sh"
activate_env

# MulticoreTSNE (another calvin_models dep) needs the old pip-installed cmake 3.18 first on PATH
export PATH=$(python -c 'import cmake; print(cmake.CMAKE_BIN_DIR)'):$PATH
cmake --version | head -1

# --- patch + build pyhash ---
BUILD=$LOGS/pyhash_build
mkdir -p "$BUILD" && cd "$BUILD"
pip download --no-deps --no-binary :all: pyhash==0.9.3 -d . -q
tar xzf pyhash-0.9.3.tar.gz
sed -i '0,/#pragma once/s//#pragma once\n#include <cstdint>/' \
    pyhash-0.9.3/src/pybind11/include/pybind11/attr.h
head -15 pyhash-0.9.3/src/pybind11/include/pybind11/attr.h | grep -n "cstdint\|pragma"

pip install --no-build-isolation --no-cache-dir "$BUILD/pyhash-0.9.3" 2>&1 | tee "$LOGS/pyhash2.log"
python -c 'import pyhash; print("PYHASH_OK", pyhash.fnv1_32()("abc"))'

# --- now calvin_models installs (pulls MulticoreTSNE, pytorch-lightning 1.8.6, hydra 1.1.1, ...) ---
cd "$CALVIN/calvin_models"
pip install -e . 2>&1 | tee "$LOGS/calvin_models3.log"
echo "EXIT=${PIPESTATUS[0]}"
