#!/bin/bash

# Function to handle errors interactively
handle_error() {
    echo -e "\n$(tput setaf 1)An error occurred while executing: $1$(tput sgr0)"
    read -p "$(tput setaf 3)Press [R]etry, [S]kip, or [E]xit: $(tput sgr0)" choice
    case $choice in
        [rR]*) eval "$1" ;;  # Retry the failed command
        [sS]*) echo "$(tput setaf 2)Skipping...$(tput sgr0)" ;;  # Skip the failed command
        *) echo "$(tput setaf 1)Exiting...$(tput sgr0)" ; exit 1 ;;
    esac
}

# Install Git
echo "$(tput setaf 2)Installing Git...$(tput sgr0)"
sudo apt-get update || handle_error "Updating package list"
sudo apt-get install -y git || handle_error "Installing Git"
echo "$(tput setaf 2)Git installation completed.$(tput sgr0)"

# Function to configure NvChad
configure_nvchad() {
    echo "Configuring NvChad..."

    # Install software-properties-common and update package list
    sudo apt-get install -y software-properties-common || handle_error "Installing software-properties-common"
    sudo apt-get update || handle_error "Updating package list"

    # Add Neovim PPA repository
    sudo add-apt-repository ppa:neovim-ppa/unstable || handle_error "Adding Neovim PPA repository"
    sudo apt update || handle_error "Updating package list"

    # Install Python virtual environment and pip
    sudo apt install -y python3-venv python3-pip || handle_error "Installing Python virtual environment and pip"
    sudo apt install -y git || handle_error "Installing Git"

    # Install Neovim
    sudo apt install -y neovim || handle_error "Installing Neovim"

    # Remove existing Neovim configuration
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim

    # Clone NvChad configuration
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 || handle_error "Cloning NvChad configuration"

    # Clone neovim-python repository
    git clone https://github.com/dreamsofcode-io/neovim-python.git ~/.config/nvim/lua/custom --depth 1 || handle_error "Cloning neovim-python repository"

    # Install Node.js and npm
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - || handle_error "Installing Node.js and npm"
    sudo apt-get install -y nodejs || handle_error "Installing Node.js and npm"

    echo "NvChad configuration completed."
}

# Function to configure Oh-My-Zsh
configure_ohmyzsh() {
    echo "Configuring Oh-My-Zsh..."

    # Install zsh-syntax-highlighting and zsh-autosuggestions
    sudo apt install -y zsh-syntax-highlighting || handle_error "Installing zsh-syntax-highlighting"

    sudo apt install -y zsh || handle_error "Installing zsh"
    if [[ ! -f /root/.zsh ]]; then
        echo "*"
    else
        sudo mv -fr /root/.zsh /home/$SUDO_USER/.zsh || handle_error "Moving Zsh configuration"
    fi
    sudo apt install -y powerline fonts-powerline || handle_error "Installing powerline and fonts-powerline"
    sudo apt install -y zsh-theme-powerlevel9k || handle_error "Installing zsh-theme-powerlevel9k"
    sudo rm -r -f ~/.oh-my-zsh || handle_error "Removing existing Oh-My-Zsh configuration"
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh --depth 1 || handle_error "Cloning Oh-My-Zsh repository"
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions --depth 1 || handle_error "Cloning zsh-autosuggestions repository"
    cat << EOF > ~/.zshrc || handle_error "Creating Zsh configuration file"
#cd ~
if [[ $(whoami) == "root" ]]; then
    export ZSH="/$(whoami)/.oh-my-zsh"
else
    export ZSH="/home/$(whoami)/.oh-my-zsh"
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
    sudo usermod -s /usr/bin/zsh $(whoami) || handle_error "Changing default shell to Zsh"
    echo "Oh-My-Zsh configuration completed."
}

# Main menu
while true; do
    clear
    echo "$(tput setaf 4)==== Configuration Menu ====$(tput sgr0)"
    echo "$(tput setaf 3)1. Configure NvChad$(tput sgr0)"
    echo "$(tput setaf 3)2. Configure Oh-My-Zsh$(tput sgr0)"
    echo "$(tput setaf 1)3. Exit$(tput sgr0)"
    
    read -p "Please select an option ($(tput setaf 3)1$(tput sgr0)/$(tput setaf 3)2$(tput sgr0)/$(tput setaf 1)3$(tput sgr0)): " choice

    case $choice in
        1) configure_nvchad ;;
        2) configure_ohmyzsh ;;
        3) echo "Exiting..."
           exit ;;
        *) echo "$(tput setaf 1)Invalid option. Please select again.$(tput sgr0)" ;;
    esac

    read -p "Press Enter to continue..."
done
