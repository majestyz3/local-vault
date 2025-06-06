# Local Vault Development Environment

This repository contains a minimal setup for running HashiCorp Vault locally
with Traefik acting as a reverse proxy. The Docker Compose stack provisions a
Vault Enterprise container and a Traefik instance that serves Vault over HTTPS.
Helper scripts are included to streamline starting and stopping the environment
and loading common environment variables.

## Repository layout

- `docker-compose.yaml` &ndash; Compose file defining the `vault` and `traefik`
  containers.
- `vault/conf/vault.hcl` &ndash; Vault configuration using raft storage and TLS
  certificates from the `certs/` directory.
- `vup` &ndash; starts the stack via Docker Compose and unseals Vault using the
  key from `vault-init.json`.
- `vdown` &ndash; stops the stack.
- `venv` &ndash; exports convenience environment variables such as
  `VAULT_ADDR` and the root token after Vault has been initialized.
- `mybot-policy.hcl` &ndash; example policy for a sample Vault path.

## Prerequisites

1. **Docker and Docker Compose** &ndash; required to run the containers.
2. **Vault CLI** &ndash; used by the helper scripts for initialization and
   unsealing.
3. **`jq`** &ndash; used by the `venv` script to parse `vault-init.json`.
4. **TLS certificates** – create a `certs/` directory in the repository root and
   place the following files inside:
   - `fullchain.pem` – certificate chain for the host names.
   - `privkey.pem` – private key for the certificate.
   - `certificate.pem` – certificate without the chain.
   - `ca.pem` – root certificate of your CA.
5. **Vault license** &ndash; copy your `vault.hclic` file to the repository root.

The Compose file also mounts a `traefik` directory that should contain a
`tls.toml` file declaring the TLS certificates for Traefik. A minimal example is
shown below:

```toml
[[tls.certificates]]
  certFile = "/certs/fullchain.pem"
  keyFile  = "/certs/privkey.pem"
```

## Getting started

1. Clone this repository anywhere on your filesystem. The helper
   scripts automatically detect their location, so no special path is
   required.
   ```bash
   git clone <repo-url> <any-path>
   cd <any-path>
   ```

2. Ensure the `certs/` and `traefik/` directories contain the required files
   described above. Place your Vault license at `vault.hclic`.

3. Start the containers and unseal Vault:
   ```bash
   ./vup
   ```
   On the very first run, initialize Vault and capture the output:
   ```bash
   vault operator init -format=json > vault-init.json
   source venv
   vault operator unseal "$VAULT_SEAL_KEY"
   ```

4. After initialization you can load the environment variables whenever you
   interact with Vault:
   ```bash
   source venv
   ```

5. The Vault UI will be available at `http://127.0.0.1:8200` (or
   `http://vault.mac.example.com` if you mapped the hostname) and the
   Traefik dashboard at `http://traefik.mac.example.com`.

6. When finished, stop the containers with:
   ```bash
   ./vdown
   ```

## Notes

The `vault/data` directory is persisted locally so that data survives container
restarts. The example policy file `mybot-policy.hcl` can be loaded into Vault
with:

```bash
vault policy write mybot mybot-policy.hcl
```

Feel free to adjust domains and paths in `docker-compose.yaml` and
`vault/conf/vault.hcl` to match your local environment.
