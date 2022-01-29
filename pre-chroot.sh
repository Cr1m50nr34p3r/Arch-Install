#!/bin/sh
echo "#############################"
echo "### UPDATING SYSTEM CLOCK ###"
echo "#############################"
timedatectl set-ntp true
read -p "Update Mirrors: " UpMirror
case $UpMirror in
"y" | "Y")
    mirror_msg () {
        echo "########################"
        echo "### UPDATING MIRRORS ###"
        echo "########################"
        echo ""

    }
    mirror_msg
    pacman -Syy reflector rsync
    clear
    mirror_msg
    reflector --sort rate --threads $(($(nproc)+1)) -l 300 --verbose --save /etc/pacman.d/mirrorlist
    ;;
'n' | 'N' | '')
    echo "Cantinuing to Partitioning ...."
    ;;
esac
part_msg () {
	echo "####################"
	echo "### PARTITIONING ###"
	echo "####################"
	echo ""
}
part_msg
lsblk
printf "Whiich Drive do u wanna partition: "
read disk
cfdisk /dev/$disk
clear &&  part_msg
echo "FORMATTING AND MOUNTING PARTITIONS"
lsblk
printf "What is your EFI  partition: "
read efi_part
mkfs.fat -F32 /dev/$efi_part
lsblk
printf "What is your root partition: "
read root_part
mkfs.ext4 /dev/$root_part
mount /dev/$root_part /mnt
lsblk
printf "do you have a Swap: "
read is_swap
case $is_swap in
'y' | 'Y' | '')
	printf "Name of Swap Partition: "
	read swap_part
	mkswap /dev/$swap_part
	swapon /dev/$swap_part
	;;
'n' | 'N')
    echo "Not making swap partition and moving on"
    ;;
esac
clear
echo "##############################"
echo "### INSTALLING BASE SYSTEM ###"
echo "##############################"
pacstrap /mnt base linux linux-firmware linux-headers base-devel
genfstab -U /mnt >> /mnt/etc/fstab
clear
echo "COPYING SCRIPT FILES ..... "
cp -rv $HOME/Arch-Install /mnt
echo "CHANGING ROOT"
arch-chroot /mnt
