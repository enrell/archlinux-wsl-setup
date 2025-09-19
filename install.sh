#!/usr/bin/env bash

# Unified installer for Arch Linux on WSL
# - If run as root (first run), it prepares pacman, mirrors, sudoers, and creates your user.
# - If run as a regular user (second run), it installs packages, yay, and configures fish.
#
# Options:
#   -h, --help             Show this help.

set -euo pipefail

bold() { printf "\033[1m%s\033[0m\n" "$*"; }
note() { printf "[install] %s\n" "$*"; }

is_root() { [ "${EUID:-$(id -u)}" -eq 0 ]; }

# Open a dedicated TTY fd for interactive prompts (supports curl | bash)
INTERACTIVE=1
if [ -e /dev/tty ] && [ -r /dev/tty ] && [ -w /dev/tty ]; then
  exec 3<>/dev/tty
else
  INTERACTIVE=0
fi

usage() {
  cat <<'USAGE'
Usage: install.sh

When run as root (Stage 1):
  - Optionally skip pacman keyring init (prompt), enables sudo for wheel.
  - Asks you for preferred countries (comma-separated) and refreshes mirrors using reflector.
  - Optionally skip user creation (prompt) or create a user and set a password.

When run as non-root (Stage 2):
  - Installs packages, yay (AUR), and configures fish/starship/direnv.

Options:
  -h, --help               Show this help and exit.
USAGE
}

# Defaults (can be overridden via config file)
CONFIG_FILE=/etc/archlinux-wsl-setup.conf
COUNTRIES=${COUNTRIES:-"United States,Brazil"}

# Parse CLI arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --)
      shift
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
done

stage_root() {
  bold "Stage 1/2: Root setup"

  # Ask whether to skip keyring initialization
  local SKIP_KEYRING=1
  if [ "$INTERACTIVE" -eq 1 ]; then
    read -r -u 3 -p "Skip pacman keyring initialization? [Y]/n: " ans_keyring
  else
    ans_keyring=Y
  fi
  case "${ans_keyring:-Y}" in
    [Yy]*) SKIP_KEYRING=1 ;;
    *)     SKIP_KEYRING=0 ;;
  esac
  if [ "$SKIP_KEYRING" -eq 0 ]; then
    note "Initializing pacman keys and updating keyring..."
    pacman-key --init || true
    pacman-key --populate
    pacman -Sy --noconfirm archlinux-keyring || true
    if command -v archlinux-keyring-wkd-sync >/dev/null 2>&1; then
      archlinux-keyring-wkd-sync || true
    fi
  else
    note "Skipping pacman keyring initialization as requested."
  fi

  note "Installing prerequisites (git, reflector, openssl, sudo)..."
  pacman -S --needed --noconfirm git reflector openssl sudo curl wget

  # Ask whether to skip reflector mirror refresh
  local SKIP_REFLECTOR=1
  if [ "$INTERACTIVE" -eq 1 ]; then
    read -r -u 3 -p "Skip mirror refresh with reflector? [Y]/n: " ans_reflector
  else
    ans_reflector=Y
  fi
  case "${ans_reflector:-Y}" in
    [Yy]*) SKIP_REFLECTOR=1 ;;
    *)     SKIP_REFLECTOR=0 ;;
  esac

  if [ "$SKIP_REFLECTOR" -eq 0 ]; then
    # Ask for preferred countries and persist configuration
    local input_countries
    if [ "$INTERACTIVE" -eq 1 ]; then
      read -r -u 3 -p "Enter countries for reflector (comma-separated) [United States,Brazil]: " input_countries
    else
      input_countries=""
    fi
    if [ -z "${input_countries// }" ]; then
      COUNTRIES="United States,Brazil"
    else
      COUNTRIES="$input_countries"
    fi
    printf "COUNTRIES=%q\n" "$COUNTRIES" > "$CONFIG_FILE"
    chmod 0644 "$CONFIG_FILE" || true

    note "Refreshing mirrors using: $COUNTRIES"
    reflector --country "$COUNTRIES" -l 10 --age 12 \
      --protocol https --sort rate --save /etc/pacman.d/mirrorlist || true
  else
    note "Skipping mirror refresh with reflector."
    # Ensure config exists with default countries for Stage 2 alias
    if [ ! -f "$CONFIG_FILE" ]; then
      printf "COUNTRIES=%q\n" "$COUNTRIES" > "$CONFIG_FILE"
      chmod 0644 "$CONFIG_FILE" || true
    fi
  fi

  # Update packages regardless of reflector usage
  pacman -Su --noconfirm || true

  note "Enabling sudo for wheel group..."
  echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
  chmod 0440 /etc/sudoers.d/wheel

  # Ask whether to skip user creation
  local SKIP_USER=1
  if [ "$INTERACTIVE" -eq 1 ]; then
    read -r -u 3 -p "Skip user creation? [Y]/n: " ans_user
  else
    ans_user=Y
  fi
  case "${ans_user:-Y}" in
    [Yy]*) SKIP_USER=1 ;;
    *)     SKIP_USER=0 ;;
  esac

  local username
  if [ "$SKIP_USER" -eq 0 ]; then
    if [ "$INTERACTIVE" -eq 1 ]; then
      read -r -u 3 -p "Enter your username: " username
    else
      note "No TTY detected; cannot prompt for username. Skipping user creation."
      SKIP_USER=1
    fi
    if [ "$SKIP_USER" -eq 0 ]; then
      if id "$username" >/dev/null 2>&1; then
        note "User '$username' already exists."
        if [ "$INTERACTIVE" -eq 1 ]; then
          read -r -u 3 -p "Reset password for '$username'? [Y]/n: " ans_reset
        else
          ans_reset=N
        fi
        case "${ans_reset:-Y}" in
          [Yy]*) 
            note "To reset password for '$username', run this command after the installer completes:"
            note "  passwd $username"
            ;;
          *)     
            note "Skipped password change for '$username'." 
            ;;
        esac
      else
        note "Creating user '$username' with shell /bin/bash and adding to wheel..."
        useradd -m -G wheel -s /bin/bash "$username"
        note "User '$username' created successfully."
      fi
    fi
  else
    note "Skipping user creation as requested."
  fi

  cat <<EOM

================================================================================
Root phase complete.

Next steps (in Windows PowerShell):
  1) run passwd $username and exit
EOM

  if [ "$SKIP_USER" -eq 0 ]; then
    cat <<EOM
  2) Set the default WSL user to '$username':
     wsl --manage archlinux --set-default-user $username
  3) Open Arch again:  wsl -d archlinux
  4) Run the same installer command once more to continue:
     curl -fsSL https://raw.githubusercontent.com/enrell/archlinux-wsl-setup/main/install.sh | bash
================================================================================
EOM
  else
    cat <<'EOM'
  2) You skipped user creation. Create a user when ready (inside Arch):
       sudo useradd -m -G wheel -s /bin/bash YOUR_USER
       sudo passwd YOUR_USER
     Then set it as default in PowerShell:
       wsl --manage archlinux --set-default-user YOUR_USER
  3) Open Arch again as YOUR_USER:  wsl -d archlinux
  4) Run the same installer command to complete user setup:
       curl -fsSL https://raw.githubusercontent.com/enrell/archlinux-wsl-setup/main/install.sh | bash
================================================================================
EOM
  fi
}

stage_user() {
  bold "Stage 2/2: User setup"

  if is_root; then
    echo "This stage must be run as the non-root user you created."
    echo "Please follow the instructions from Stage 1."
    exit 1
  fi

  local INSTALL_DIR
  INSTALL_DIR="$HOME/archlinux-wsl-setup"
  local YAY_DIR
  YAY_DIR="$INSTALL_DIR/yay"
  local FISH_CONFIG
  FISH_CONFIG="$HOME/.config/fish/config.fish"

  mkdir -p "$INSTALL_DIR"
  cd "$INSTALL_DIR"

  note "Updating system and installing core packages..."
  sudo pacman -Syu --needed --noconfirm wget curl eza make openssh python python-pip neovim fish direnv starship git base-devel

  note "Installing yay (AUR helper)..."
  if ! command -v yay >/dev/null 2>&1; then
    git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
    pushd "$YAY_DIR" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "$YAY_DIR"
  else
    note "yay already installed. Skipping."
  fi

  note "Installing find-the-command via yay..."
  yay -S --noconfirm --needed find-the-command

  note "Configuring fish shell..."
  mkdir -p "$(dirname "$FISH_CONFIG")"

  # Check if config exists to provide appropriate message
  if [ -f "$FISH_CONFIG" ]; then
    note "Overwriting existing fish configuration in $FISH_CONFIG"
  else
    note "Writing complete fish configuration to $FISH_CONFIG"
  fi

  # Determine countries from config (fallback to default) for alias
  if [ -f /etc/archlinux-wsl-setup.conf ]; then
    # shellcheck disable=SC1091
    . /etc/archlinux-wsl-setup.conf || true
  fi

  # Write complete fish configuration, overwriting any existing content
  cat > "$FISH_CONFIG" <<EOF
# Check for interactive shell
if status is-interactive
    starship init fish | source
    set -g fish_greeting ""
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin \$PATH
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
    commandline -i '\$'
  end
end

if [ "\$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '\$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '\$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp \$filename \$filename.bak
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
alias hw='hwinfo --short'            # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl"    # Sort installed packages according to size in MB
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages

# Get fastest mirrors - customized by installer
alias update-mirrorlist="sudo reflector -l 30 --country '$COUNTRIES' --age 12 --protocol https,http --save /etc/pacman.d/mirrorlist"

# Cleanup orphaned packages
alias cleancache='sudo pacman -Rns (pacman -Qtdq)'

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# fast stop/start containers
alias stop-containers='sudo docker stop (sudo docker ps -q)'
alias start-containers='sudo docker start (sudo docker ps -a -q)'

eval (direnv hook fish)
EOF

  note "Fish configuration has been written with all content."

  # Remove the old separate alias append logic since it's now included in the main config

  note "Cleaning up temporary installer directory..."
  cd "$HOME"
  rm -rf "$INSTALL_DIR"

  cat <<'EOM'

Setup complete! You can restart your shell or run:  exec fish
For appearance and font tips, see the README.
EOM
}

main() {
  if is_root; then
    stage_root
  else
    stage_user
  fi
}

main "$@"
