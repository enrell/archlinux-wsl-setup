sudo pacman -Sy --needed wget curl eza make openssh python python-pip neovim fish direnv starship --noconfirm
sudo chown $USER:$USER ../achlinux-wsl-setup
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

cd ..
rm -rf ./yay
cd

yay -Sy find-the-command --noconfirm

FISH_CONFIG="$HOME/.config/fish/config.fish"

# Fish configuration content
read -r -d '' FISH_CONFIG_CONTENT <<'EOF'
# Check for interactive shell
if status is-interactive
    starship init fish | source
    set -g fish_greeting ""
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Advanced command-not-found hook
source /usr/share/doc/find-the-command/ftc.fish

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Useful aliases
alias ls='eza -l --color=always --group-directories-first --icons' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll='eza -la --color=always --group-directories-first --icons'  # long format
alias lt='eza -aT --color=always --group-directories-first --icons' # tree listing
alias l.='eza -ald --color=always --group-directories-first --icons .*' # show only dotfiles
alias ip='ip -color'

# Common use
alias grubup="sudo update-grub"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias tarnow='tar -acf '
alias untar='tar -xvf '
alias wget='wget -c '
alias install="sudo pacman -S"
alias update="sudo pacman -Sy"
alias remove="sudo pacman -Rdd"
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias upgrade='sudo pacman -Syu'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='grep -F --color=auto'
alias egrep='grep -E --color=auto'
alias hw='hwinfo --short'                          # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl"     # Sort installed packages according to size in MB
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages

# Get fastest mirrors
alias update-mirrorlist="sudo reflector -l 30 --country 'Brazil,United States' --age 12 --protocol https,http --save /etc/pacman.d/mirrorlist"

# Cleanup orphaned packages
alias cleancache='sudo pacman -Rns (pacman -Qtdq)'

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# fast stop/start containers
alias stop-containers='sudo docker stop $(sudo docker ps -q)'
alias start-containers='sudo docker start $(sudo docker ps -a -q)'

eval (direnv hook fish)
EOF

# Append the content to config.fish if it doesn't already exist
if ! grep -q "starship init fish" "$FISH_CONFIG"; then
    echo "$FISH_CONFIG_CONTENT" >> "$FISH_CONFIG"
    echo "Fish configuration has been updated!"
else
    echo "Fish configuration already contains the setup."
fi

# Remove setup folder
cd ..
sudo rm -rf achlinux-wsl-setup
cd

echo "Continue the configuration: https://github.com/enrell/archlinux-wsl-setup/tree/main?tab=readme-ov-file#zsh-configuration"
