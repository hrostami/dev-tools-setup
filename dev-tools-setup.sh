#!/bin/bash

# Function to display error messages and exit
exit_with_error() {
    echo -e "\033[1;31mError: $1\033[0m"
    exit 1
}

# Function to configure NvChad
configure_nvchad() {
    echo "Configuring NvChad..."

    # Install software-properties-common and update package list
    sudo apt-get install -y software-properties-common || exit_with_error "Failed to install software-properties-common"
    sudo apt-get update || exit_with_error "Failed to update package list"

    # Add Neovim PPA repository
    sudo add-apt-repository ppa:neovim-ppa/unstable || exit_with_error "Failed to add Neovim PPA repository"
    sudo apt update || exit_with_error "Failed to update package list"

    # Install Python virtual environment and pip
    sudo apt install -y python3-venv python3-pip || exit_with_error "Failed to install Python packages"

    # Install Neovim
    sudo apt install -y neovim || exit_with_error "Failed to install Neovim"

    # Remove existing Neovim configuration
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim

    # Clone NvChad configuration
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 || exit_with_error "Failed to clone NvChad repository"

    # Clone neovim-python repository
    git clone https://github.com/dreamsofcode-io/neovim-python.git ~/.config/nvim/lua/custom --depth 1 || exit_with_error "Failed to clone neovim-python repository"

    # Install Node.js and npm
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - || exit_with_error "Failed to set up Node.js repository"
    sudo apt-get install -y nodejs || exit_with_error "Failed to install Node.js"

    echo "NvChad configuration completed."
}

# Function to configure Oh-My-Zsh
configure_ohmyzsh() {
    echo "Configuring Oh-My-Zsh..."

    sudo apt-get install software-properties-common || exit_with_error "Failed to install software-properties-common"
    sudo apt-get update || exit_with_error "Failed to update package list"

    # Install zsh-syntax-highlighting and zsh-autosuggestions
    sudo apt install -y zsh-syntax-highlighting || exit_with_error "Failed to install zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions || exit_with_error "Failed to clone zsh-autosuggestions repository"

    sudo apt install -y zsh
    if [[ ! -f /root/.zsh ]]; then
        echo "*"
    else
        sudo mv -fr /root/.zsh /home/$SUDO_USER/.zsh
    fi
    sudo apt install -y powerline fonts-powerline
    sudo apt install -y zsh-theme-powerlevel9k
    sudo rm -r -f ~/.oh-my-zsh
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh || exit_with_error "Failed to clone Oh-My-Zsh repository"
    cat << EOF > ~/.zshrc
#cd ~
if [[ \$(whoami) == "root" ]]; then
    export ZSH="/\$(whoami)/.oh-my-zsh"
else
    export ZSH="/home/\$(whoami)/.oh-my-zsh"
fi
ZSH_THEME="agnoster"
plugins=(
  git
  zsh-autosuggestions
)
source \$ZSH/oh-my-zsh.sh
source /usr/share/powerlevel9k/powerlevel9k.zsh-theme
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
bindkey '^ ' autosuggest-accept
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(anaconda user dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history ram ssh)
EOF
    sudo usermod -s /usr/bin/zsh \$(whoami)
    echo "Oh-My-Zsh configuration completed."
}

# ANSI color escape codes
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"
LINE="=============================================================================="

# Main menu
while true; do
    clear
    echo -e "${CYAN}$LINE${RESET}"
    echo -e "$(printf '%*s' $(((${#LINE}+27)/2)) "==== Configuration Menu ====")"
    echo -e "${CYAN}$LINE${RESET}"
    echo -e "${GREEN}1. Configure NvChad${RESET}"
    echo -e "${GREEN}2. Configure Oh-My-Zsh${RESET}"
    echo -e "${YELLOW}3. Exit${RESET}"
    read -p "Please select an option (${GREEN}1${RESET}/${GREEN}2${RESET}/${YELLOW}3${RESET}): " choice

    case $choice in
        1) configure_nvchad ;;
        2) configure_ohmyzsh ;;
        3) echo "Exiting..."
           exit ;;
        *) echo "Invalid option. Please select again." ;;
    esac

    read -p "Press Enter to continue..."
done
