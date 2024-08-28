#Create Requester Token
REQUESTER=$(vault token create -field=token -display-name=requester -entity-alias=requester -role=requester-role -namespace=pki_design)
echo $REQUESTER
#Create Approver Token
APPROVER=$(vault token create -field=token -display-name=approver -entity-alias=approver -role=approver-role -namespace=pki_design)
echo $APPROVER

#Test reading root_ca mount
VAULT_TOKEN=$REQUESTER vault list -namespace=pki_design root_ca/ca_root/issuers

#Start lock request
LOCK_REQUEST=$(VAULT_TOKEN=$REQUESTER vault namespace lock -format=json -namespace=pki_design root_ca) 
LOCK_WRAPPING_TOKEN=$(echo $LOCK_REQUEST | jq -r ."wrap_info"."token")
LOCK_WRAPPING_ACCESSOR=$(echo $LOCK_REQUEST | jq -r ."wrap_info"."accessor")

#Check status of lock request
VAULT_TOKEN=$APPROVER vault write -namespace=pki_design sys/control-group/request accessor=$LOCK_WRAPPING_ACCESSOR

#Approve lock request
VAULT_TOKEN=$APPROVER vault write -namespace=pki_design sys/control-group/authorize accessor=$LOCK_WRAPPING_ACCESSOR

#Get Unlock Key
LOCK_TOKEN_CHECK=$(VAULT_TOKEN=$REQUESTER vault unwrap -format=json -namespace=pki_design $LOCK_WRAPPING_TOKEN)

UNLOCK_KEY=$(echo $LOCK_TOKEN_CHECK | jq -r ."data"."unlock_key")

#Test reading root_ca mount - should fail due to namespace being locked
VAULT_TOKEN=$REQUESTER vault list -namespace=pki_design root_ca/ca_root/issuers


#Start Unlock Request - BUG Does not return Wrapping token info
UNLOCK_REQUEST=$(VAULT_TOKEN=$REQUESTER vault namespace unlock -format=json -namespace=pki_design -unlock-key=$UNLOCK_KEY root_ca)

#Start Unlock Request - Works
UNLOCK_REQUEST=$(curl -X PUT -H "X-Vault-Request: true" -H "X-Vault-Namespace: pki_design/" -H "X-Vault-Token: $REQUESTER" -d '{"unlock_key":"'$UNLOCK_KEY'"}' https://vault.guystack1.guy.aws.sbx.hashicorpdemo.com:8200/v1/sys/namespaces/api-lock/unlock/root_ca)
UNLOCK_WRAPPING_TOKEN=$(echo $UNLOCK_REQUEST | jq -r ."wrap_info"."token")
UNLOCK_WRAPPING_ACCESSOR=$(echo $UNLOCK_REQUEST | jq -r ."wrap_info"."accessor")

#Check Unlock Request
VAULT_TOKEN=$APPROVER vault write -namespace=pki_design sys/control-group/request accessor=$UNLOCK_WRAPPING_ACCESSOR

#Approve Unlock Request
VAULT_TOKEN=$APPROVER vault write -namespace=pki_design sys/control-group/authorize accessor=$UNLOCK_WRAPPING_ACCESSOR

#Check for error messages when unlocking
UNLOCK_TOKEN_CHECK=$(VAULT_TOKEN=$REQUESTER vault unwrap -namespace=pki_design $UNLOCK_WRAPPING_TOKEN)

#Test reading root_ca mount - should fail due to namespace being locked
VAULT_TOKEN=$REQUESTER vault list -namespace=pki_design root_ca/ca_root/issuers
