# Local Vault Environment

This repository contains a small Docker Compose setup for running Vault Enterprise
behind Traefik. It is intended for local testing.

## Prerequisites

* Docker and `docker-compose`
* `jq`
* `openssl`
* A Vault Enterprise license file (copy it to `vault.hclic` after running the
  setup script)

## Setup

1. Run `./setup.sh` to create required folders and generate self‑signed TLS
   certificates.
2. Copy your Vault license to `vault.hclic` in the repository root.
3. Add the following line to your `/etc/hosts` file so the example domains
   resolve locally:

   ```
   127.0.0.1  traefik.mac.example.com vault.mac.example.com mac.example.com
   ```
4. Start the environment with `./vup`.
5. On first run, initialize Vault and save the output:

   ```
   docker exec -it vault vault operator init -format=json > vault-init.json
   ```

   Source the generated environment variables with:

   ```
   . ./venv
   ```

   Then unseal with `./vup` or `vault operator unseal`.

## Stopping

Use `./vdown` to stop the containers.

## Notes

The generated certificates are self signed and intended for local use only.
