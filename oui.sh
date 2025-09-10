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
    
    # Create .confs directory if it doesn't exist
    local config_dir="$AFS_DIR/.confs"
    mkdir -p "$config_dir"
    
    # List of dotfiles to install
    local dot_list="bashrc zshrc config starship kitty nvim waybar hypr wofi mako waypaper"
    
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
    
    # Create symlinks
    echo -e "  ${YELLOW}→${RESET} Creating symlinks..."
    
    for f in $dot_list; do
        if [ -e "$config_dir/$f" ]; then
            rm -rf "$HOME/.$f" 2>/dev/null
            ln -s "$config_dir/$f" "$HOME/.$f"
            echo -e "    ${GREEN}✓${RESET} Lien créé pour ${BOLD}.$f${RESET}"
        else
            echo -e "    ${YELLOW}!${RESET} Ignoré ${BOLD}.$f${RESET} (non trouvé dans les dotfiles)"
        fi
    done
    
    # Cleanup
    rm -rf "$temp_dir"
    
    echo -e "${GREEN}✓ Installation des dotfiles terminée !${RESET}"
    return 0
}

# Remove dotfiles
remove_dotfiles() {
    echo -e "${CYAN}Suppression des dotfiles...${RESET}"
    
    # List of dotfiles to remove
    local dot_list="bashrc zshrc config starship kitty nvim waybar hypr wofi mako waypaper"
    
    # Remove symlinks
    echo -e "  ${YELLOW}→${RESET} Suppression des liens symboliques..."
    for f in $dot_list; do
        if [ -L "$HOME/.$f" ]; then
            rm -f "$HOME/.$f"
            echo -e "    ${GREEN}✓${RESET} Lien symbolique supprimé ${BOLD}.$f${RESET}"
        elif [ -e "$HOME/.$f" ]; then
            echo -e "    ${YELLOW}!${RESET} Ignoré ${BOLD}.$f${RESET} (n'est pas un lien symbolique)"
        fi
    done
    
    # Restore EPITA defaults if we're on an EPITA system
    if [ -d "/afs/cri.epita.fr/resources/confs" ]; then
    echo -e "  ${YELLOW}→${RESET} Restauration de la configuration par défaut EPITA..."
        rm -rf "$AFS_DIR/.confs"/* 2>/dev/null
        cp -r /afs/cri.epita.fr/resources/confs/* "$AFS_DIR/.confs"/ 2>/dev/null
    echo -e "  ${GREEN}✓${RESET} Configuration EPITA restaurée"
    else
    echo -e "  ${YELLOW}!${RESET} Système EPITA non détecté, restauration par défaut ignorée"
    fi
    
    echo -e "${GREEN}✓ Suppression des dotfiles terminée !${RESET}"
    return 0
}

# Main menu
show_menu() {
    while true; do
        echo -e "${CYAN}Que souhaitez-vous faire ?${RESET}"
        echo -e "  ${GREEN}1)${RESET} Installer les dotfiles"
        echo -e "  ${RED}2)${RESET} Supprimer les dotfiles"
        echo -e "  ${YELLOW}3)${RESET} Annuler et quitter"
        echo ""
        # Utilisation de /dev/tty pour s'assurer de lire depuis le terminal
        read -p "Entrez votre choix (1-3) : " choice </dev/tty
        # Si read échoue (EOF, pipe, etc.), quitter
        if [ $? -ne 0 ] || [ -z "$choice" ]; then
            echo -e "${RED}Aucune entrée détectée. Sortie...${RESET}"
            exit 1
        fi
        case "$choice" in
            1)
                install_dotfiles
                break
                ;;
            2)
                remove_dotfiles
                break
                ;;
            3)
                echo -e "${YELLOW}Sortie sans modification.${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Option invalide. Veuillez entrer 1, 2 ou 3.${RESET}"
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
if [ $? -eq 0 ] && [ "$choice" == "1" ]; then
    echo ""
    echo -e "${CYAN}Prochaines étapes :${RESET}"
    echo -e "  ${YELLOW}1.${RESET} Déconnectez-vous ou redémarrez votre système"
    echo -e "  ${YELLOW}2.${RESET} Si vous êtes sur un système EPITA : Utilisez ${BOLD}Ctrl + Alt + F1${RESET} pour passer à tty1, connectez-vous, puis lancez 'bash'"
fi

echo ""
echo -e "${BLUE}Merci d'utiliser Oui ! Bonne journée.${RESET}"
