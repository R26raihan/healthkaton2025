#!/usr/bin/env python3
"""
Script untuk generate secret key yang aman untuk JWT
Jalankan: python generate_secret_key.py
"""
import secrets
import string

def generate_secret_key(length=64):
    """
    Generate random secret key menggunakan secrets module (cryptographically secure)
    """
    # Menggunakan kombinasi huruf, angka, dan karakter khusus
    alphabet = string.ascii_letters + string.digits + string.punctuation
    secret_key = ''.join(secrets.choice(alphabet) for _ in range(length))
    return secret_key

if __name__ == "__main__":
    print("=" * 60)
    print("SECRET KEY GENERATOR untuk JWT")
    print("=" * 60)
    print()
    
    # Generate secret key
    secret_key = generate_secret_key(64)
    
    print("Secret Key yang dihasilkan:")
    print("-" * 60)
    print(secret_key)
    print("-" * 60)
    print()
    print("Copy secret key di atas dan paste ke file env.py pada SECRET_KEY")
    print("=" * 60)

