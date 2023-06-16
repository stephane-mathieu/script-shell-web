#!/bin/bash

# Vérification des droits d'exécution en tant que root
if [[ $EUID -ne 0 ]]; then
  echo "Ce script doit être exécuté en tant que superutilisateur (root)."
  exit 1
fi

set -e

# Récupération du répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Nom du fichier de log
LOG_FILE="${SCRIPT_DIR}/install.log"

# Fonction pour enregistrer l'état de l'installation dans le fichier de log
log_status() {
  local status=$1
  local message=$2
  echo "$(date) - $status: $message" >> "$LOG_FILE"
}


#  prochaine Feature v1.2

#fonction pour installer le paquet gitkraken et autre paquet pour le systeme du choix d'installation


# Fonction pour installer un paquet avec apt
install_package() {
  local package=$1
  apt install -y "$package" || {
    log_status "ERREUR" "Échec de l'installation du paquet $package"
    exit 1
  }
  log_status "SUCCÈS" "Installation du paquet $package"
}

# Fonction pour désinstaller un paquet avec apt
uninstall_package() {
  local package=$1
  apt remove -y "$package" || {
    log_status "ERREUR" "Échec de la désinstallation du paquet $package"
    exit 1
  }
  log_status "SUCCÈS" "Désinstallation du paquet $package"
}

#  prochaine Feature v1.2

# Fonction pour afficher le menu d'aide
display_help() {
  echo "Menu d'aide :"
  echo "- all        : Installer tous les programmes"
  echo "- update     : Mettre à jour les packages système"
  echo "- reinstall  : Réinstaller tous les packages du script"
  echo "- remove     : Supprimer tous les packages du script"
  echo "- vscode     : Lancer Visual Studio Code"
  echo "- gitkraken  : Lancer GitKraken"
  echo "- nodejs     : Lancer Node.js"
  echo "- webdev     : Lancer les outils de développement web"
  echo "- apache     : Lancer Apache"
  echo "- help       : Afficher le menu d'aide (en cour de développement)"
  echo "- quit       : Quitter"
}

launch_vscode() {
  echo "Lancement de Visual Studio Code..."
  sudo -u $SUDO_USER code --user-data-dir=/tmp/vscode_$SUDO_USER || {
    log_status "ERREUR" "Échec du lancement de Visual Studio Code"
    echo "Une erreur s'est produite lors du lancement de Visual Studio Code."
    echo "Veuillez vérifier que Visual Studio Code est installé correctement."
    echo "Si ce n'est pas le cas, vous pouvez l'installer en exécutant 'install_package code'."
    return 1
  }
  log_status "SUCCÈS" "Lancement de Visual Studio Code"
}


# Fonction pour lancer GitKraken
launch_gitkraken() {
  echo "Lancement de GitKraken..."
  /opt/gitkraken/gitkraken || {
    log_status "ERREUR" "Échec du lancement de GitKraken"
    echo "Une erreur s'est produite lors du lancement de GitKraken."
    echo "Veuillez vérifier que GitKraken est installé correctement."
    echo "Si ce n'est pas le cas, vous pouvez l'installer en exécutant 'install_package gitkraken'."
    return 1
  }
  log_status "SUCCÈS" "Lancement de GitKraken"
}

# Fonction pour lancer Node.js
launch_nodejs() {
  echo "Lancement de Node.js..."
  node || {
    log_status "ERREUR" "Échec du lancement de Node.js"
    echo "Une erreur s'est produite lors du lancement de Node.js."
    echo "Veuillez vérifier que Node.js est installé correctement."
    echo "Si ce n'est pas le cas, vous pouvez l'installer en exécutant 'install_package nodejs'."
    return 1
  }
  log_status "SUCCÈS" "Lancement de Node.js"
}

# Fonction pour lancer Apache
launch_apache() {
  echo "Lancement d'Apache..."
  systemctl start apache2 || {
    log_status "ERREUR" "Échec du lancement d'Apache"
    echo "Une erreur s'est produite lors du lancement d'Apache."
    echo "Veuillez vérifier que Apache est installé correctement."
    echo "Si ce n'est pas le cas, vous pouvez l'installer en exécutant 'install_package apache2'."
    return 1
  }
  log_status "SUCCÈS" "Lancement d'Apache"
}

# Fonction pour lancer les outils de développement web
launch_webdev() {
  echo "Lancement des outils de développement web..."
  launch_apache  # Appel à la fonction launch_apache
  launch_vscode  # Appel à la fonction launch_vscode
  # Ajoutez d'autres commandes de lancement des outils de développement web ici
}


# Fonction pour installer tous les programmes
install_all() {
  echo "Installation de tous les programmes..."
  
echo "Installation de Visual Studio Code..."
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list
apt update
install_package code



  # Installation de LAMPP
  echo "Installation de LAMPP..."
  install_package apache2 mariadb-server php libapache2-mod-php php-mysql
  sudo systemctl enable apache2
  sudo systemctl enable mariadb
  sudo systemctl start apache2
  sudo systemctl start mariadb


  # Installation de GitKraken
  echo "Installation de GitKraken..."
  wget -O "${SCRIPT_DIR}/gitkraken.deb" https://release.gitkraken.com/linux/gitkraken-amd64.deb
  dpkg -i "${SCRIPT_DIR}/gitkraken.deb"
  apt --fix-broken install -y
  log_status "SUCCÈS" "Installation du paquet gitkraken"

  # Installation de Node.js
  echo "Installation de Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  install_package nodejs

  # Installation d'Apache
  echo "Installation d'Apache..."
  install_package apache2

  echo "Installation terminée !"
}

# Fonction pour mettre à jour les packages système
update_packages() {
  echo "Mise à jour des packages système..."
  apt update
  apt upgrade -y
  log_status "SUCCÈS" "Mise à jour des packages système"
}

# Fonction pour réinstaller tous les packages du script
reinstall_packages() {
  echo "Réinstallation de tous les packages du script..."
  initialize_log_file
  uninstall_packages
  install_all
}

# Fonction pour supprimer tous les packages du script
remove_packages() {
  echo "Suppression de tous les packages du script..."
  uninstall_packages
}

# Fonction pour désinstaller tous les packages du script
uninstall_packages() {
  echo "Désinstallation de tous les packages du script..."
  
  # Désinstallation de Visual Studio Code
  sudo dpkg --force-all -P code

  # Désinstallation de GitKraken
  sudo dpkg --force-all -P gitkraken

  # Désinstallation de Node.js
  sudo dpkg --force-all -P nodejs

  # Désinstallation d'Apache
  sudo dpkg --force-all -P  apache2

  echo "Désinstallation terminée !"
}

# Fonction pour initialiser le fichier de log
initialize_log_file() {
  echo "Journal d'installation" > "$LOG_FILE"
  echo "---------------------" >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"
}

# Affichage du menu principal
display_menu() {
  echo "Menu principal :"
  echo "- all        : Installer tous les programmes"
  echo "- update     : Mettre à jour les packages système"
  echo "- reinstall  : Réinstaller tous les packages du script"
  echo "- remove     : Supprimer tous les packages du script"
  echo "- vscode     : Lancer Visual Studio Code"
  echo "- gitkraken  : Lancer GitKraken"
  echo "- nodejs     : Lancer Node.js"
  echo "- webdev     : Lancer les outils de développement web"
  echo "- apache     : Lancer Apache"
  echo "- help       : Afficher le menu d'aide (en cour de développement)"
  echo "- quit       : Quitter"

  while true; do
    read -p "Que souhaitez-vous faire ? " choice
    case "$choice" in
      all)
        initialize_log_file
        install_all ;;
      update)
        update_packages ;;
      reinstall)
        reinstall_packages ;;
      remove)
        remove_packages ;;
      vscode)
        launch_vscode ;;
      gitkraken)
        launch_gitkraken ;;
      nodejs)
        launch_nodejs ;;
      webdev)
        launch_webdev ;;
      apache)
        launch_apache ;;
      help)
        display_help ;;
      quit)
        break ;;
      *)
        echo "Option invalide. Veuillez réessayer." ;;
    esac
  done
}

# Vérification des arguments de ligne de commande
if [ $# -eq 0 ]; then
  # Si aucun argument n'est fourni, afficher le menu principal
  display_menu
else
  # Si des arguments sont fournis, les traiter individuellement
  for arg in "$@"; do
    case "$arg" in
      all)
        initialize_log_file
        install_all ;;
      update)
        update_packages ;;
      reinstall)
        reinstall_packages ;;
      remove)
        remove_packages ;;
      vscode)
        launch_vscode ;;
      gitkraken)
        launch_gitkraken ;;
      nodejs)
        launch_nodejs ;;
      webdev)
        launch_webdev ;;
      apache)
        launch_apache ;;
      help)
        display_help ;;
      *)
        echo "Option invalide : $arg. Veuillez réessayer." ;;
    esac
  done
fi
