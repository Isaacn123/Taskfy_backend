#!/bin/bash

# Generate self-signed SSL certificate for development
# For production, use a proper SSL certificate from a trusted CA

mkdir -p ssl

# Generate private key
openssl genrsa -out ssl/nginx-selfsigned.key 2048

# Generate certificate signing request
openssl req -new -key ssl/nginx-selfsigned.key -out ssl/nginx-selfsigned.csr -subj "/C=US/ST=State/L=City/O=Organization/CN=45.56.120.65"

# Generate self-signed certificate
openssl x509 -req -days 365 -in ssl/nginx-selfsigned.csr -signkey ssl/nginx-selfsigned.key -out ssl/nginx-selfsigned.crt

echo "SSL certificates generated in ssl/ directory"
echo "For production, replace these with certificates from a trusted CA"
