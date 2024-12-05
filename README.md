# archlinux-wsl-setup
My setup to run archlinux development environment.

Sometimes i change something :)


# How to install <br>

Download Arch zip file here: [Download](https://github.com/yuk7/ArchWSL/releases).<br>
Extract zip file and open Windows Terminal(recommended) or cmd. <br>
<code>cd</code> to Arch folder path <br><br>
Run the Arch.exe
````
.\Arch.exe
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
pacman -S git reflector openssl --noconfirm
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
.\Arch.exe config --default-user your-user-here
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
# fish configuration
## leave it that way and save changes
![image](https://github.com/user-attachments/assets/b2e20e0a-a5ce-43d8-b60a-f7b2393f3105)
![image](https://github.com/user-attachments/assets/12ca1539-a30a-49cc-a87f-7aa524a7824e)

# My appearance settings
![image](https://github.com/user-attachments/assets/a7f4980f-c7a2-47d7-a726-cf21a9a4ce35)

# You can download the Hack Nerd Font here
[https://www.nerdfonts.com/font-downloads](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip)

![image](https://github.com/user-attachments/assets/d851b7c2-4550-48a4-a024-785cf525ecb9)
![image](https://github.com/user-attachments/assets/7f958007-dd4e-4af8-98ad-5970c8b02157)

# Restart windows terminal and open your Arch
## You can set Arch as default profile too
![image](https://github.com/user-attachments/assets/46050fc8-10b7-4f2a-ab72-1e55eb1c3ca7)

