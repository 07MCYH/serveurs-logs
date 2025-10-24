#!/bin/bash

# test_rotation.sh
# Test manuel de la rotation

echo "🧪 Test rotation logs + GitHub"

# Créer des logs de test
echo "$(date) - Log Node.js test" >> node.log
echo "$(date) - Log Python test" >> python.log
echo "$(date) - Surveillance test" >> surveillance.log

echo "📝 Logs de test créés"

# Exécuter la rotation
./rotation_logs_github.sh

echo "🔍 Vérification des archives:"
ls -la logs/archives/

echo "🔍 Status Git:"
git status --short
