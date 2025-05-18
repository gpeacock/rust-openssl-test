# Rust OpenSSL Test Project for Windows MSVC and others

This is a simple Rust project that tests the OpenSSL build process on Windows using the MSVC toolchain in a GitHub Actions workflow.

## Features

- Demonstrates OpenSSL functionality in Rust
- Tests SHA-256 hashing
- Tests AES encryption/decryption
- Attempts a TLS connection
- Includes GitHub Actions workflow for CI

## Setup

1. Clone this repository
2. Ensure you have Rust and Visual Studio installed on your development machine
3. Run the setup script to build OpenSSL:

```powershell
.\setup-rust-openssl.ps1
```

4. Build and run the project:

```bash
cargo build
cargo run
```

## Testing

Run the included tests:

```bash
cargo test
```

## How it works

This project uses the `openssl` crate to interact with the OpenSSL library. The project includes:

- `Cargo.toml` - Project configuration with OpenSSL dependency
- `src/main.rs` - Example program that demonstrates OpenSSL functionality
- `setup-rust-openssl.ps1` - PowerShell script to build OpenSSL with MSVC
- `.github/workflows/rust-openssl-test.yml` - GitHub Actions workflow

## GitHub Actions CI

The included GitHub Actions workflow:

1. Sets up a Windows environment
2. Installs the MSVC Rust toolchain
3. Builds OpenSSL using Visual Studio tools
4. Builds and tests the Rust project

The workflow ensures that your Rust code compiles and runs correctly with OpenSSL on Windows using the MSVC toolchain.