#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <vault_string> <vault_password_file> <output_file>"
    exit 1
fi
VAULT_STRING=$1
VAULT_PASSWORD_FILE=$2
OUTPUT_FILE=$3
TEMP_ENCRYPTED_FILE=$(mktemp)
echo "$VAULT_STRING" > "$TEMP_ENCRYPTED_FILE"
ansible-vault decrypt "$TEMP_ENCRYPTED_FILE" --vault-password-file "$VAULT_PASSWORD_FILE"
mv "$TEMP_ENCRYPTED_FILE" "$OUTPUT_FILE"
[ -f "$TEMP_ENCRYPTED_FILE" ] && rm "$TEMP_ENCRYPTED_FILE"
echo "Decryption completed. Decrypted content is saved in $OUTPUT_FILE"
