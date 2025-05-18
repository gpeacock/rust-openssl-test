use openssl::hash::{hash, MessageDigest};
use openssl::ssl::{SslConnector, SslMethod};
use std::error::Error;
use std::io::{Read, Write};
use std::net::TcpStream;

fn main() -> Result<(), Box<dyn Error>> {
    // Simple test 1: Compute a SHA-256 hash using OpenSSL
    let data = b"Hello, OpenSSL!";
    let hash_result = hash(MessageDigest::sha256(), data)?;
    
    println!("SHA-256 Hash test:");
    println!("Input: '{}'", String::from_utf8_lossy(data));
    println!("Hash: {}", hex_encode(&hash_result));
    
    // Simple test 2: Print OpenSSL version information
    println!("\nOpenSSL Version Information:");
    println!("Version: {}", openssl::version::version());
    println!("Version Number: {}", openssl::version::number());
    println!("OpenSSL Dir: {:?}", std::env::var("OPENSSL_DIR").ok());
    
    // Advanced test: Try to make a TLS connection if possible
    println!("\nAttempting TLS connection to httpbin.org...");
    match make_tls_request() {
        Ok(response) => {
            println!("TLS Connection successful!");
            println!("Response preview (first 200 chars):");
            println!("{}", if response.len() > 200 { 
                &response[..200] 
            } else { 
                &response 
            });
        },
        Err(e) => {
            println!("TLS Connection test failed: {}", e);
            println!("This might be due to network connectivity issues and doesn't necessarily mean OpenSSL is misconfigured.");
        }
    }
    
    println!("\nOpenSSL test completed!");
    Ok(())
}

// Helper function to encode binary data as hex string
fn hex_encode(data: &[u8]) -> String {
    data.iter()
        .map(|b| format!("{:02x}", b))
        .collect::<Vec<String>>()
        .join("")
}

// Function to make a TLS connection and retrieve response
fn make_tls_request() -> Result<String, Box<dyn Error>> {
    // Create a TLS connector
    let mut builder = SslConnector::builder(SslMethod::tls())?;
    builder.set_verify(openssl::ssl::SslVerifyMode::NONE); // For testing only
    let connector = builder.build();
    
    // Connect to httpbin.org
    let stream = TcpStream::connect("httpbin.org:443")?;
    let mut stream = connector.connect("httpbin.org", stream)?;
    
    // Send HTTP request
    let request = "GET /ip HTTP/1.1\r\nHost: httpbin.org\r\nConnection: close\r\n\r\n";
    stream.write_all(request.as_bytes())?;
    
    // Read response
    let mut response = String::new();
    stream.read_to_string(&mut response)?;
    
    Ok(response)
}


#[cfg(test)]
mod tests {
    use openssl::hash::{hash, MessageDigest};
    use openssl::rand::rand_bytes;
    use openssl::symm::{encrypt, decrypt, Cipher};
    
    #[test]
    fn test_sha256_hash() {
        let data = b"OpenSSL test data";
        let result = hash(MessageDigest::sha256(), data).unwrap();
        
        // Just verify we get a result of the expected length for SHA-256 (32 bytes)
        assert_eq!(result.len(), 32);
        
        println!("SHA-256 hash computed successfully");
    }
    
    #[test]
    fn test_aes_encryption_decryption() {
        // Generate random key and iv
        let mut key = [0; 32]; // AES-256 key
        let mut iv = [0; 16];  // AES block size
        
        rand_bytes(&mut key).unwrap();
        rand_bytes(&mut iv).unwrap();
        
        let cipher = Cipher::aes_256_cbc();
        let data = b"Secret message that needs encryption";
        
        // Encrypt
        let encrypted = encrypt(
            cipher,
            &key,
            Some(&iv),
            data
        ).unwrap();
        
        // Decrypt
        let decrypted = decrypt(
            cipher,
            &key,
            Some(&iv),
            &encrypted
        ).unwrap();
        
        // Verify decryption worked
        assert_eq!(data.to_vec(), decrypted);
        
        println!("AES encryption/decryption test passed");
    }
    
    #[test]
    fn test_openssl_version() {
        let version = openssl::version::version();
        println!("OpenSSL version: {}", version);
        
        // Just verify we can access version info
        assert!(!version.is_empty());
    }
}