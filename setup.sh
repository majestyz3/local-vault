#!/bin/bash
set -e

# Prepare directories
mkdir -p certs traefik vault/audit vault/snapshots vault/plugins

# Check dependencies
for cmd in docker docker-compose jq openssl; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "Error: $cmd is not installed" >&2
    exit 1
  fi
done

# Generate fresh self-signed certificates, replacing any existing files
rm -f certs/privkey.pem certs/certificate.pem certs/fullchain.pem certs/ca.pem
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout certs/privkey.pem \
  -out certs/certificate.pem \
  -subj "/CN=mac.example.com"
cp certs/certificate.pem certs/fullchain.pem
cp certs/certificate.pem certs/ca.pem

# Create traefik tls config
cat > traefik/tls.toml <<'CONFIG'
[tls.stores]
  [tls.stores.default.defaultCertificate]
    certFile = "/certs/fullchain.pem"
    keyFile  = "/certs/privkey.pem"
CONFIG

cat <<'MSG'
Setup complete. Copy your Vault Enterprise license file to vault.hclic
and run ./vup to start the environment.
MSG
