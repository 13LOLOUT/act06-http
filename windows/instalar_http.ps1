# instalar_http.ps1 - Script principal HTTP (Windows)
# Actividad 06 - Servicios HTTP
# Autor: Mario Alejandro Verdugo Alvarez
# Materia: Administracion de Sistemas - UAS FIM
# Profesor: Dr. Herman Geovany Ayala Zuniga

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\funciones_http.ps1"

Clear-Host
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "      ACTIVIDAD 06 - SERVICIOS HTTP (Windows)         " -ForegroundColor Cyan
Write-Host "   IIS :80 | XAMPP/Apache :8083 | Nginx :8084         " -ForegroundColor Cyan
Write-Host "      Mario Alejandro Verdugo Alvarez - UAS FIM        " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

Verify-Admin

Write-Info "-- FASE 1: IIS (Puerto 80) --------------------------"
Install-IIS
Start-IIS

Write-Host ""
Write-Info "-- FASE 2: XAMPP/Apache (Puerto 8083) ---------------"
Configure-XAMPP
Start-XAMPP

Write-Host ""
Write-Info "-- FASE 3: Nginx (Puerto 8084) ----------------------"
Install-Nginx
Configure-Nginx
Start-Nginx

Write-Host ""
Write-Info "-- VERIFICACION FINAL --------------------------------"
Verify-Services

Write-Host ""
Write-OK "Instalacion completa. Los 3 servicios HTTP estan activos."
Write-Info "  -> IIS          : http://localhost:80"
Write-Info "  -> XAMPP/Apache : http://localhost:8083"
Write-Info "  -> Nginx        : http://localhost:8084"
