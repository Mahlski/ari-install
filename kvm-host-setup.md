# KVM Host Setup (AMD)

One-time setup per machine. Run before creating any VMs.

Tested on ari7 (AMD Ryzen 7 7800X3D + NVIDIA RTX 4090, Arch Linux). For Intel hosts, swap `svm` / `kvm_amd` for `vmx` / `kvm_intel` throughout.

## Prereqs

- BIOS: AMD SVM enabled (verified: `svm` flag in `/proc/cpuinfo`, `/dev/kvm` exists, `kvm_amd` loaded, nested virt = `Y`)

Quick check:

```fish
grep -c svm /proc/cpuinfo          # > 0
lsmod | grep '^kvm_amd'            # kvm_amd present
ls -la /dev/kvm                    # crw-rw-rw- root kvm
cat /sys/module/kvm_amd/parameters/nested   # 1 (Y)
```

## Important — interactive terminal required

Install script uses `sudo` for `pacman`, `usermod`, `systemctl`, `virsh`. **Must be run in an interactive terminal** (kitty / login shell). Running via Claude Code's Bash tool fails silently — sudo refuses to prompt for password without TTY:

```
sudo: a terminal is required to read the password
```

Same applies to `create-arch-vm.fish` and `reset-arch-vm.fish` (both invoke `sudo`). Always run these from your own terminal, not from inside an assistant tool call.

## Steps

1. **Install host stack** — run interactively

   ```fish
   fish ~/.local/bin/vm/install-vm-stack.fish
   ```

   Installs: `qemu-base qemu-desktop libvirt virt-install virt-manager virt-viewer edk2-ovmf dnsmasq dmidecode swtpm libosinfo`. Adds `$USER` to `libvirt` group. Enables `libvirtd.socket` + `virtlogd.socket`. Activates `default` NAT network.

   Script is idempotent — safe to re-run after partial failure. Will skip already-installed packages, ignore already-enabled units, ignore already-active network.

   Expected sudo prompts:
   - `pacman -S --needed --noconfirm <packages>`
   - `usermod -aG libvirt $USER`
   - `systemctl enable --now libvirtd.socket virtlogd.socket`
   - `virsh net-autostart default` + `virsh net-start default`
   - `virsh net-list --all` (final verification)

2. **Logout + login (full Hyprland session)**
   - Required so virt-manager GUI + bare `virsh` inherit new `libvirt` group
   - Alternative for single shell only: `newgrp libvirt`
   - Reboot NOT needed

3. **Verify group + socket access**

   ```fish
   id | grep libvirt
   virsh -c qemu:///system list --all
   ```

   Both must succeed without sudo.

## Post-install verification

```fish
# group membership
id | grep libvirt

# socket access (no sudo)
virsh -c qemu:///system list --all

# default network active
virsh -c qemu:///system net-list --all
# expect:  default   active   yes (autostart)   nat

# OVMF firmware present
ls /usr/share/edk2/x64/OVMF_CODE.4m.fd

# KVM acceleration usable
qemu-system-x86_64 -accel help | grep kvm
```

All five must succeed before running `create-arch-vm.fish`.

## Migrating ISO from old `~/.cache` location

One-time move if ISO was downloaded to old path:

```fish
sudo mkdir -p /var/lib/libvirt/images/iso
sudo mv ~/.cache/iso/archlinux-x86_64.iso /var/lib/libvirt/images/iso/
sudo chown libvirt-qemu:libvirt-qemu /var/lib/libvirt/images/iso/archlinux-x86_64.iso
fish ~/.local/bin/vm/fetch-arch-iso.fish   # re-verifies checksum, no re-download
```

## Failure surfaces

- **sudo password prompt fails** → not running in interactive terminal. Run script from kitty/login shell, not from assistant tool call.
- **`virsh -c qemu:///system list --all` fails permission after install** → not relogged yet, libvirt group not active. Logout + login.
- **`'svm' flag not in /proc/cpuinfo`** → SVM disabled in BIOS. Reboot, enable under CPU / Advanced / SVM Mode (ASUS) or equivalent, retry.

## Known VM-vs-bare-metal caveats

Guest is virtio-only — no host GPU passthrough in this setup. So:

- GPU-bound packages installed in guest are inert: `nvidia-utils`, `vulkan-radeon`, `intel-media-driver`, etc. Install OK, won't accelerate anything in a virtio-gpu guest.
- Laptop-only hardware-tied packages (`tlp`, `powertop`, `brightnessctl`, `acpi`, `bluez*`) install OK in guest but have no hardware to manage.
- Hyprland may fail to start a session in a virtio-gpu guest. Install step still succeeds; runtime is the issue.
- Any hostname-gated config (e.g. peripheral-specific fixes) is skipped automatically in VM since the VM has its own hostname.

For host GPU passthrough (NVIDIA VFIO, etc.), this doc does not cover it — different setup, different failure modes.
