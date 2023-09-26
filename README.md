# achlinux-wsl-setup
My setup for run archlinux development environment.

# IN DEVELOPMENT
A general setup for working with Docker in Arch linux. <br>

# How to install <br>

Download Arch zip file here: [Download](https://github.com/yuk7/ArchWSL/releases/tag/22.10.16.0).<br>
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
pacman-key --init && pacman-key --populate && pacman -Syy archlinux-keyring git reflector && pacman -Su
````
## Set the mirrorlist to improve the download speed
````
reflector --country 'United States,Brazil' -l 10 --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
````
````
cd /tmp
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
Change default user READ THE CODE
````
Arch.exe config --default-user your-user-here
````
And open Arch again
````
wsl -d Arch
````
And run the second script
````
cd /tmp/achlinux-wsl-setup && sh second.sh
````
# zsh configuration
## leave it that way and save changes
![screenshot](https://i.imgur.com/I1ReXZB.png)
![screenshot](https://i.imgur.com/ad8CbYU.png)
![screenshot](https://i.imgur.com/pQwCU1r.png)

# Restart windows terminal and open your Arch
## You can set Arch as default profile

# To run docker just run this.
````
docker
````
