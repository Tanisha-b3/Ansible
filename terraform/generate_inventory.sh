#!/usr/bin/env bash
set -e
# Requires terraform output -json public_ips
IPS_JSON="$(terraform output -json public_ips 2>/dev/null || true)"
if [ -z "$IPS_JSON" ]; then
  echo "Run this script from the terraform directory (or ensure terraform state is present)."
  exit 1
fi
IPS=($(jq -r '.[]' <<<"$IPS_JSON"))
if [ ${#IPS[@]} -ne 4 ]; then
  echo "Expected 4 IPs, found ${#IPS[@]}"
  exit 1
fi

cat > ~/ansible-onboarding/ansible/inventory.ini <<EOF
[web]
${IPS[0]}

[app]


[db]

[all:vars]
ansible_user=azureuser
ansible_ssh_private_key_file=~/ansible-onboarding/terraform/ssh/epicbook
EOF

echo "inventory.ini created"
