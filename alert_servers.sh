#!/bin/bash

# alerte_avec_debug.sh
GMAIL_USER="myveshenri@gmail.com"
GMAIL_PASS="faln mvzg ifso lcqh"
ADMIN_EMAIL="mbula.gilberto@gmail.com"  # ⬅️ UTILISEZ UNE AUTRE ADRESSE

node_alerte_envoyee=0
python_alerte_envoyee=0

alerter() {
    local sujet="$1"
    local message="$2"
    
    echo "🔄 Tentative d'envoi à l'admin: $sujet"
    echo "📧 De: $GMAIL_USER → Vers: $ADMIN_EMAIL"
    
    # Créer un fichier temporaire pour l'email
    cat > /tmp/email_content.txt << EOF
From: Serveur Monitor <$GMAIL_USER>
To: Administrateur <$ADMIN_EMAIL>
Subject: $sujet

$message

---
Envoyé automatiquement le $(date)
EOF

    # Envoyer avec verbose
    curl -v --url "smtps://smtp.gmail.com:465" \
        --ssl-reqd \
        --mail-from "$GMAIL_USER" \
        --mail-rcpt "$ADMIN_EMAIL" \
        --user "$GMAIL_USER:$GMAIL_PASS" \
        --upload-file /tmp/email_content.txt 2>&1 | grep -E "connected|authenticated|failed|error|250"
    
    local result=$?
    rm -f /tmp/email_content.txt
    
    if [ $result -eq 0 ]; then
        echo "✅ Alerte envoyée à l'admin: $sujet"
    else
        echo "❌ Échec envoi alerte: $sujet"
    fi
}

# Test de connexion Gmail au démarrage
echo "🧪 Test de connexion Gmail..."
echo "Expéditeur: $GMAIL_USER"
echo "Destinataire: $ADMIN_EMAIL"
alerter "Test de configuration" "Ceci est un test de l'alerte serveur."

echo "🔍 Démarrage de la surveillance - Alertes vers: $ADMIN_EMAIL"

while true; do
    echo "--- Vérification à $(date '+%H:%M:%S') ---"
    
    # Vérifier Node.js
    if pgrep -f "serveur_node.js" > /dev/null; then
        if [ $node_alerte_envoyee -eq 1 ]; then
            echo "✅ Node.js restauré"
            node_alerte_envoyee=0
        else
            echo "✅ Node.js fonctionne"
        fi
    else
        if [ $node_alerte_envoyee -eq 0 ]; then
            echo "🚨 Node.js arrêté - Envoi alerte à l'admin..."
            alerter "🚨 ALERTE: Serveur Node.js ARRÊTÉ" "Le serveur Node.js est arrêté et nécessite une intervention manuelle.\n\nDétecté à: $(date)\n\nAction: Redémarrage manuel requis."
            node_alerte_envoyee=1
        else
            echo "🚨 Node.js toujours arrêté (alerte déjà envoyée)"
        fi
    fi
    
    # Vérifier Python
    if pgrep -f "serveur_python.py" > /dev/null; then
        if [ $python_alerte_envoyee -eq 1 ]; then
            echo "✅ Python restauré"
            python_alerte_envoyee=0
        else
            echo "✅ Python fonctionne"
        fi
    else
        if [ $python_alerte_envoyee -eq 0 ]; then
            echo "🚨 Python arrêté - Envoi alerte à l'admin..."
            alerter "🚨 ALERTE: Serveur Python ARRÊTÉ" "Le serveur Python est arrêté et nécessite une intervention manuelle.\n\nDétecté à: $(date)\n\nAction: Redémarrage manuel requis."
            python_alerte_envoyee=1
        else
            echo "🚨 Python toujours arrêté (alerte déjà envoyée)"
        fi
    fi
    
    echo "⏱  Attente 30 secondes..."
    echo ""
    sleep 30
done
