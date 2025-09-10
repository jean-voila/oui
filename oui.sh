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
    echo -e "${CYAN}Bienvenue sur l'installateur des dotfiles ${BOLD}oui${RESET}${CYAN}, les meilleurs dotfiles de tout le Texas${RESET}"
    echo -e "${MAGENTA}===========================${RESET}"
    echo ""
}

# Check if running with sudo
check_sudo() {
    if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Ce script ne doit pas être exécuté avec sudo ou en tant que root.${RESET}"
        exit 1
    fi
}

# Detect environment
detect_environment() {
    echo -e "${CYAN}Détection de l'environnement...${RESET}"
    
    # Check if AFS_DIR is set, otherwise check for AFS directory
    if [ -z "$AFS_DIR" ]; then
        if [ -d "$HOME/afs" ]; then
            AFS_DIR="$HOME/afs"
            echo -e "  ${GREEN}✓${RESET} Dossier AFS trouvé à : ${BOLD}$AFS_DIR${RESET}"
        else
            echo -e "  ${RED}✗${RESET} Dossier AFS introuvable. Ce script est destiné uniquement aux systèmes EPITA."
            echo -e "${RED}Sortie...${RESET}"
            exit 1
        fi
    else
        if [ -d "$AFS_DIR" ]; then
            echo -e "  ${GREEN}✓${RESET} Utilisation du dossier AFS : ${BOLD}$AFS_DIR${RESET}"
        else
            echo -e "  ${RED}✗${RESET} Dossier AFS spécifié ${BOLD}$AFS_DIR${RESET} introuvable."
            echo -e "${RED}Sortie...${RESET}"
            exit 1
        fi
    fi
}

# Check for existing configuration


# Install dotfiles
install_dotfiles() {
    echo -e "${CYAN}Installation des dotfiles...${RESET}"
    
    # Vérifier l'existence du dossier .confs
    local config_dir="$AFS_DIR/.confs"
    if [ ! -d "$config_dir" ]; then
        echo -e "${RED}Le dossier ${BOLD}$config_dir${RESET}${RED} n'existe pas. Veuillez le créer manuellement avant de lancer l'installation.${RESET}"
        return 1
    fi

    
    # Copy all files
    local temp_dir="$(mktemp -d)"
    cd "$temp_dir"
    
    echo -e "  ${YELLOW}→${RESET} Téléchargement des dotfiles..."
    curl -s https://codeload.github.com/jean-voila/oui/tar.gz/refs/heads/main -o dotfiles.tar.gz
    
    if [ $? -ne 0 ]; then
    echo -e "  ${RED}✗${RESET} Échec du téléchargement des dotfiles"
        return 1
    fi
    
    echo -e "  ${YELLOW}→${RESET} Extraction des fichiers..."
    tar -xzf dotfiles.tar.gz
    
    if [ $? -ne 0 ]; then
    echo -e "  ${RED}✗${RESET} Échec de l'extraction des dotfiles"
        return 1
    fi
    
    echo -e "  ${YELLOW}→${RESET} Copie des fichiers vers ${BOLD}$config_dir${RESET}..."
    cp -r ./oui-main/* "$config_dir"/
    
    if [ $? -ne 0 ]; then
        echo -e "  ${RED}✗${RESET} Failed to copy files"
        return 1
    fi

    
    # Cleanup
    command rm -rf "$temp_dir"
    
    echo -e "${GREEN}✓ Installation des dotfiles terminée !${RESET}"
    return 0
}

# Remove dotfiles

# Main menu
show_menu() {
    while true; do
        echo -e "${CYAN}Que souhaitez-vous faire ?${RESET}"
        echo -e "  ${GREEN}1)${RESET} Installer les dotfiles"
        echo -e "  ${YELLOW}2)${RESET} Annuler et quitter"
        echo ""
        # Utilisation de /dev/tty pour s'assurer de lire depuis le terminal
        read -p "Entrez votre choix (1-2) : " choice </dev/tty
        # Si read échoue (EOF, pipe, etc.), quitter
        if [ $? -ne 0 ] || [ -z "$choice" ]; then
            echo -e "${RED}Aucune entrée détectée. Sortie...${RESET}"
            exit 1
        fi
        case "$choice" in
            1)
                install_dotfiles
                install_success=$?
                break
                ;;

            2)
                echo -e "${YELLOW}Sortie sans modification.${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Option invalide. Veuillez entrer 1 ou 2.${RESET}"
                # La boucle recommence
                ;;
        esac
    done
}

# Main execution
clear
check_sudo
print_banner
detect_environment
show_menu

# Instructions after install
if [ "$choice" == "1" ] && [ "$install_success" -eq 0 ]; then
    echo ""
    echo -e "${CYAN}Prochaines étapes :${RESET} Utilisez ${BOLD}Ctrl + Alt + F1${RESET} pour passer à tty1, connectez-vous, puis lancez 'bash'"
fi

echo ""
echo -e "${BLUE}Merci d'utiliser oui. Bonne journée.${RESET}"
