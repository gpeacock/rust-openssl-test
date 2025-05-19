# Rust OpenSSL Test Project for Windows MSVC and others

This is a simple Rust project that tests the OpenSSL build process on Windows using the MSVC toolchain in a GitHub Actions workflow.
I've found it very frustrating getting openssl to build reliably on Windows in scripted environments like github actions and powershell, so this provides a powershell script that does the setup for both environments.

## Features

- Demonstrates OpenSSL functionality in Rust
- Tests SHA-256 hashing
- Tests AES encryption/decryption
- Attempts a TLS connection
- Includes GitHub Actions workflow for CI

## Setup on Windows

1. Install Git and Clone this repository
2. Ensure you have Rust and Visual Studio installed on your development machine
3. Enable Powershell to run scripts (admin terminal with ``` Set-ExecutionPolicy RemoteSigned```)
3. Run the setup script in powershell:

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