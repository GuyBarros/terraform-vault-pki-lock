resource "vault_mount" "ca_root" {
  namespace             = vault_namespace.root_ca.path_fq
  path                  = "ca_root"
  type                  = "pki"
  max_lease_ttl_seconds = 315360000 # 10 years
}



resource "vault_pki_secret_backend_root_cert" "ca_root" {
  backend              = vault_mount.ca_root.path
  namespace            = vault_namespace.root_ca.path_fq
  type                 = "internal"
  ttl                  = "87600h"
  key_type             = "rsa"
  exclude_cn_from_sans = true
  ////////////////////////////////////////////////////////////////
  common_name = "root-ca"
  # ttl = "15768000s"
  format             = "pem"
  private_key_format = "der"
  # key_type = "rsa"
  key_bits = 2048
  # exclude_cn_from_sans = true
  //////////////////////////////////////////////////////////
}

resource "vault_mount" "int_ca" {
  namespace             = vault_namespace.int_ca.path_fq
  path                  = "int_ca"
  type                  = "pki"
  max_lease_ttl_seconds = 157680000 # 5 years
}



resource "vault_pki_secret_backend_intermediate_cert_request" "int_ca" {
  namespace   = vault_namespace.int_ca.path_fq
  backend     = vault_mount.int_ca.path
  type        = "internal"
  common_name = "root-ca"
  key_type    = "rsa"
  key_bits    = "2048"
}



resource "vault_pki_secret_backend_root_sign_intermediate" "int_ca" {
  namespace            = vault_namespace.root_ca.path_fq
  backend              = vault_mount.ca_root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.int_ca.csr
  common_name          = "root-ca"
  ttl                  = "43800h"
  exclude_cn_from_sans = true
  format               = "pem_bundle"
}



resource "vault_pki_secret_backend_intermediate_set_signed" "int_ca" {
  namespace   = vault_namespace.int_ca.path_fq
  backend     = vault_mount.int_ca.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.int_ca.certificate
}



resource "vault_pki_secret_backend_role" "leaf-ca" {
  namespace = vault_namespace.int_ca.path_fq
  backend   = vault_mount.int_ca.path
  name      = "leaf-ca"
  # allowed_domains = ["example.io"]
  allow_bare_domains = true #
  allow_subdomains   = true #
  allow_glob_domains = true #
  allow_any_name     = true # adjust allow_*, flags accordingly
  allow_ip_sans      = true #
  server_flag        = true #
  client_flag        = true #
  key_usage          = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "KeyUsageCertSign"]
  max_ttl            = "730h" # ~1 month
  ttl                = "730h"
}