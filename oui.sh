#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Banner function
print_banner() {
    echo -e "${BOLD}${BLUE}"
    echo -e " ██████╗ ██╗   ██╗██╗"
    echo -e "██╔═══██╗██║   ██║██║"
    echo -e "██║   ██║██║   ██║██║"
    echo -e "██║   ██║██║   ██║██║"
    echo -e "╚██████╔╝╚██████╔╝██║"
    echo -e " ╚═════╝  ╚═════╝ ╚═╝"
    echo -e "${RESET}"
    echo -e "${CYAN}Dotfiles Installation Script${RESET}"
    echo -e "${MAGENTA}===========================${RESET}"
    echo ""
}

# Check if running with sudo
check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}This script should not be run with sudo or as root.${RESET}"
        exit 1
    fi
}

# Detect environment
detect_environment() {
    echo -e "${CYAN}Detecting environment...${RESET}"
    
    # Check if AFS_DIR is set, otherwise check for AFS directory
    if [ -z "$AFS_DIR" ]; then
        if [ -d "$HOME/afs" ]; then
            AFS_DIR="$HOME/afs"
            echo -e "  ${GREEN}✓${RESET} AFS directory found at: ${BOLD}$AFS_DIR${RESET}"
        else
            echo -e "  ${RED}✗${RESET} AFS directory not found. This script is intended for EPITA systems only."
            echo -e "${RED}Exiting...${RESET}"
            exit 1
        fi
    else
        if [ -d "$AFS_DIR" ]; then
            echo -e "  ${GREEN}✓${RESET} Using AFS directory: ${BOLD}$AFS_DIR${RESET}"
        else
            echo -e "  ${RED}✗${RESET} Specified AFS directory ${BOLD}$AFS_DIR${RESET} not found."
            echo -e "${RED}Exiting...${RESET}"
            exit 1
        fi
    fi
}

# Check for existing configuration
check_existing_config() {
    echo -e "${CYAN}Checking existing configuration...${RESET}"
    
    local config_dir="$AFS_DIR/.confs"
    if [ -d "$config_dir" ]; then
        echo -e "  ${YELLOW}!${RESET} Existing configuration found at ${BOLD}$config_dir${RESET}"
        echo -e "  ${YELLOW}!${RESET} Backup will be created if you choose to install"
        HAS_EXISTING_CONFIG=true
    else
        echo -e "  ${GREEN}✓${RESET} No existing configuration found, safe to proceed"
        HAS_EXISTING_CONFIG=false
    fi
}

# Create backup of existing configuration
backup_existing_config() {
    if [ "$HAS_EXISTING_CONFIG" = true ]; then
        local config_dir="$AFS_DIR/.confs"
        local backup_dir="$AFS_DIR/.confs.backup.$(date +%Y%m%d%H%M%S)"
        
        echo -e "${CYAN}Creating backup of existing configuration...${RESET}"
        mkdir -p "$backup_dir"
        cp -r "$config_dir"/* "$backup_dir"/ 2>/dev/null || true
        echo -e "  ${GREEN}✓${RESET} Backup created at ${BOLD}$backup_dir${RESET}"
    fi
}

# Install dotfiles
install_dotfiles() {
    echo -e "${CYAN}Installing dotfiles...${RESET}"
    
    # Create .confs directory if it doesn't exist
    local config_dir="$AFS_DIR/.confs"
    mkdir -p "$config_dir"
    
    # List of dotfiles to install
    local dot_list="bashrc zshrc config starship kitty nvim waybar hypr wofi mako waypaper"
    
    # Copy all files
    local temp_dir="$(mktemp -d)"
    cd "$temp_dir"
    
    echo -e "  ${YELLOW}→${RESET} Downloading dotfiles..."
    curl -s https://codeload.github.com/jean-voila/oui/tar.gz/refs/heads/main -o dotfiles.tar.gz
    
    if [ $? -ne 0 ]; then
        echo -e "  ${RED}✗${RESET} Failed to download dotfiles"
        return 1
    fi
    
    echo -e "  ${YELLOW}→${RESET} Extracting files..."
    tar -xzf dotfiles.tar.gz
    
    if [ $? -ne 0 ]; then
        echo -e "  ${RED}✗${RESET} Failed to extract dotfiles"
        return 1
    fi
    
    echo -e "  ${YELLOW}→${RESET} Copying files to ${BOLD}$config_dir${RESET}..."
    cp -r ./oui-main/* "$config_dir"/
    
    if [ $? -ne 0 ]; then
        echo -e "  ${RED}✗${RESET} Failed to copy files"
        return 1
    fi
    
    # Create symlinks
    echo -e "  ${YELLOW}→${RESET} Creating symlinks..."
    
    for f in $dot_list; do
        if [ -e "$config_dir/$f" ]; then
            rm -rf "$HOME/.$f" 2>/dev/null
            ln -s "$config_dir/$f" "$HOME/.$f"
            echo -e "    ${GREEN}✓${RESET} Linked ${BOLD}.$f${RESET}"
        else
            echo -e "    ${YELLOW}!${RESET} Skipping ${BOLD}.$f${RESET} (not found in dotfiles)"
        fi
    done
    
    # Cleanup
    rm -rf "$temp_dir"
    
    echo -e "${GREEN}✓ Dotfiles installation complete!${RESET}"
    return 0
}

# Remove dotfiles
remove_dotfiles() {
    echo -e "${CYAN}Removing dotfiles...${RESET}"
    
    # List of dotfiles to remove
    local dot_list="bashrc zshrc config starship kitty nvim waybar hypr wofi mako waypaper"
    
    # Remove symlinks
    echo -e "  ${YELLOW}→${RESET} Removing symlinks..."
    for f in $dot_list; do
        if [ -L "$HOME/.$f" ]; then
            rm -f "$HOME/.$f"
            echo -e "    ${GREEN}✓${RESET} Removed symlink ${BOLD}.$f${RESET}"
        elif [ -e "$HOME/.$f" ]; then
            echo -e "    ${YELLOW}!${RESET} Skipping ${BOLD}.$f${RESET} (not a symlink)"
        fi
    done
    
    # Restore EPITA defaults if we're on an EPITA system
    if [ -d "/afs/cri.epita.fr/resources/confs" ]; then
        echo -e "  ${YELLOW}→${RESET} Restoring EPITA default configuration..."
        rm -rf "$AFS_DIR/.confs"/* 2>/dev/null
        cp -r /afs/cri.epita.fr/resources/confs/* "$AFS_DIR/.confs"/ 2>/dev/null
        echo -e "  ${GREEN}✓${RESET} EPITA defaults restored"
    else
        echo -e "  ${YELLOW}!${RESET} Not on EPITA system, skipping default restoration"
    fi
    
    echo -e "${GREEN}✓ Dotfiles removal complete!${RESET}"
    return 0
}

# Main menu
show_menu() {
    echo -e "${CYAN}What would you like to do?${RESET}"
    echo -e "  ${GREEN}1)${RESET} Install dotfiles"
    echo -e "  ${RED}2)${RESET} Remove dotfiles"
    echo -e "  ${YELLOW}3)${RESET} Cancel and exit"
    echo ""
    read -p "Enter your choice (1-3): " choice
    
    case "$choice" in
        1)
            backup_existing_config
            install_dotfiles
            ;;
        2)
            remove_dotfiles
            ;;
        3)
            echo -e "${YELLOW}Exiting without changes.${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please enter 1, 2, or 3.${RESET}"
            show_menu
            ;;
    esac
}

# Main execution
clear
check_sudo
print_banner
detect_environment
check_existing_config
show_menu

# Instructions after install
if [ $? -eq 0 ] && [ "$choice" == "1" ]; then
    echo ""
    echo -e "${CYAN}Next steps:${RESET}"
    echo -e "  ${YELLOW}1.${RESET} Log out or restart your system"
    echo -e "  ${YELLOW}2.${RESET} If on EPITA system: Use ${BOLD}Ctrl + Alt + F1${RESET} to switch to tty1, log in, then run 'bash'"
fi

echo ""
echo -e "${BLUE}Thank you for using Oui! Have a nice day.${RESET}"
