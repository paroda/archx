# Arch Linux

This will guide you on how to create a new VirtualBox guest VM running Arch Linux.

## Create a VBox VM

Create a new virtual machine with following specs:

* CPU: 8
* RAM: 8 GB
* HDD: 20 GB [archX.vdi]
* Display
  - Video Memory: 256 MB
  -  Graphics Controller: VMSVGA (or VBoxSVGA if any issue)
* Network: [default NAT]
  - Port Forward: SSH - 22 --> 22

## Install Arch Linux

For more information on how to setup Arch Linux see its [installation guide](https://wiki.archlinux.org/title/installation_guide)

Insert the installation image (archlinux-2021.05.01-x86_64.iso) into the virtual DVD drive and boot.
The virtual machine will boot up and show the root shell.

Now do the following actions.

``` shell
$ timedatectl set-ntp true

### create and mount one partition (primary, whole disk, boot flag on, type Linux)
$ fdisk /dev/sda
$ mkfs.ext4 /dev/sda1
$ mount /dev/sda1 /mnt

```

Now install base system.

``` shell
$ pacstrap /mnt base linux neovim
$ genfstab -U /mnt >> /mnt/etc/fstab
$ arch-chroot /mnt

$ ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
$ hwclock --systohc

### edit /etc/locale.gen and uncomment en_US.UTF-8 UTF-8
$ nvim /etc/locale.gen

### generate locales
$ locale-gen

### create locale.conf and set LANG
$ echo 'LANG=en_US.UTF-8' > /etc/locale.conf

### create hostname
$ echo 'archX' > /etc/hostname

### add to hosts
$ echo "127.0.0.1      localhost" >> /etc/hosts
$ echo "::1            localhost" >> /etc/hosts
$ echo "127.0.0.1      archX" >> /etc/hosts

### set root passwd
$ passwd

### install GRUB bootloader
$ pacman -Syu grub
$ grub-install --target=i386-pc /dev/sda
$ grub-mkconfig -o /boot/grub/grub.cfg

### install microcode (AMD cpu)
$ pacman -Syu amd-ucode
$ grub-mkconfig -o /boot/grub/grub.cfg

### exit, unmount then reboot
$ exit
$ umount -R /mnt
$ reboot

```

The base operating system is now installed.
The expected disk file size at this point is 1.1 GB.

## Configure Network

Check network and fix to DHCP if needed.

``` shell
### enable the daemons for network manager
$ systemctl enable systemd-networkd
$ systemctl enable systemd-resolved

$ nvim /etc/systemd/network/20-wired.network
### set the content as
###  [Match]
###  Name=enp0s3
###
###  [Network]
###  DHCP=yes

$ reboot

```

The network should up by now.

## Enable Audio

The audio works mostly out of box, though it would be initially muted.
You just need to unmute.

``` shell
### install the utilities
$ pacman -Syu alsa-utils

### unmute using amixer
$ amixer sset Master unmute
$ amixer sset Speaker unmute
$ amixer sset Headphone unmute

### unmute using alsamixer console, here just raise
### the volume to full: Master, Master Mono, PCM, Surround, Center, LFE
$ alsamixer

### now test the speakers
$ speaker-test -c 2

```

## Install VirtualBox Guest Additions drivers

Install pre-requisites

``` shell
$ pacman -Syu linux-headers base-devel

```

Inject the virtualbox-guest-additions image into the virtual DVD drive.
Then do the following command

``` shell
### mount and install
$ mkdir /tmp/cdrom
$ mount /dev/cdrom /tmp/cdrom
$ cd /tmp/cdrom
$ ./VBoxLinuxAdditions.run

```

## Setup auto sync of time

``` shell
$ timedatectl set-ntp true

```

## Setup User & Group

Setup user

``` shell
### install sudo
$ pacman -Syu sudo

### uncomment %wheel ALL=(ALL) ALL in sudo config
$ EDITOR=nvim visudo

### create user dipu
$ useradd -mG wheel dipu
$ passwd dipu

$ reboot

```

The new user *dipu* is now ready for login.
The expected disk file size at this point is 1.9 GB.

## Install basic components

``` shell
### install minimal system
$ sudo pacman -Syu i3-wm dmenu xorg-server xorg-xinit xorg-xdm openssh ttf-fira-mono
$ sudo pacman -Syu fakeroot git fish alacritty ranger exa

### enable X11 forwarding in ssh
$ sudo nvim /etc/ssh/sshd_config

### enable ssh service
$ sudo systemctl enable sshd

### create ~/.xinitrc
$ cp /etc/X11/xinit/xinitrc ~/.xinitrc

### remove the last few lines starting with twm &
### and add just: exec i3

### make it executable
$ chmod +x ~/.xinitrc

```

Later modify .config/i3/config (auto created on first run) to comment out i3status to
eliminate the red errors in the bottom bar.

Now enable the login screen.

``` shell
$ sudo pacman -Syu xdm-archlinux
$ sudo systemctl enable xdm-archlinux
$ reboot

```

Now we are ready with a minimal system with simple graphical login screen.
The expected disk file size at this point is 2.7 GB.

## Install primary tools for work

Target tools
* emacs
* docker
* clojure
* nodejs

``` shell
### clojure, node
$ sudo pacman -Syu rlwrap unzip clojure leiningen jdk11-openjdk nodejs npm

### clone the clojure config repo
$ git clone git@github.com:paroda/clojure-deps-edn.git ~/.clojure

### emacs
$ sudo pacman -Syu ripgrep the_silver_searcher ditaa graphviz gnuplot pandoc emacs

### install vterm support
$ sudo pacman -Syu cmake libvterm

### clone the config repo
$ git clone git@github.com:paroda/prelude.git ~/.emacs.d
$ pushd ~/.emacs.d ; git checkout gui ; popd

### install docker
$ sudo pacman -Syu docker docker-compose
$ sudo usermod -aG docker dipu
$ sudo systemctl enable docker

### install postgres sql client
$ sudo pacman -Syu postgresql

```

For clj-kondo, Intel MKL and plantuml jar, either get it from the data disk (data.vdi)
or download from the internet.

The expected disk file size at this point is 5.7 GB.

Now the primary setup is ready 😎

## More tools

Install some additional tools.

``` shell
$ sudo pacman -Syu feh qiv picom rofi xcursor-flatbed
$ sudo pacman -Syu perl-anyevent-i3 mplayer i3status-rust
$ sudo pacman -Syu fd plocate bashtop

# install xwinwrap form AUR - to use a video as wallpaper
$ cd /tmp
$ git clone https://aur.archlinux.org/xwinwrap-git.git
$ cd xwinwrap-git
$ makepkg -si

```

Install Google Chrome web browser

``` shell
$ cd /tmp
$ git clone https://aur.archlinux.org/google-chrome.git
$ cd google-chrome
$ makepkg -si

```

## Add the data disks

Mount the data disks in the following order and accordingly they would appear in */dev*

| Disk file      | /dev/sd*  | Mount path   |
| :---           | :---      | :---         |
| dipu.vdi       | /dev/sdb1 | ~/.dipu      |
| my.vdi         | /dev/sdc1 | ~/my         |
| vacuumlabs.vdi | /dev/sdd1 | ~/vacuumlabs |

Create the folders at mount path and edit */etc/fstab* to sepcify the auto mounts:

``` shell
/dev/sdb1      /home/dipu/.dipu           ext4       rw,relatime       0 1
/dev/sdc1      /home/dipu/my              ext4       rw,relatime       0 1
/dev/sdd1      /home/dipu/vacuumlabs      ext4       rw,relatime       0 1

```

### Copy system level config file

Use the custom xdm-archlinux config, which will set the wallpaper on login screen.

``` shell
$ sudo cp ~/.dipu/store/cp-etc_X11_xdm_archlinux_Xsetup /etc/X11/xdm/archlinux/Xsetup

```

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
|                                                       |                                                 |
| ~/.dipu/.emacs.d/.persistent                          | ~/.emacs.d/.persistent                          |
| ~/.dipu/.lein/profiles.clj                            | ~/.lein/profiles.clj                            |
| ~/.dipu/.local/share/fonts                            | ~/.local/share/fonts                            |
|                                                       |                                                 |
| ~/.dipu/.ssh/config                                   | ~/.ssh/config                                   |
| ~/.dipu/.ssh/id_rsa                                   | ~/.ssh/id_rsa                                   |
| ~/.dipu/.ssh/id_rsa_aws_11onze                        | ~/.ssh/id_rsa_aws_11onze                        |
| ~/.dipu/.ssh/id_rsa_aws_my                            | ~/.ssh/id_rsa_aws_my                            |
| ~/.dipu/.ssh/id_rsa_aws_psn_dev                       | ~/.ssh/id_rsa_aws_psn_dev                       |
| ~/.dipu/.ssh/id_rsa_aws_psn_stage                     | ~/.ssh/id_rsa_aws_psn_stage                     |
| ~/.dipu/.ssh/id_rsa_aws_psn_prod                      | ~/.ssh/id_rsa_aws_psn_prod                      |
| ~/.dipu/.ssh/id_rsa_github                            | ~/.ssh/id_rsa_github                            |
|                                                       |                                                 |
| ~/.dipu/.aws/config                                   | ~/.aws/config                                   |
| ~/.dipu/.aws/credentials                              | ~/.aws/credentials                              |
|                                                       |                                                 |

## Optional

### Use static wallpaper instead of video

Edit the * ~/.xinitrc * and replace

``` shell
picom &
xwinwrap -ov -ni -fs -un -s -st -sp -b -nf -- mplayer -fps 12 -loop 0 -nosound -osdlevel 0 -fixed-vo -noconsolecontrols -wid WID ~/.wallpapers/wallpaper-video-4K-02.mp4 &
exec i3

```

with

``` shell
picom &
~/.bin/feh-random &
exec i3

```
