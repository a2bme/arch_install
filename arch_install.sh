# == MY ARCH SETUP INSTALLER == #
#part1
printf '\033c'
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
printf "\e[0;34mEnter the drive: \e[0m" 
read drive
cfdisk $drive 
printf "\e[0;34mEnter the EFI partition: \e[0m" 
read efipartition
mkfs.fat -F32 $efipartition 
read -p "Did you also create swap partition? [y/n]" answer
if [[ $answer = y ]] ; then
  printf "\e[0;34mEnter swap partition: \e[0m" 
  read swappartition
  mkswap $swappartition
  swapon $swappartition
fi
printf "\e[0;34mEnter the linux filesystem partition: \e[0m" 
read partition
mkfs.ext4 $partition 
echo "mounting $partition to /mnt"
mount $partition /mnt 
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2/d'  arch_install.sh > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 

#part2 
printf '\033c'
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
printf "\e[0;34mHostname: \e[0m"
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd
pacman --noconfirm -S grub efibootmgr os-prober
printf "\e[0;34mEnter EFI partition: \e[0m"
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm xorg-server xorg-xprop xorg-xkill \
    xfce4 xfce4-goodies cmatrix htop git man-db mpv \
    zip unzip pipewire pipewire-pulse networkmanager firefox
    
systemctl enable NetworkManager.service 

echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
printf "\e[0;34mEnter Username: \e[0m"
read username
useradd -m -G wheel -s /bin/zsh $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit 

#part3
printf '\033c'
cd $HOME
echo "setup is done now you can restart the pc"
exit
