
resource "vault_namespace" "pki_design" {
  path = "pki_design"
}

resource "vault_namespace" "root_ca" {
  namespace = vault_namespace.pki_design.path
  path      = "root_ca"
}

resource "vault_namespace" "int_ca" {
  namespace = vault_namespace.pki_design.path
  path      = "int_ca"
}