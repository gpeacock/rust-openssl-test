# setup-rust-openssl.ps1
# Script to setup Rust with OpenSSL using Visual Studio tools on GitHub Actions windows-latest image

# Stop on first error
$ErrorActionPreference = "Stop"

Write-Host "Setting up Rust with OpenSSL (MSVC) environment..."

# Define variables
$OPENSSL_VERSION = "3.1.4"
$OPENSSL_DIR = "C:\OpenSSL"
$TEMP_DIR = "C:\openssl_build"
$VCVARS_PATH = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

# Create directories
New-Item -ItemType Directory -Force -Path $TEMP_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $OPENSSL_DIR | Out-Null

# Change to temp directory
Push-Location $TEMP_DIR

try {
    # Download OpenSSL source
    Write-Host "Downloading OpenSSL source..."
    $openssl_url = "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz"
    Invoke-WebRequest -Uri $openssl_url -OutFile "openssl.tar.gz"
    
    # Extract OpenSSL
    Write-Host "Extracting OpenSSL source..."
    tar -xf openssl.tar.gz
    
    # Setup Visual Studio environment
    Write-Host "Setting up Visual Studio environment..."
    cmd.exe /c "call `"$VCVARS_PATH`" && set > %temp%\vcvars.txt"
    Get-Content "$env:temp\vcvars.txt" | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            $name = $matches[1]
            $value = $matches[2]
            [Environment]::SetEnvironmentVariable($name, $value, [EnvironmentVariableTarget]::Process)
        }
    }
    
    # Configure and build OpenSSL
    Write-Host "Configuring and building OpenSSL..."
    cd "openssl-$OPENSSL_VERSION"
    
    # Configure OpenSSL for MSVC (not MinGW/GNU)
    perl Configure VC-WIN64A --prefix=$OPENSSL_DIR --openssldir=$OPENSSL_DIR\ssl
    
    # Build and install OpenSSL
    nmake
    nmake install_sw
    
    # Set environment variables for Rust
    Write-Host "Setting environment variables for Rust..."
    [Environment]::SetEnvironmentVariable("OPENSSL_DIR", $OPENSSL_DIR, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("OPENSSL_LIB_DIR", "$OPENSSL_DIR\lib", [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("OPENSSL_INCLUDE_DIR", "$OPENSSL_DIR\include", [EnvironmentVariableTarget]::Machine)
    
    # Set for current process as well
    $env:OPENSSL_DIR = $OPENSSL_DIR
    $env:OPENSSL_LIB_DIR = "$OPENSSL_DIR\lib"
    $env:OPENSSL_INCLUDE_DIR = "$OPENSSL_DIR\include"
    
    # Ensure Rust is using MSVC toolchain
    Write-Host "Configuring Rust to use MSVC toolchain..."
    rustup default stable-msvc
    rustup update stable-msvc
    
    # Add OpenSSL bin to PATH for DLLs
    $current_path = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
    $new_path = "$OPENSSL_DIR\bin;$current_path"
    [Environment]::SetEnvironmentVariable("PATH", $new_path, [EnvironmentVariableTarget]::Machine)
    $env:PATH = "$OPENSSL_DIR\bin;$env:PATH"
    
    # Output summary
    Write-Host "`n=== Configuration Summary ===`n"
    Write-Host "OpenSSL installed to: $OPENSSL_DIR"
    Write-Host "OpenSSL version: $OPENSSL_VERSION"
    Write-Host "Rust toolchain: $(rustc --version)"
    Write-Host "Environment variables set:"
    Write-Host "  OPENSSL_DIR = $env:OPENSSL_DIR"
    Write-Host "  OPENSSL_LIB_DIR = $env:OPENSSL_LIB_DIR"
    Write-Host "  OPENSSL_INCLUDE_DIR = $env:OPENSSL_INCLUDE_DIR"
    Write-Host "`nSetup completed successfully!"
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
} finally {
    # Return to original directory
    Pop-Location
}