# raft storage
storage "raft" {
  path    = "/vault/data"
  node_id = "node_1"

  retry_join {
    leader_api_addr     = "https://vault.example.com:8200"
    leader_ca_cert_file = "/certs/ca.pem"
    tls_cert_file       = "/certs/certificate.pem"
    tls_key_file        = "/certs/privkey.pem"
  }
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/certs/fullchain.pem"
  tls_key_file  = "/certs/privkey.pem"
  tls_disable = false
}


cluster_name = "vault"

