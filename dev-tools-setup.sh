#!/bin/bash

# Function to configure NvChad
configure_nvchad() {
    echo "Configuring NvChad..."

    # Install software-properties-common and update package list
    sudo apt-get install -y software-properties-common
    sudo apt-get update

    # Add Neovim PPA repository
    sudo add-apt-repository ppa:neovim-ppa/unstable
    sudo apt update

    # Install Python virtual environment and pip
    sudo apt install -y python3-venv python3-pip

    # Install Neovim
    sudo apt install -y neovim

    # Remove existing Neovim configuration
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim

    # Clone NvChad configuration
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

    # Clone neovim-python repository
    git clone https://github.com/dreamsofcode-io/neovim-python.git ~/.config/nvim/lua/custom --depth 1

    # Install Node.js and npm
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs

    echo "NvChad configuration completed."
}

# Function to configure Oh-My-Zsh
configure_ohmyzsh() {
    echo "Configuring Oh-My-Zsh..."

    # Install zsh-syntax-highlighting and zsh-autosuggestions
    sudo apt install -y zsh-syntax-highlighting

    sudo apt install -y zsh
    if [[ ! -f /root/.zsh ]]; then
        echo "*"
    else
        sudo mv -fr /root/.zsh /home/$SUDO_USER/.zsh
    fi
    sudo apt install -y powerline fonts-powerline
    sudo apt install -y zsh-theme-powerlevel9k
    sudo rm -r -f ~/.oh-my-zsh
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins
    cat << EOF > ~/.zshrc
cd ~
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
    sudo usermod -s /usr/bin/zsh $(whoami)
    echo "Oh-My-Zsh configuration completed."
}

# Main menu
while true; do
    clear
    echo -e "$(tput setaf 6)==== Configuration Menu ====$(tput sgr0)"
    echo -e "$(tput setaf 2)1. Configure NvChad$(tput sgr0)"
    echo -e "$(tput setaf 2)2. Configure Oh-My-Zsh$(tput sgr0)"
    echo -e "$(tput setaf 3)3. Exit$(tput sgr0)"
    read -p "Please select an option ($(tput setaf 2)1$(tput sgr0)/$(tput setaf 2)2$(tput sgr0)/$(tput setaf 3)3$(tput sgr0)): " choice

    case $choice in
        1) configure_nvchad ;;
        2) configure_ohmyzsh ;;
        3) echo "Exiting..."
           exit ;;
        *) echo "Invalid option. Please select again." ;;
    esac

    read -p "Press Enter to continue..."
done
