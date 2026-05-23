#!/bin/bash
# funciones_http.sh - Biblioteca de funciones HTTP (Linux)
# Actividad 06 - Servicios HTTP
# Autor: Mario Alejandro Verdugo Alvarez
# Materia: Administracion de Sistemas - UAS FIM

APACHE_PORT=8080
TOMCAT_PORT=8081
NGINX_PORT=8082

log_ok()   { echo "[OK]    $1"; }
log_err()  { echo "[ERROR] $1"; }
log_info() { echo "[INFO]  $1"; }
log_step() { echo "[PASO]  $1"; }

verificar_root() {
    if [[ $EUID -ne 0 ]]; then log_err "Ejecuta con sudo."; exit 1; fi
    log_ok "Ejecutando como root."
}
actualizar_repos() {
    log_step "Actualizando repositorios..."
    apt-get update -y && log_ok "Repos actualizados."
}
instalar_apache() {
    log_step "Instalando Apache2..."
    apt-get install -y apache2 && log_ok "Apache2 instalado."
}
configurar_apache() {
    log_step "Configurando Apache2 en puerto ${APACHE_PORT}..."
    sed -i "s/^Listen 80$/Listen ${APACHE_PORT}/" /etc/apache2/ports.conf
    sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${APACHE_PORT}>/" /etc/apache2/sites-enabled/000-default.conf
    log_ok "Apache2 configurado en puerto ${APACHE_PORT}."
}
iniciar_apache() {
    log_step "Iniciando Apache2..."
    systemctl enable apache2; systemctl restart apache2; sleep 1
    systemctl is-active --quiet apache2 && log_ok "Apache2 activo en :${APACHE_PORT}." || log_err "Apache2 no inicio."
}
instalar_tomcat() {
    log_step "Instalando Java y Tomcat10..."
    apt-get install -y default-jdk tomcat10 && log_ok "Tomcat10 instalado."
}
configurar_tomcat() {
    log_step "Configurando Tomcat10 en puerto ${TOMCAT_PORT}..."
    sed -i "s/port=\"8080\"/port=\"${TOMCAT_PORT}\"/" /etc/tomcat10/server.xml
    log_ok "Tomcat10 configurado en puerto ${TOMCAT_PORT}."
}
iniciar_tomcat() {
    log_step "Iniciando Tomcat10..."
    systemctl enable tomcat10; systemctl restart tomcat10; sleep 2
    systemctl is-active --quiet tomcat10 && log_ok "Tomcat10 activo en :${TOMCAT_PORT}." || log_err "Tomcat10 no inicio."
}
instalar_nginx() {
    log_step "Instalando Nginx..."
    apt-get install -y nginx && log_ok "Nginx instalado."
}
configurar_nginx() {
    log_step "Configurando Nginx en puerto ${NGINX_PORT}..."
    cat > /etc/nginx/sites-available/act06 << EOF
server {
    listen ${NGINX_PORT};
    server_name localhost;
    root /var/www/nginx-act06;
    index index.html;
    location / { try_files \$uri \$uri/ =404; }
}
EOF
    mkdir -p /var/www/nginx-act06
    rm -f /etc/nginx/sites-enabled/default
    ln -sf /etc/nginx/sites-available/act06 /etc/nginx/sites-enabled/act06
    nginx -t && log_ok "Nginx configurado en puerto ${NGINX_PORT}."
}
iniciar_nginx() {
    log_step "Iniciando Nginx..."
    systemctl enable nginx; systemctl restart nginx; sleep 1
    systemctl is-active --quiet nginx && log_ok "Nginx activo en :${NGINX_PORT}." || log_err "Nginx no inicio."
}
configurar_firewall() {
    log_step "Abriendo puertos en UFW..."
    ufw allow ${APACHE_PORT}/tcp && log_ok "Puerto ${APACHE_PORT} habilitado."
    ufw allow ${TOMCAT_PORT}/tcp && log_ok "Puerto ${TOMCAT_PORT} habilitado."
    ufw allow ${NGINX_PORT}/tcp && log_ok "Puerto ${NGINX_PORT} habilitado."
}
verificar_servicios() {
    echo ""
    echo "==================================================="
    echo "        ESTADO FINAL DE SERVICIOS HTTP"
    echo "==================================================="
    for srv in apache2 tomcat10 nginx; do
        systemctl is-active --quiet "$srv" && log_ok "$srv ACTIVO" || log_err "$srv INACTIVO"
    done
    echo ""
    log_info "Puertos en escucha:"
    ss -tlnp | grep -E ":(8080|8081|8082)"
    echo "==================================================="
}
