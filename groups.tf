data "vault_auth_backend" "token" {
  path      = "token"
  namespace = vault_namespace.pki_design.path_fq
}
resource "vault_identity_group" "requesters" {
  namespace = vault_namespace.pki_design.path_fq
  name      = "requesters"
  type      = "internal"
  policies  = ["requesters"]

  metadata = {
    version = "2"
  }
  member_entity_ids = [vault_identity_entity.requester.id]
}

resource "vault_identity_entity" "requester" {
  namespace = vault_namespace.pki_design.path_fq
  name      = "requester"
}

resource "vault_identity_entity_alias" "requester" {
  namespace      = vault_namespace.pki_design.path_fq
  name           = "requester"
  mount_accessor = data.vault_auth_backend.token.accessor
  canonical_id   = vault_identity_entity.requester.id
}

resource "vault_token_auth_backend_role" "requester-role" {
  role_name              = "requester-role"
  namespace              = vault_namespace.pki_design.path_fq
  allowed_policies       = ["default"]
  orphan                 = false
  token_period           = "86400"
  renewable              = true
  token_explicit_max_ttl = "115200"
  path_suffix            = "path-suffix"
  allowed_entity_aliases = ["*"]
}


resource "vault_identity_group" "approvers" {
  namespace = vault_namespace.pki_design.path_fq
  name      = "approvers"
  type      = "internal"
  policies  = ["approvers"]

  metadata = {
    version = "2"
  }
  member_entity_ids = [vault_identity_entity.approver.id]
}

resource "vault_identity_entity" "approver" {
  namespace = vault_namespace.pki_design.path_fq
  name      = "approver"
}

resource "vault_identity_entity_alias" "approver" {
  namespace      = vault_namespace.pki_design.path_fq
  name           = "approver"
  mount_accessor = data.vault_auth_backend.token.accessor
  canonical_id   = vault_identity_entity.approver.id
}

resource "vault_token_auth_backend_role" "approver-role" {
  role_name              = "approver-role"
  namespace              = vault_namespace.pki_design.path_fq
  allowed_policies       = ["default"]
  orphan                 = false
  token_period           = "86400"
  renewable              = true
  token_explicit_max_ttl = "115200"
  path_suffix            = "path-suffix"
  allowed_entity_aliases = ["*"]
}
