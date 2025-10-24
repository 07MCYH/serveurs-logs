#!/bin/bash

# setup_github.sh
# Configuration initiale GitHub

echo "🔧 Configuration GitHub pour les logs"

# Vérifier si Git est installé
if ! command -v git &> /dev/null; then
    echo "❌ Git n'est pas installé"
    echo "📦 Installation: sudo apt-get install git"
    exit 1
fi

# Configuration Git
git config user.email "myveshenri@gmail.com"
git config user.name "myveshenri"

# Vérifier le repository
if [[ ! -d ".git" ]]; then
    echo "🔄 Initialisation Git..."
    git init
    
    # Premier commit
    git add .
    git commit -m "🎉 Initial commit - Logs serveurs"
fi

# Vérifier le remote
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "❌ Aucun remote GitHub configuré"
    echo "🌐 Pour configurer:"
    echo "   git remote add origin https://github.com/myveshenri/serveurs-logs.git"
else
    echo "✅ Remote GitHub configuré:"
    git remote get-url origin
fi

echo "🔍 Status Git:"
git status --short

echo "🎯 Configuration terminée"
