#!/bin/bash
# generate_inventory.sh
# Dynamically generates Ansible inventory.ini from Terraform outputs

set -e

echo "🔧 Generating Ansible inventory..."

# Fetch Terraform outputs safely
PUBLIC_IP=$(terraform output -raw vm_public_ip)
MYSQL_HOST=$(terraform output -raw mysql_fqdn)
MYSQL_USER=$(terraform output -raw mysql_username)
MYSQL_PASS=$(terraform output -raw mysql_password)
MYSQL_CONNECTION=$(terraform output -raw mysql_connection_string)

USER="epicbookadmin"
KEY_PATH="$HOME/ansible-onboarding/.ssh/id_rsa"
ANSIBLE_DIR="$HOME/ansible-onboarding/ansible"

# Ensure target directory exists
mkdir -p "$ANSIBLE_DIR"

# Generate inventory.ini file
cat > "$ANSIBLE_DIR/inventory.ini" <<EOF
[web]
$PUBLIC_IP ansible_user=$USER ansible_ssh_private_key_file=$KEY_PATH ansible_python_interpreter=/usr/bin/python3

[db]
$MYSQL_HOST

[all:vars]
mysql_host=$MYSQL_HOST
mysql_username=$MYSQL_USER
mysql_password=$MYSQL_PASS
mysql_connection_string=$MYSQL_CONNECTION
EOF

echo "✅ inventory.ini created successfully!"
echo
