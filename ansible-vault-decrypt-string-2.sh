#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <vault_string> <output_file>"
    exit 1
fi
VAULT_STRING=$1
OUTPUT_FILE=$2
TEMP_ENCRYPTED_FILE=$(mktemp)
echo "$VAULT_STRING" > "$TEMP_ENCRYPTED_FILE"
echo "Enter the path to the vault password file:"
read -e VAULT_PASSWORD_FILE
if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
    echo "Vault password file does not exist."
    exit 1
fi
ansible-vault decrypt "$TEMP_ENCRYPTED_FILE" --vault-password-file "$VAULT_PASSWORD_FILE"
mv "$TEMP_ENCRYPTED_FILE" "$OUTPUT_FILE"
[ -f "$TEMP_ENCRYPTED_FILE" ] && rm "$TEMP_ENCRYPTED_FILE"
echo "Decryption completed. Decrypted content is saved in $OUTPUT_FILE"
