#!/bin/sh

# Install curl if needed
apk add --no-cache curl

# Wait for Vault to be initialized
until curl -s http://vault:8200/v1/sys/health | grep -q '"initialized":true'; do
  echo "Waiting for Vault to be initialized..."
  sleep 5
done
echo "Vault is initialized!"

# Wait for Vault to be unsealed
until curl -s http://vault:8200/v1/sys/health | grep -q '"sealed":false'; do
  echo "Waiting for Vault to be unsealed..."
  sleep 5
done
echo "Vault is unsealed!"

# Authenticate with Vault using the root token (update token if needed)
export VAULT_TOKEN="replace-by-your-vault-token"
export VAULT_ADDR='http://vault:8200'

# Define the policy with full permissions
cat <<EOF | curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data @- http://vault:8200/v1/sys/policies/acl/full-access
{
  "policy": "path \"*/*\" {\n  capabilities = [\"create\", \"read\", \"update\", \"delete\", \"list\"]\n}\n"
}
EOF

# Enable the userpass authentication method
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"type":"userpass"}' http://vault:8200/v1/sys/auth/userpass

# Create a user with full access policy
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"password":"mypassword","policies":"full-access"}' http://vault:8200/v1/auth/userpass/users/myuser

echo "Starting config sync vault secret to json file."

# Enable AppRole auth method
vault auth enable approle

vault secrets enable -path=kv kv-v2

# Create a policy that allows reading the secret
vault policy write my-policy - <<EOF
path "kv/data/*" {
  capabilities = ["read", "list"]
}
EOF

# Create an AppRole with the policy
vault write auth/approle/role/my-role token_policies="my-policy"

# Get the Role ID and Secret ID
vault read -field=role_id auth/approle/role/my-role/role-id > /vault/creds/role_id
vault write -field=secret_id -f auth/approle/role/my-role/secret-id > /vault/creds/secret_id

vault token create -policy="my-policy"

echo "Vault role and credentials have been set up."

