# Local Vault Development Environment

This repository contains a minimal setup for running HashiCorp Vault locally
with Traefik acting as a reverse proxy. The Docker Compose stack provisions a
Vault Enterprise container and a Traefik instance that serves Vault over HTTP.
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
4. **OpenSSL** &ndash; required for `setup.sh`, which generates the TLS certificates.
5. **Vault license** &ndash; copy your `vault.hclic` file to the repository root.

The Compose file also mounts a `traefik` directory that contains a
`tls.toml` file declaring the TLS certificates for Traefik. `setup.sh` writes
this file automatically. A minimal example is shown below:

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

2. Run the setup script to generate fresh TLS certificates and create the
   required directories. Any existing files in `certs/` will be replaced.
   ```bash
   ./setup.sh
   ```

3. Copy your Vault Enterprise license to `vault.hclic` and start the containers:
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

## Troubleshooting

### "permission denied" when creating `/vault/data/vault.db`

If Vault fails to start with an error similar to:

```
Error initializing storage of type raft: failed to create fsm: failed to open bolt file: open /vault/data/vault.db: permission denied
```

The data volumes are likely owned by `root` on the host. Vault runs as UID `100` inside the container and requires write access to these volumes.

Fix the ownership as follows:

1. Stop the stack and remove the containers (volumes are kept):

   ```bash
   ./vdown
   ```

2. For each data volume, find its mountpoint and change ownership to `100:100`:

   ```bash
   docker volume inspect local-vault_c1-node1-data | jq -r '.[0].Mountpoint'
   sudo chown -R 100:100 <mountpoint>
   ```

   Replace `local-vault_c1-node1-data` with the other volume names (`c1-node2-data`, `c1-node3-data`, etc.) and repeat the `chown` command for each.

3. Start the stack again:

   ```bash
   ./vup
   ```

4. If you previously removed the volumes with `docker compose down -v`, reinitialize Vault and unseal it as described in the **Getting started** section.

