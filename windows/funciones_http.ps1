# funciones_http.ps1 - Biblioteca de funciones HTTP (Windows)
# Actividad 06 - Servicios HTTP
# Autor: Mario Alejandro Verdugo Alvarez
# Materia: Administracion de Sistemas - UAS FIM

$IIS_PORT   = 80
$XAMPP_PORT = 8083
$NGINX_PORT = 8084
$NGINX_PATH = "C:\nginx"
$XAMPP_PATH = "C:\xampp"

function Write-OK   { param($msg) Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-Err  { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Step { param($msg) Write-Host "[PASO]  $msg" -ForegroundColor Yellow }

function Verify-Admin {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Err "Ejecuta PowerShell como Administrador."; exit 1
    }
    Write-OK "Ejecutando como Administrador."
}
function Install-IIS {
    Write-Step "Instalando IIS..."
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole,IIS-WebServer,IIS-ManagementConsole -All -NoRestart | Out-Null
    Write-OK "IIS instalado."
}
function Start-IIS {
    Write-Step "Iniciando IIS en puerto $IIS_PORT..."
    Start-Service W3SVC -ErrorAction SilentlyContinue
    iisreset /start | Out-Null
    $svc = Get-Service -Name W3SVC
    if ($svc.Status -eq "Running") { Write-OK "IIS activo en puerto $IIS_PORT." }
    else { Write-Err "IIS no pudo iniciarse." }
}
function Configure-XAMPP {
    Write-Step "Configurando XAMPP/Apache en puerto $XAMPP_PORT..."
    $conf = "$XAMPP_PATH\apache\conf\httpd.conf"
    if (Test-Path $conf) {
        (Get-Content $conf) -replace "^Listen 80$","Listen $XAMPP_PORT" | Set-Content $conf
        Write-OK "XAMPP configurado en puerto $XAMPP_PORT."
    } else { Write-Err "No se encontro httpd.conf." }
}
function Start-XAMPP {
    Write-Step "Iniciando Apache de XAMPP..."
    $apache = "$XAMPP_PATH\apache\bin\httpd.exe"
    if (Test-Path $apache) {
        Start-Process $apache -WindowStyle Hidden; Start-Sleep 2
        if (netstat -ano | Select-String ":$XAMPP_PORT") { Write-OK "XAMPP/Apache activo en puerto $XAMPP_PORT." }
        else { Write-Err "XAMPP/Apache no pudo iniciarse." }
    } else { Write-Err "No se encontro httpd.exe." }
}
function Install-Nginx {
    Write-Step "Instalando Nginx..."
    if (-NOT (Test-Path $NGINX_PATH)) {
        Invoke-WebRequest -Uri "https://nginx.org/download/nginx-1.26.2.zip" -OutFile "C:\nginx.zip"
        Expand-Archive -Path "C:\nginx.zip" -DestinationPath "C:\" -Force
        Rename-Item "C:\nginx-1.26.2" "C:\nginx" -ErrorAction SilentlyContinue
        Remove-Item "C:\nginx.zip" -Force
        Write-OK "Nginx instalado."
    } else { Write-OK "Nginx ya instalado." }
}
function Configure-Nginx {
    Write-Step "Configurando Nginx en puerto $NGINX_PORT..."
    $conf = "$NGINX_PATH\conf\nginx.conf"
    (Get-Content $conf) -replace "listen\s+80;","listen       $NGINX_PORT;" | Set-Content $conf
    Write-OK "Nginx configurado en puerto $NGINX_PORT."
}
function Start-Nginx {
    Write-Step "Iniciando Nginx..."
    Start-Process "$NGINX_PATH\nginx.exe" -WindowStyle Hidden; Start-Sleep 2
    if (netstat -ano | Select-String ":$NGINX_PORT") { Write-OK "Nginx activo en puerto $NGINX_PORT." }
    else { Write-Err "Nginx no pudo iniciarse." }
}
function Verify-Services {
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host "      ESTADO FINAL DE SERVICIOS HTTP             " -ForegroundColor Cyan
    Write-Host "=================================================" -ForegroundColor Cyan
    $iis = Get-Service W3SVC -ErrorAction SilentlyContinue
    if ($iis.Status -eq "Running") { Write-OK "IIS          activo en puerto $IIS_PORT" } else { Write-Err "IIS INACTIVO" }
    if (netstat -ano | Select-String ":$XAMPP_PORT\s") { Write-OK "XAMPP/Apache activo en puerto $XAMPP_PORT" } else { Write-Err "XAMPP INACTIVO" }
    if (netstat -ano | Select-String ":$NGINX_PORT\s") { Write-OK "Nginx        activo en puerto $NGINX_PORT" } else { Write-Err "Nginx INACTIVO" }
    Write-Host ""; Write-Info "Puertos en escucha:"
    netstat -ano | findstr ":80 :8083 :8084"
    Write-Host "=================================================" -ForegroundColor Cyan
}
