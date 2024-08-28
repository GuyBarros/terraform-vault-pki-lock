resource "vault_policy" "requesters" {
  name      = "requesters"
  namespace = vault_namespace.pki_design.path_fq
  policy    = <<EOT
path "/sys/namespaces/api-lock/lock/root_ca" {
    capabilities = ["create","update"]
    control_group = {
        factor "lock_manager" {
            identity {
                group_names = ["approvers"]
                approvals = 1
            }
        }
    }
}

path "/sys/namespaces/api-lock/unlock/root_ca" {
    capabilities = ["create","update"]
    control_group = {
        factor "lock_manager" {
            identity {
                group_names = ["approvers"]
                approvals = 1
            }
        }
    }
}


path "/pki_design/*" {
    capabilities = ["read","list","create","update"]
}
path "/pki_design/root_ca/*" {
    capabilities = ["read","list","create","update"]
}

path "/pki_design/int_ca/*" {
    capabilities = ["read","list","create","update"]
}
EOT
}



resource "vault_policy" "approvers" {
  name      = "approvers"
  namespace = vault_namespace.pki_design.path_fq
  policy    = <<EOT


path "/pki_design/*" {
    capabilities = ["read","list","create","update"]
}

path "/pki_design/root_ca/*" {
    capabilities = ["read","list","create","update"]
}

path "/pki_design/int_ca/*" {
    capabilities = ["read","list","create","update"]
}

# To approve the request
path "sys/control-group/authorize" {
    capabilities = ["create", "update"]
}

# To check control group request status
path "sys/control-group/request" {
    capabilities = ["create", "update"]
}


EOT
}