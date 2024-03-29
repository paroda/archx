# Arch Linux

This will guide you on how to create a new VMWare Player guest VM running Arch Linux.

## Create a new Virtual Machine

Create a new virtual machine with following specs:

* CPU: 8
* RAM: 8 GB
* HDD: 20 GB *archX.vmdk*
* Display
  * Video Memory: 2 GB
  * Enable 3D acceleration: yes
* Network: *default NAT*


## Install Arch Linux

For more information on how to setup Arch Linux see its [installation guide](https://wiki.archlinux.org/title/installation_guide)

Insert the installation image (archlinux-2021.05.01-x86_64.iso) into the virtual DVD drive and boot.
The virtual machine will boot up and show the root shell.

Now do the following actions.

``` sh
timedatectl set-ntp true

# create and mount one partition (primary, whole disk, boot flag on, type Linux)
fdisk /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

```

Now install base system.

``` sh
pacstrap /mnt base linux neovim linux-headers base-devel
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# edit /etc/locale.gen and uncomment en_US.UTF-8 UTF-8
nvim /etc/locale.gen

# generate locales
locale-gen

# create locale.conf and set LANG
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# create hostname
echo 'archX' > /etc/hostname

# add to hosts
echo "127.0.0.1      localhost" >> /etc/hosts
echo "::1            localhost" >> /etc/hosts
echo "127.0.0.1      archX" >> /etc/hosts

# set root passwd
passwd

# install GRUB bootloader
pacman -Syu grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# install microcode (AMD cpu)
pacman -Syu amd-ucode
grub-mkconfig -o /boot/grub/grub.cfg

# exit, unmount then reboot
exit
umount -R /mnt
reboot

```

The base operating system is now installed.
The expected disk file size at this point is 1.8 GB.

## Configure Network

Check network and fix to DHCP if needed.

``` sh
# enable the daemons for network manager
systemctl enable systemd-networkd
systemctl enable systemd-resolved

nvim /etc/systemd/network/20-wired.network
# set the content as
#  [Match]
#  Name=ens33
#
#  [Network]
#  DHCP=yes

reboot

```

The network should up by now.

## Update pacman keyring

``` sh
pacman-key --populate archlinux

```

## Enable Audio

The audio works mostly out of box, though it would be initially muted.
You just need to unmute.

``` sh
# install the utilities
pacman -Syu alsa-utils

# unmute using amixer
amixer sset Master unmute

# unmute using alsamixer console, here just raise the volume to full: Master, PCM, Video
alsamixer

# now test the speakers
speaker-test -c 2

```

## Install OpenVMTools

Install OpenVMTools

``` sh
pacman -Syu open-vm-tools
pacman -Syu gtkmm3 xf86-input-vmmouse xf86-video-vmware
systemctl enable vmtoolsd
systemctl enable vmware-vmblock-fuse

```

## Setup auto sync of time

``` sh
timedatectl set-ntp true

```

## Setup User & Group

Setup user

``` sh
# install sudo
pacman -Syu sudo

# uncomment %wheel ALL=(ALL) ALL in sudo config
# also add: %wheel ALL=(ALL) NOPASSWD: /usr/bin/halt, /usr/bin/reboot, /usr/bin/poweroff
EDITOR=nvim visudo

# create user dipu
useradd -mG wheel dipu
passwd dipu

reboot

```

The new user *dipu* is now ready for login.
The expected disk file size at this point is 2.4 GB.

## Install basic components

``` sh
# install minimal system
sudo pacman -Syu i3-wm dmenu xorg-server xorg-xinit xorg-xdm openssh ttf-fira-mono
sudo pacman -Syu xorg-xrandr fakeroot git fish alacritty ranger exa

# enable X11 forwarding in ssh
sudo nvim /etc/ssh/sshd_config

# enable ssh service
sudo systemctl enable sshd

# create ~/.xinitrc
cp /etc/X11/xinit/xinitrc ~/.xinitrc

# remove the last few lines starting with twm &
# and add:
#    vmware-user &
#    exec i3

# make it executable
chmod +x ~/.xinitrc

```

Later modify .config/i3/config (auto created on first run) to comment out i3status to
eliminate the red errors in the bottom bar.

Now enable the login screen.

``` sh
sudo pacman -Syu xdm-archlinux
sudo systemctl enable xdm-archlinux
reboot

```

Now we are ready with a minimal system with simple graphical login screen.
The expected disk file size at this point is 2.6 GB.

## Install primary tools for work

Target tools
* emacs
* docker
* clojure
* nodejs

``` sh
# clojure, node
sudo pacman -Syu rlwrap unzip clojure leiningen jdk11-openjdk nodejs npm

# copy your personal Github key file to ~/.ssh/id_rsa_github
# create a basic ssh config file ~/.ssh/config to use the above key file
nvim ~/.ssh/config
# ~/.ssh/config - set the content
#     Host github.com
#       Hostname  github.com
#       IdentityFile ~/.ssh/id_rsa_github
#       User git

# clone the clojure config repo
git clone git@github.com:paroda/clojure-deps-edn.git ~/.clojure

# emacs
sudo pacman -Syu ripgrep the_silver_searcher ditaa graphviz gnuplot pandoc emacs

# install vterm support
sudo pacman -Syu cmake libvterm

# clone the config repo
git clone git@github.com:paroda/prelude.git ~/.emacs.d
pushd ~/.emacs.d ; git checkout archx ; popd

# install docker
sudo pacman -Syu docker docker-compose
sudo usermod -aG docker dipu
sudo systemctl enable docker

# install postgres sql client
sudo pacman -Syu postgresql

```

The expected disk file size at this point is 4.5 GB.

Now the primary setup is ready 😎

## More tools

Install some additional tools.

``` sh
sudo pacman -Syu feh qiv picom rofi xcursor-flatbed conky
sudo pacman -Syu perl-anyevent-i3 mplayer i3status-rust
sudo pacman -Syu fd plocate bashtop

# install xwinwrap form AUR - to use a video as wallpaper
cd /tmp
git clone https://aur.archlinux.org/xwinwrap-git.git
cd xwinwrap-git
makepkg -si

```

Install Google Chrome web browser

``` sh
cd /tmp
git clone https://aur.archlinux.org/google-chrome.git
cd google-chrome
makepkg -si

```

## Add the data disks

Mount the data disks in the following order and accordingly they would appear in */dev*

| Disk file       | /dev/sd*  | Mount path   |
|:----------------|:----------|:-------------|
| dipu.vmdk       | /dev/sdb1 | ~/.dipu      |
| my.vmdk         | /dev/sdc1 | ~/my         |

NOTE: The disk *dipu.vmdk* contains same thing as this repository. You can just create a new
virtual disk and copy the contents of this repo to it. The disk *my.vmdk* is an optional disk
to store personal files. Just create a new one, if you do not have one already.

Create the folders at mount path and edit */etc/fstab* to sepcify the auto mounts. However, some
virtual machines do not maintain the order of disk files in `/dev`. A more reliable way is to use
the `UUID` as shown next.

``` sh
/dev/sdb1      /home/dipu/.dipu           ext4       rw,relatime       0 1
/dev/sdc1      /home/dipu/my              ext4       rw,relatime       0 1

```

If you face issue with ordering of the disks, use the **UUID** of the disks instead of *device file*.
You can find the correct UUID of the disks using the command `lsblk -o NAME,PATH,LABEL,UUID`.

``` sh
UUID=f1fe50e6-2102-40f4-89d2-fdbc9014857b       /home/dipu/.dipu           ext4       rw,relatime       0 1
UUID=ba0e28be-366a-4f93-ae3e-4d0fa615da39       /home/dipu/my              ext4       rw,relatime       0 1

```

Now reboot.

### Create the symlinks as follows:

*Dot Files*

| Symlink target                                        | Symlink                                         |
|:------------------------------------------------------|:------------------------------------------------|
| ~/my/.store                                           | ~/Downloads                                     |
| ~/.dipu/.bash_profile                                 | ~/.bash_profile                                 |
| ~/.dipu/.bashrc                                       | ~/.bashrc                                       |
| ~/.dipu/.bin                                          | ~/.bin                                          |
| ~/.dipu/.gitconfig                                    | ~/.gitconfig                                    |
| ~/.dipu/.sdk                                          | ~/.sdk                                          |
| ~/.dipu/.vimrc                                        | ~/.vimrc                                        |
| ~/.dipu/.wallpapers                                   | ~/.wallpapers                                   |
| ~/.dipu/.xinitrc                                      | ~/.xinitrc                                      |
| ~/.dipu/.Xresources                                   | ~/.Xresources                                   |
|                                                       |                                                 |
| ~/.dipu/.config/alacritty/alacritty.yml               | ~/.config/alacritty/alacritty.yml               |
| ~/.dipu/.config/fish/config.fish                      | ~/.config/fish/config.fish                      |
| ~/.dipu/.config/fish/functions/hostname.fish          | ~/.config/fish/functions/hostname.fish          |
| ~/.dipu/.config/fish/functions/fish_prompt.fish       | ~/.config/fish/functions/fish_prompt.fish       |
| ~/.dipu/.config/fish/functions/fish_right_prompt.fish | ~/.config/fish/functions/fish_right_prompt.fish |
| ~/.dipu/.config/i3/config                             | ~/.config/i3/config                             |
| ~/.dipu/.config/i3/layouts                            | ~/.config/i3/layouts                            |
| ~/.dipu/.config/i3status-rust/config.toml             | ~/.config/i3status-rust/config.toml             |
| ~/.dipu/.config/nvim/init.vim                         | ~/.config/nvim/init.vim                         |
| ~/.dipu/.config/picom/picom.conf                      | ~/.config/picom/picom.conf                      |
| ~/.dipu/.config/conky/conky.conf                      | ~/.config/conky/conky.conf                      |
|                                                       |                                                 |
| ~/.dipu/.emacs.d/.persistent                          | ~/.emacs.d/.persistent                          |
| ~/.dipu/.lein/profiles.clj                            | ~/.lein/profiles.clj                            |
| ~/.dipu/.local/share/fonts                            | ~/.local/share/fonts                            |
|                                                       |                                                 |
| ~/.dipu/.ssh/config                                   | ~/.ssh/config                                   |
| ~/.dipu/.ssh/id_rsa                                   | ~/.ssh/id_rsa                                   |
| ~/.dipu/.ssh/id_rsa_github                            | ~/.ssh/id_rsa_github                            |
| ~/.dipu/.ssh/id_rsa_aws_my                            | ~/.ssh/id_rsa_aws_my                            |
| ~/.dipu/.ssh/id_rsa_{others}                          | ~/.ssh/id_rsa_{others}                          |

### Copy the files:

Since we are using aws via docker, symlink would be invalid. Hence just copy.

| Source file              | Target             |
|:-------------------------|:-------------------|
| ~/.dipu/.aws/config      | ~/.aws/config      |
| ~/.dipu/.aws/credentials | ~/.aws/credentials |

### Copy system level config file

Use the custom xdm-archlinux config, which will set the wallpaper on login screen.
NOTE: It includes an `xrandr` command to set initial screen resolution to `1920x1080 @ 60Hz`. However, on
resizing the window or fullscreen, the system will auto resize the resolution.

``` sh
sudo cp ~/.dipu/store/cp-etc_X11_xdm_archlinux_Xsetup /etc/X11/xdm/archlinux/Xsetup
sudo cp ~/.dipu/store/cp-etc_X11_xdm_archlinux_Xresources /etc/X11/xdm/archlinux/Xresources

```

## Add encrypted data disks

We are using **LUKS on partition** for encrypting the partition in the virtual hard disk with a passphrase.

### How to create a new encrypted disk

Create a regular virtual hard disk and add to your machine, and then locate it in the `/dev` folder. Let's
say it is mounted at `/dev/sdd` for example. Then create the encrypted partition as follows:

``` sh
# Create the partition on /dev/sdd

sudo fdisk /dev/sdd

# Now you should have the newly created partition at /dev/sdd1

sudo cryptsetup -y -v luksFormat /dev/sdd1

# It will ask for a passphrase. Provide one and remember it, since you would need it later to mount it

cryptsetup open /dev/sdd1 cryptroot
mkfs.ext4 /dev/mapper/cryptroot
cryptsetup close cryptroot

```

### Mount encrypted disk partition

Note the **UUID** of the partition. To list out details of all disks added to the virtual machine,
you can use the command `lsblk -o NAME,PATH,LABEL,UUID,SIZE,TYPE,MOUNTPOINTS`.

For convenience, there is a script file `.bin/mount-crypts`. Edit it to replace two parameters `vol_name` and
`vol_uuid` as per your need. Then, you can call it anytime after a machine restart to mount that
encrypted partition at `~/$vol_name`. It'll ask for the passphrase, provide the one you set while
creating the encrypted disk.

## Optional

### video wallpaper
To use the video wallpaper use the command

``` sh
wp-video

```

### Install clj-kondo
``` sh
cd /tmp
git clone https://aur.archlinux.org/clj-kondo-bin.git
cd clj-kondo-bin
makepkg -si

```

### Install babashka
``` sh
cd /tmp
git clone https://aur.archlinux.org/babashka-bin.git
cd babashka-bin
makepkg -si

```

### Misc SDKs
For Intel MKL and plantuml jar, either get it from the data disk (dipu.vmdk)
or download from the internet. These being large binary files, not included in the repo.

Copy the plantuml jar file to `~/.sdk/plantuml.jar`.
Copy the MKL lib folder to `~/.sdk/mkl/lib` folder.

## The End
