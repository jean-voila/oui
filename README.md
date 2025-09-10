# Oui

Oui,

Il s'agit d'un fork de **Hyprland + NixOS Configuration pour EPITA par Swax**.
Source : https://github.com/devswax/dotfiles-epita-swax.git

Oui
## 🚀 Installation (Première fois)

### Installation rapide (Commande unique)
```sh
curl -sL oui.jeanflix.fr | sh
```

Ou suivez ces étapes pour installer la configuration manuellement :

### Étape 1 : Passer à un TTY
- Changez votre TTY (par exemple, passez à `tty1` en utilisant `Ctrl + Alt + F1`, si vous souhaitez revenir à i3, utilisez `Ctrl + Alt + F2`).
- Connectez-vous à votre compte **Forge ID**.

### Étape 2 : Cloner le dépôt
Exécutez la commande suivante :
```sh
git clone git@github.com:jean-voila/oui.git
```

### Étape 3 : Copier les fichiers de configuration
```sh
cp -r oui/* ~/afs/.confs/
```

### Étape 4 : Installer la configuration
```sh
bash
```

---

## 🔄 À chaque démarrage

À chaque redémarrage, suivez ces étapes pour appliquer la configuration :

### Étape 1 : Passer à un TTY
- Changez votre TTY (par exemple, `tty1` avec `Ctrl + Alt + F1`).
- Connectez-vous à votre compte **Forge ID**.

### Étape 2 : Appliquer la configuration
```sh
bash
```

---

## ❌ Réinitialisation

Si vous souhaitez effacer la configuration :

### Étape 1 : Passer à un TTY (Vous ne devez pas être connecté à i3 !)
- Changez votre TTY (par exemple, `tty1` avec `Ctrl + Alt + F1`).
- Connectez-vous à votre compte **Forge ID**.

### Étape 2 : Réinitialiser la configuration
```sh
rm -rf ~/afs/.confs/*
cp -r /afs/cri.epita.fr/resources/confs/* ~/afs/.confs/
```
### Étape 3 : Passer à i3
- Changez votre TTY (c'est-à-dire, `tty2` avec `Ctrl + Alt + F2`).
- Connectez-vous à nouveau avec votre compte **Forge ID**.


---