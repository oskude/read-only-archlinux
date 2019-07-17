.PHONY: all test clean mount unmount

SUDO = sudo

all: roarch.disk
	make mount
	$(SUDO) rsync -rlptv --exclude="/boot" files/ mnt/
	$(SUDO) rsync -rutv files/boot/ mnt/boot/
	$(SUDO) pacstrap -c mnt --needed $(shell grep '^[^# ]' files/etc/packages.list)
	$(SUDO) mkdir -p mnt/boot/efi/boot
	$(SUDO) cp mnt/usr/lib/systemd/boot/efi/systemd-bootx64.efi mnt/boot/efi/boot/bootx64.efi
	$(SUDO) sync
	make unmount

test: efi_vars.bin
	qemu-system-x86_64 -enable-kvm -m 1G -soundhw hda -drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/x64/OVMF_CODE.fd -drive if=pflash,format=raw,file=efi_vars.bin -drive file=roarch.disk,format=raw

clean:
	make unmount
	rm roarch.disk
	rm efi_vars.bin

mount:
	$(SUDO) qemu-nbd -n -c /dev/nbd0 -f raw roarch.disk
	$(SUDO) sync
	$(SUDO) mount /dev/nbd0p2 mnt
	$(SUDO) mkdir mnt/boot || true
	$(SUDO) mount /dev/nbd0p1 mnt/boot

unmount:
	$(SUDO) umount -R mnt || true
	$(SUDO) qemu-nbd -d /dev/nbd0 || true

efi_vars.bin:
	cp /usr/share/ovmf/x64/OVMF_VARS.fd efi_vars.bin

roarch.disk:
	fallocate -l 4GB roarch.disk
	sgdisk roarch.disk --zap-all
	sgdisk roarch.disk -n 0:0:+200MB -t 0:EF00 -c 0:roarch_boot
	sgdisk roarch.disk -n 0:0:0      -t 0:8304 -c 0:roarch_root
	$(SUDO) qemu-nbd -n -c /dev/nbd0 -f raw roarch.disk
	$(SUDO) sync
	$(SUDO) mkfs.vfat /dev/nbd0p1
	$(SUDO) mkfs.ext4 /dev/nbd0p2
	$(SUDO) sync
	make unmount
