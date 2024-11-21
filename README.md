# archlinux-wsl-setup
My setup to run archlinux development environment.

# IN DEVELOPMENT
A general setup for Arch linux (WSL). <br>

# How to install <br>

Download Arch zip file here: [Download](https://github.com/yuk7/ArchWSL/releases).<br>
Extract zip file and open Windows Terminal(recommended) or cmd. <br>
<code>cd</code> to Arch folder path <br><br>
Run the Arch.exe
````
> Arch.exe
````
After install folow the next steps.
````
wsl -d Arch
````
````
pacman-key --init && pacman-key --populate && pacman -Sy archlinux-keyring --noconfirm && archlinux-keyring-wkd-sync
````
## Set the mirrorlist to improve the download speed and update
````
pacman -S git reflector --noconfirm
````
````
reflector --country 'United States,Brazil' -l 10 --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist && pacman -Su --noconfirm
````
````
cd /home
git clone https://github.com/enrell/achlinux-wsl-setup.git
cd achlinux-wsl-setup
````
## Run the first script
````
sh first.sh
````
Go back to command prompt:
````
exit
````
Change default user
````
Arch.exe config --default-user your-user-here
````
Open Arch again
````
wsl -d Arch
````
Run the second script
````
cd /home/achlinux-wsl-setup && sh second.sh
````
````
exit
````
# zsh configuration
## leave it that way and save changes
![screenshot](https://i.imgur.com/I1ReXZB.png)
![screenshot](https://i.imgur.com/ad8CbYU.png)
![screenshot](https://i.imgur.com/pQwCU1r.png)

# Restart windows terminal and open your Arch
## You can set Arch as default profile
