```bash
sudo apt update
sudo apt install -y pciutils ubuntu-drivers-common linux-headers-$(uname -r)

lspci | grep -i nvidia
```

```bash
ubuntu-drivers devices
ubuntu-drivers list --gpgpu

sudo ubuntu-drivers --gpgpu install
sudo reboot
```

```bash
nvidia-smi
lsmod | grep nvidia
```

```bash
sudo apt install nvtop
```