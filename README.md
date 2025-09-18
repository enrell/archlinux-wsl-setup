# archlinux-wsl-setup
My setup to run an Arch Linux development environment on WSL.

Sometimes I change things :)


# One‑liner auto install

1) Install Arch on WSL from Windows PowerShell:

```powershell
wsl --install archlinux
```

2) Open Arch for the first time and run the installer as root. The installer will ask for your preferred countries (for fastest mirrors), a username (unless you skip), set up sudo, and more. Paste one of the following inside the Arch shell:

```bash
curl -fsSL https://raw.githubusercontent.com/enrell/archlinux-wsl-setup/main/install.sh | bash
```

or, if curl isn't available yet:

```bash
wget -qO- https://raw.githubusercontent.com/enrell/archlinux-wsl-setup/main/install.sh | bash
```

Optional: you can skip creating a user in Stage 1 by adding --skip-user at the end of the command (you’ll get instructions to add it later).

```bash
curl -fsSL https://raw.githubusercontent.com/enrell/archlinux-wsl-setup/main/install.sh | bash -s -- --skip-user
```

3) When it finishes, exit the Arch shell and set the default user in PowerShell (replace YOUR_USER):

```powershell
exit
wsl --manage archlinux --set-default-user YOUR_USER
```

4) Open Arch again (now as your user) and run the same one‑liner to complete user setup (packages, yay, fish config):

```powershell
wsl -d archlinux
```

Then paste inside the Arch shell:

```bash
curl -fsSL https://raw.githubusercontent.com/enrell/archlinux-wsl-setup/main/install.sh | bash
```

or

```bash
wget -qO- https://raw.githubusercontent.com/enrell/archlinux-wsl-setup/main/install.sh | bash
```

You’ll be asked for mirror countries only in Stage 1. Stage 2 uses your saved choice.

That's it. After completion you can restart your shell or run:

```bash
exec fish
```

Tip: You can set Arch as the default profile in Windows Terminal.


## Notes

- The installer performs the original manual steps automatically, including pacman keyring init, mirrorlist optimization, sudo/wheel, user creation, base packages, yay, and fish/starship/direnv configuration.
- If curl fails due to SSL or networking issues, ensure your clock is correct and try again.


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

