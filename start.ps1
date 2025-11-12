#!/usr/bin/env pwsh
# set -euo pipefail  => tương đương PowerShell: $ErrorActionPreference = "Stop"
$ErrorActionPreference = "Stop"

<#
.SYNOPSIS
  start.ps1 - Chuẩn bị môi trường và chạy dự án trên máy mới.

.DESCRIPTION
  - Tạo hoặc cập nhật file .env.local với MONGODB_URI
  - Chạy npm install (trừ khi có tham số --no-install)
  - Kiểm tra kết nối MongoDB bằng scripts/check-db.js
  - Khởi chạy server dev (npm run dev)

.PARAMETER mongo-uri
  Chuỗi kết nối MongoDB (URI)

.PARAMETER port
  Cổng chạy ứng dụng Next.js (mặc định: 9002)

.PARAMETER no-install
  Bỏ qua bước cài npm install

.EXAMPLE
  ./start.ps1
  ./start.ps1 --mongo-uri "mongodb://localhost:27017/test" --port 8080
#>

function Show-Help {
    Write-Host @"
Usage: ./start.ps1 [--mongo-uri <MONGODB_URI>] [--port <PORT>] [--no-install]

This script will:
  - create or update .env.local with MONGODB_URI
  - optionally run npm install
  - run a quick DB connectivity check (scripts/check-db.js)
  - start the dev server (npm run dev)
"@
}

# --- Parse arguments ---
$MONGO_URI = ""
$PORT = if ($env:PORT) { $env:PORT } else { "9002" }
$NO_INSTALL = $false

for ($i = 0; $i -lt $args.Count; $i++) {
    switch ($args[$i]) {
        "--mongo-uri" {
            if ($i + 1 -lt $args.Count) {
                $MONGO_URI = $args[$i + 1]
                $i++
            } else {
                Write-Error "Missing value for --mongo-uri"
                exit 1
            }
        }
        "--port" {
            if ($i + 1 -lt $args.Count) {
                $PORT = $args[$i + 1]
                $i++
            } else {
                Write-Error "Missing value for --port"
                exit 1
            }
        }
        "--no-install" { $NO_INSTALL = $true }
        "--help" { Show-Help; exit 0 }
        "-h" { Show-Help; exit 0 }
        Default {
            Write-Host "Unknown option: $($_)"
            Show-Help
            exit 1
        }
    }
}

# Prefer runtime env
if ([string]::IsNullOrEmpty($MONGO_URI) -and $env:MONGODB_URI) {
    $MONGO_URI = $env:MONGODB_URI
}

# Ask user if missing
if ([string]::IsNullOrEmpty($MONGO_URI)) {
    $default = "mongodb://localhost:27017/ai-hairstyle-npa"
    $yn = Read-Host "No MongoDB URI provided. Use default $default? [Y/n]"
    if ($yn -match "^[Yy]?$") {
        $MONGO_URI = $default
    } else {
        Write-Host "Please re-run with --mongo-uri or set MONGODB_URI env var"
        exit 1
    }
}

# --- Create .env.local ---
$envFile = ".env.local"
if (Test-Path $envFile) {
    Write-Host "Backing up existing $envFile -> $envFile.bak"
    Copy-Item $envFile "$envFile.bak" -Force
}

"MONGODB_URI=$MONGO_URI" | Out-File -Encoding UTF8 $envFile
Write-Host "Wrote $envFile"

# --- Install dependencies ---
if (-not $NO_INSTALL) {
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "Installing npm dependencies..."
        npm install
    } else {
        Write-Error "npm not found in PATH. Please install Node.js and npm, then re-run."
        exit 1
    }
} else {
    Write-Host "Skipping npm install (--no-install supplied)"
}

# --- DB check ---
if (Test-Path "scripts/check-db.js") {
    Write-Host "Checking MongoDB connectivity using scripts/check-db.js"
    $env:MONGODB_URI = $MONGO_URI
    try {
        node scripts/check-db.js
    } catch {
        Write-Warning "DB check failed (continuing)"
    }
} else {
    Write-Host "No scripts/check-db.js found; skipping DB check"
}

# --- Start Next.js server ---
Write-Host "Starting Next dev server (port $PORT)"
$env:PORT = $PORT
npm run dev
