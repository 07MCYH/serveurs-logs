#!/bin/bash

# rotation_logs_github.sh
# Rotation des logs + envoi vers GitHub

echo "🚀 Début rotation logs + GitHub - $(date)"

# Configuration
REPO_GITHUB="https://github.com/07MCYH/serveurs-logs.git"
BRANCHE="main"
EMAIL_GIT="myveshenri@gmail.com"
NOM_GIT="07MCYH"

# 1. Rotation des logs
echo "📁 Rotation des logs..."
mkdir -p logs/archives

rotation_log() {
    local nom_fichier="$1"
    
    if [[ -f "$nom_fichier" && -s "$nom_fichier" ]]; then
        timestamp=$(date '+%Y%m%d_%H%M%S')
        archive_nom="logs/archives/${nom_fichier%.*}_${timestamp}.log"
        
        # Archiver
        cp "$nom_fichier" "$archive_nom"
        > "$nom_fichier"
        
        echo "✅ Archivé: $archive_nom"
        return 0
    else
        echo "ℹ️  Fichier vide: $nom_fichier"
        return 1
    fi
}

# Rotation des fichiers
echo "🔄 Rotation en cours..."
rotation_log "node.log"
rotation_log "python.log"
rotation_log "surveillance.log"

# 2. Opérations Git
echo "📤 Préparation envoi GitHub..."

# Initialiser Git si nécessaire
if [[ ! -d ".git" ]]; then
    echo "🔄 Initialisation repository Git..."
    git init
    git config user.email "$EMAIL_GIT"
    git config user.name "$NOM_GIT"
    
    # Créer .gitignore
    cat > .gitignore << EOF
*.pyc
__pycache__/
node_modules/
.env
*.tmp
EOF
fi

# Configurer remote GitHub
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "🌐 Configuration remote GitHub..."
    git remote add origin "$REPO_GITHUB"
fi

# Ajouter les nouveaux fichiers
git add logs/archives/

# Vérifier s'il y a des changements
if git diff --staged --quiet; then
    echo "ℹ️  Aucun nouveau log à pousser"
else
    # Faire le commit
    git commit -m "📊 Rotation logs automatique - $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Push vers GitHub
    echo "⬆️  Push vers GitHub..."
    if git push -u origin "$BRANCHE" 2>/dev/null; then
        echo "✅ GitHub: Push réussi"
    else
        # Si main ne marche pas, essayer master
        git push -u origin master 2>/dev/null && echo "✅ GitHub: Push réussi (branch master)" || echo "❌ GitHub: Erreur push"
    fi
fi

echo "✅ Rotation terminée - $(date)"
echo "---"
