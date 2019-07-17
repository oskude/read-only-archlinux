# read-only-archlinux

experimenting with read-only root filesystem for archlinux desktop system.

this repo (makefile) creates a disk image (roarch.disk), installs archlinux (files) on it and boots it with qemu.

**IMPORTANT: many commands in the makefile require sudo for root rights, so if we want to review and confirm those commands, change the line in makefile to `SUDO = sudo -k`, or something...** _(would be nice if make or sudo could provide a simple y/n confirmation)_

## build

we need an archlinux host with following packages installed: `arch-install-scripts dosfstools e2fsprogs gptfdisk ovmf qemu rsync sudo util-linux `

we also need the nbd kernel module on the host _(cause qemu-nbd uses less ram than losetup)_: `sudo -k modprobe nbd`

to build everything, or update an already build image, run:

```
> make
```

> if `make` fails, run `make unmount` before running again. or `make clean` to start all over.

## test

to boot the build image in qemu, run:

```
> make test
```

## files

the `files` directory contains files that will be copied to the disk image.

| path | why |
|------|------|
| boot/ | bootloader config. we dont actually care. TODO: can we automatically create the loader config and entries? |
| etc/fstab | crucial mount points |
| etc/mkinitcpio.conf | TODO: "autodetect" doesnt add our fs mods? |
| etc/mkinitcpio.d/linux.preset | just to save time, removed "fallback" image |
| etc/packages.list | custom list of pacman packages to install |
| etc/resolv.conf | lazy dns |
| etc/systemd/network/99-wired.network | setup dhcp on wired network devices |
| etc/systemd/system/multi-user.target.wants/systemd-networkd.service | start network devices |
| usr/local/bin/remount-read | script to re-mount important paths read-only |
| usr/local/bin/remount-write | script to re-mount important paths read-write |
