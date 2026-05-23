#!/bin/bash
# instalar_http.sh - Script principal HTTP (Linux)
# Actividad 06 - Servicios HTTP
# Autor: Mario Alejandro Verdugo Alvarez
# Materia: Administracion de Sistemas - UAS FIM
# Profesor: Dr. Herman Geovany Ayala Zuniga

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/funciones_http.sh"

clear
echo "======================================================"
echo "       ACTIVIDAD 06 - SERVICIOS HTTP (Linux)"
echo "  Apache2 :8080 | Tomcat10 :8081 | Nginx :8082"
echo "     Mario Alejandro Verdugo Alvarez - UAS FIM"
echo "======================================================"
echo ""

verificar_root
actualizar_repos

echo ""
log_info "-- FASE 1: Apache2 ----------------------------------"
instalar_apache
configurar_apache
iniciar_apache

echo ""
log_info "-- FASE 2: Tomcat10 ---------------------------------"
instalar_tomcat
configurar_tomcat
iniciar_tomcat

echo ""
log_info "-- FASE 3: Nginx ------------------------------------"
instalar_nginx
configurar_nginx
iniciar_nginx

echo ""
log_info "-- FASE 4: Firewall ---------------------------------"
configurar_firewall

echo ""
log_info "-- VERIFICACION FINAL -------------------------------"
verificar_servicios

echo ""
log_ok "Instalacion completa. Los 3 servicios HTTP estan activos."
log_info "  -> Apache2  : http://localhost:8080"
log_info "  -> Tomcat10 : http://localhost:8081"
log_info "  -> Nginx    : http://localhost:8082"
echo ""
