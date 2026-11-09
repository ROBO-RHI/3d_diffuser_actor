```bash
# initiate conda env
conda update conda
conda env create -f environment.yaml
conda activate 3d_diffuser_actor

# install diffuser
pip install diffusers["torch"]

# install dgl (https://www.dgl.ai/pages/start.html)
pip install dgl==1.1.3+cu116 -f https://data.dgl.ai/wheels/cu116/dgl-1.1.3%2Bcu116-cp38-cp38-manylinux1_x86_64.whl

# install flash attention (https://github.com/Dao-AILab/flash-attention#installation-and-features)
pip install packaging
pip install ninja
pip install flash-attn==2.5.9.post1 --no-build-isolation
```

```bash
# pip install cmake==3.18.4.post1 # Not working ig
# conda install -c conda-forge cmake # Doing this as a replacement to prev command
conda remove -y cmake
python -m pip uninstall -y cmake

python -m pip install --no-cache-dir --force-reinstall "cmake==3.18.4.post1"

hash -r
cmake --version

python -c "import cmake; print(cmake.__version__); print(cmake.CMAKE_BIN_DIR)"

CMAKE_BIN="$(python -c 'import cmake; print(cmake.CMAKE_BIN_DIR)')"

"$CMAKE_BIN/cmake" --version

export PATH="$CMAKE_BIN:$PATH"
hash -r

which cmake
cmake --version

CFLAGS="-include stdint.h" CXXFLAGS="-include cstdint" python -m pip install --no-cache-dir pyhash

pip install --upgrade pip setuptools wheel
git clone --recurse-submodules https://github.com/mees/calvin.git
export CALVIN_ROOT=$(pwd)/calvin
cd calvin
cd calvin_env; git checkout main
cd ..
./install.sh; cd ..
```

```bash
# Install open3D
pip install open3d

# Install PyRep (https://github.com/stepjam/PyRep?tab=readme-ov-file#install)
git clone https://github.com/stepjam/PyRep.git 
cd PyRep/
wget https://www.coppeliarobotics.com/files/V4_1_0/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz
tar -xf CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz;
echo "export COPPELIASIM_ROOT=$(pwd)/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04" >> $HOME/.bashrc; 
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$COPPELIASIM_ROOT" >> $HOME/.bashrc;
echo "export QT_QPA_PLATFORM_PLUGIN_PATH=\$COPPELIASIM_ROOT" >> $HOME/.bashrc;
source $HOME/.bashrc;
conda activate 3d_diffuser_actor
pip install -r requirements.txt; pip install -e .; cd ..

# Install RLBench (Note: there are different forks of RLBench)
# PerAct setup
git clone https://github.com/MohitShridhar/RLBench.git
cd RLBench; git checkout -b peract --track origin/peract; pip install -r requirements.txt; pip install -e .; cd ..;
```