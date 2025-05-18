#!/bin/bash
# setup-rust-openssl.sh - Script for setting up OpenSSL for Rust on Linux and macOS

set -e  # Exit on error

echo "Setting up OpenSSL for Rust..."

# Platform detection
OS=$(uname -s)

case $OS in
  Linux)
    echo "Detected Linux platform"
    # On Linux, we typically use the system's package manager
    if command -v apt-get &> /dev/null; then
      echo "Installing OpenSSL development packages with apt..."
      sudo apt-get update
      sudo apt-get install -y pkg-config libssl-dev
    elif command -v yum &> /dev/null; then
      echo "Installing OpenSSL development packages with yum..."
      sudo yum install -y openssl-devel
    elif command -v dnf &> /dev/null; then
      echo "Installing OpenSSL development packages with dnf..."
      sudo dnf install -y openssl-devel
    else
      echo "Unsupported Linux distribution. Please install OpenSSL development packages manually."
      exit 1
    fi
    ;;
    
  Darwin)
    echo "Detected macOS platform"
    # On macOS, we use Homebrew
    if ! command -v brew &> /dev/null; then
      echo "Homebrew is not installed. Please install it first: https://brew.sh/"
      exit 1
    fi
    
    echo "Installing OpenSSL with Homebrew..."
    brew update
    brew install openssl@3
    
    # Set environment variables
    export OPENSSL_DIR=$(brew --prefix openssl@3)
    export OPENSSL_LIB_DIR=$(brew --prefix openssl@3)/lib
    export OPENSSL_INCLUDE_DIR=$(brew --prefix openssl@3)/include
    
    echo "OpenSSL installed at: $OPENSSL_DIR"
    
    # For GitHub Actions or other CI environments
    if [[ -n "$GITHUB_ENV" ]]; then
      echo "OPENSSL_DIR=$OPENSSL_DIR" >> $GITHUB_ENV
      echo "OPENSSL_LIB_DIR=$OPENSSL_LIB_DIR" >> $GITHUB_ENV
      echo "OPENSSL_INCLUDE_DIR=$OPENSSL_INCLUDE_DIR" >> $GITHUB_ENV
      echo "Environment variables added to GITHUB_ENV"
    fi
    
    # Add to shell profile if it exists
    for PROFILE in ~/.bash_profile ~/.zshrc ~/.profile; do
      if [[ -f $PROFILE ]]; then
        if ! grep -q "OPENSSL_DIR" "$PROFILE"; then
          echo "Adding OpenSSL environment variables to $PROFILE"
          echo "export OPENSSL_DIR=$(brew --prefix openssl@3)" >> "$PROFILE"
          echo "export OPENSSL_LIB_DIR=$(brew --prefix openssl@3)/lib" >> "$PROFILE"
          echo "export OPENSSL_INCLUDE_DIR=$(brew --prefix openssl@3)/include" >> "$PROFILE"
        fi
      fi
    done
    
    echo "Please restart your shell or run 'source ~/.bash_profile' (or your equivalent profile) to apply the changes."
    ;;
    
  *)
    echo "Unsupported operating system: $OS"
    exit 1
    ;;
esac

echo "Verifying Rust installation..."
if ! command -v rustc &> /dev/null; then
  echo "Rust not found. Please install it first: https://rustup.rs/"
  exit 1
fi

echo "Rust version: $(rustc --version)"
echo "Cargo version: $(cargo --version)"

echo "OpenSSL setup completed successfully!"