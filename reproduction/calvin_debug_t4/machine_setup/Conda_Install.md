```bash
sudo apt update
sudo apt install -y curl bzip2

cd /tmp
curl -fsSLO "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh"

bash "Miniconda3-latest-Linux-$(uname -m).sh" \
  -b \
  -p "$HOME/miniconda3"

"$HOME/miniconda3/bin/conda" init bash
source "$HOME/.bashrc"
```

```bash
conda --version
which conda
```

```bash
conda config --set auto_activate_base true
source "$HOME/.bashrc"
```