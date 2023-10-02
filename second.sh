sudo pacman -Sy wget curl exa make openssh python python-pip neovim zsh zsh-completions zsh-doc zsh-history-substring-search zshdb zsh-autosuggestions zsh-syntax-highlighting --noconfirm

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

## oh my zsh setup
sudo git clone https://github.com/Daivasmara/daivasmara.zsh-theme.git
cd daivasmara.zsh-theme
cp daivasmara.zsh-theme ~/.oh-my-zsh/themes/
cd
rm -rf daivasmara.zsh-theme/

echo 'export PATH="$HOME/bin:/usr/local/bin:$PATH"' >> ~/.zshrc

theme='ZSH_THEME="robbyrussell"'
newTheme='ZSH_THEME="daivasmara"'

zsh="/home/$USER/.zshrc"

sed -i "s/$theme/$newTheme/" "$zsh"

# Auto update
update="# zstyle ':omz:update' mode auto      # update automatically without asking"
newUpdate="zstyle ':omz:update' mode auto      # update automatically without asking"
sed -i "s/$update/$newUpdate/" "$zsh"

# Language
languageCommented="# export LANG=en_US.UTF-8"
language="export LANG=en_US.UTF-8"
sed -i "s/$languageCommented/$language/" "$zsh"

echo "alias ls='exa --color=auto'
alias ll='exa -lah --color=auto'
alias grep='grep --color=auto'

alias install='sudo pacman -S'
alias update='sudo pacman -Syy'
alias upgrade='sudo pacman -Syu'
alias remove='sudo pacman -Rns'

alias status='sudo systemctl status'
alias start='sudo systemctl start'
alias restart='sudo systemctl restart'
alias stop='sudo systemctl stop'
alias enable='sudo systemctl enable'
alias disable='sudo systemctl disable'

alias mirrorlist='sudo reflector --country "United States,Brazil" -l 10 --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'" >> $zsh
echo "" >> $zsh
echo 'export PATH="/home/$USER/bin:$PATH"' >> "$zsh"
