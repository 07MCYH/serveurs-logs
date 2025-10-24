#!/bin/bash

# Script de surveillance et relance automatique des serveurs
# Auteur: Assistant IA
# Version: 1.0

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NODE_SERVER="serveur_node.js"
PYTHON_SERVER="serveur_python.py"
LOG_FILE="server_monitor.log"
CHECK_INTERVAL=5  # Vérification toutes les 5 secondes

# Fonctions d'affichage
info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCÈS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERREUR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Fonction pour vérifier si un processus est en cours d'exécution
is_process_running() {
    local process_name="$1"
    local server_type="$2"
    
    if [[ "$server_type" == "node" ]]; then
        # Pour Node.js, on cherche le fichier JavaScript
        pgrep -f "node.*$process_name" > /dev/null 2>&1
        return $?
    else
        # Pour Python, on cherche le fichier Python
        pgrep -f "python.*$process_name" > /dev/null 2>&1
        return $?
    fi
}

# Fonction pour obtenir le PID d'un processus
get_pid() {
    local process_name="$1"
    local server_type="$2"
    
    if [[ "$server_type" == "node" ]]; then
        pgrep -f "node.*$process_name"
    else
        pgrep -f "python.*$process_name"
    fi
}

# Fonction pour démarrer le serveur Node.js
start_node_server() {
    info "Démarrage du serveur Node.js: $NODE_SERVER"
    
    if [[ ! -f "$NODE_SERVER" ]]; then
        error "Fichier $NODE_SERVER non trouvé!"
        return 1
    fi
    
    # Démarrer en arrière-plan et rediriger les logs
    node "$NODE_SERVER" >> "node_server.log" 2>&1 &
    local node_pid=$!
    
    # Attendre un peu pour voir si le démarrage réussit
    sleep 2
    
    if is_process_running "$NODE_SERVER" "node"; then
        success "Serveur Node.js démarré avec PID: $node_pid"
        echo "$node_pid" > "node_server.pid"
        return 0
    else
        error "Échec du démarrage du serveur Node.js"
        return 1
    fi
}

# Fonction pour démarrer le serveur Python
start_python_server() {
    info "Démarrage du serveur Python: $PYTHON_SERVER"
    
    if [[ ! -f "$PYTHON_SERVER" ]]; then
        error "Fichier $PYTHON_SERVER non trouvé!"
        return 1
    fi
    
    # Démarrer en arrière-plan et rediriger les logs
    python3 "$PYTHON_SERVER" >> "python_server.log" 2>&1 &
    local python_pid=$!
    
    # Attendre un peu pour voir si le démarrage réussit
    sleep 2
    
    if is_process_running "$PYTHON_SERVER" "python"; then
        success "Serveur Python démarré avec PID: $python_pid"
        echo "$python_pid" > "python_server.pid"
        return 0
    else
        error "Échec du démarrage du serveur Python"
        return 1
    fi
}

# Fonction pour arrêter proprement un serveur
stop_server() {
    local process_name="$1"
    local server_type="$2"
    local pid_file="$3"
    
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        info "Arrêt du serveur (PID: $pid)"
        kill "$pid" 2>/dev/null
        
        # Attendre un peu que le processus s'arrête
        local count=0
        while is_process_running "$process_name" "$server_type" && [[ $count -lt 10 ]]; do
            sleep 1
            ((count++))
        done
        
        # Si le processus est toujours en cours, forcer l'arrêt
        if is_process_running "$process_name" "$server_type"; then
            warning "Forçage de l'arrêt du serveur"
            kill -9 "$pid" 2>/dev/null
        fi
        
        rm -f "$pid_file"
        success "Serveur arrêté"
    fi
}

# Fonction de surveillance d'un serveur
monitor_server() {
    local server_name="$1"
    local process_name="$2"
    local server_type="$3"
    local pid_file="$4"
    local start_function="$5"
    
    local restart_count=0
    local max_restarts=5
    
    while true; do
        if ! is_process_running "$process_name" "$server_type"; then
            warning "Le serveur $server_name a crash ou s'est arrêté!"
            ((restart_count++))
            
            if [[ $restart_count -le $max_restarts ]]; then
                info "Tentative de relance $restart_count/$max_restarts..."
                
                # Nettoyer l'ancien PID file s'il existe
                rm -f "$pid_file"
                
                if $start_function; then
                    success "Serveur $server_name relancé avec succès"
                    # Réinitialiser le compteur après un redémarrage réussi
                    restart_count=0
                else
                    error "Échec de la relance du serveur $server_name"
                    
                    if [[ $restart_count -eq $max_restarts ]]; then
                        error "Nombre maximum de tentatives de relance atteint pour $server_name"
                        break
                    fi
                fi
            else
                error "Arrêt de la surveillance pour $server_name - trop d'échecs"
                break
            fi
        else
            # Le serveur fonctionne normalement
            local current_pid=$(get_pid "$process_name" "$server_type")
            if [[ $restart_count -eq 0 ]]; then
                info "Serveur $server_name en cours d'exécution (PID: $current_pid)"
            fi
            restart_count=0
        fi
        
        sleep "$CHECK_INTERVAL"
    done
}

# Fonction pour afficher le statut des serveurs
show_status() {
    echo
    info "=== STATUT DES SERVEURS ==="
    
    if is_process_running "$NODE_SERVER" "node"; then
        local node_pid=$(get_pid "$NODE_SERVER" "node")
        success "✓ Serveur Node.js: EN COURS (PID: $node_pid)"
    else
        error "✗ Serveur Node.js: ARRÊTÉ"
    fi
    
    if is_process_running "$PYTHON_SERVER" "python"; then
        local python_pid=$(get_pid "$PYTHON_SERVER" "python")
        success "✓ Serveur Python: EN COURS (PID: $python_pid)"
    else
        error "✗ Serveur Python: ARRÊTÉ"
    fi
    
    echo
}

# Fonction pour afficher le menu principal
show_menu() {
    echo
    echo "========================================="
    echo "  MONITEUR DE SERVEURS"
    echo "  Surveillance Node.js et Python"
    echo "========================================="
    echo
    echo "1. Démarrer la surveillance Node.js"
    echo "2. Démarrer la surveillance Python"
    echo "3. Démarrer la surveillance des deux serveurs"
    echo "4. Afficher le statut"
    echo "5. Arrêter tous les serveurs"
    echo "6. Voir les logs"
    echo "7. Quitter"
    echo
    echo -n "Choisissez une option [1-7]: "
}

# Fonction pour afficher les logs
show_logs() {
    echo
    info "=== LOGS SERVEUR NODE.JS ==="
    if [[ -f "node_server.log" ]]; then
        tail -20 "node_server.log"
    else
        echo "Aucun log disponible"
    fi
    
    echo
    info "=== LOGS SERVEUR PYTHON ==="
    if [[ -f "python_server.log" ]]; then
        tail -20 "python_server.log"
    else
        echo "Aucun log disponible"
    fi
    
    echo
    info "=== LOGS DU MONITEUR ==="
    if [[ -f "$LOG_FILE" ]]; then
        tail -10 "$LOG_FILE"
    else
        echo "Aucun log disponible"
    fi
}

# Nettoyage à l'arrêt du script
cleanup() {
    info "Arrêt du moniteur et nettoyage..."
    stop_server "$NODE_SERVER" "node" "node_server.pid"
    stop_server "$PYTHON_SERVER" "python" "python_server.pid"
    exit 0
}

# Configuration des traps pour la gestion des signaux
trap cleanup SIGINT SIGTERM

# Fonction principale
main() {
    info "Démarrage du moniteur de serveurs"
    
    local node_monitor_pid=""
    local python_monitor_pid=""
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                info "Lancement de la surveillance Node.js"
                monitor_server "Node.js" "$NODE_SERVER" "node" "node_server.pid" "start_node_server" &
                node_monitor_pid=$!
                info "Surveillance Node.js démarrée (PID: $node_monitor_pid)"
                ;;
            2)
                info "Lancement de la surveillance Python"
                monitor_server "Python" "$PYTHON_SERVER" "python" "python_server.pid" "start_python_server" &
                python_monitor_pid=$!
                info "Surveillance Python démarrée (PID: $python_monitor_pid)"
                ;;
            3)
                info "Lancement de la surveillance des deux serveurs"
                monitor_server "Node.js" "$NODE_SERVER" "node" "node_server.pid" "start_node_server" &
                node_monitor_pid=$!
                monitor_server "Python" "$PYTHON_SERVER" "python" "python_server.pid" "start_python_server" &
                python_monitor_pid=$!
                info "Surveillance complète démarrée"
                ;;
            4)
                show_status
                ;;
            5)
                info "Arrêt de tous les serveurs..."
                stop_server "$NODE_SERVER" "node" "node_server.pid"
                stop_server "$PYTHON_SERVER" "python" "python_server.pid"
                
                if [[ -n "$node_monitor_pid" ]]; then
                    kill "$node_monitor_pid" 2>/dev/null
                fi
                if [[ -n "$python_monitor_pid" ]]; then
                    kill "$python_monitor_pid" 2>/dev/null
                fi
                ;;
            6)
                show_logs
                ;;
            7)
                cleanup
                ;;
            *)
                error "Option invalide: $choice"
                ;;
        esac
        
        echo
        echo -n "Appuyez sur Entrée pour continuer..."
        read -r
        clear
    done
}

# Point d'entrée du script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
