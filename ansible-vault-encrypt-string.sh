#!/bin/bash
function display_usage {
    echo "Usage: $0 --vault-pass-file <vault-password-file> --name <variable_name>"
    exit 1
}
if [ "$#" -ne 4 ]; then
    display_usage
fi
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --vault-pass-file)
      VAULT_PASSWORD_FILE="$2"
      shift 2
      ;;
    --name)
      VARIABLE_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      display_usage
      ;;
  esac
done
if [ -z "$VAULT_PASSWORD_FILE" ] || [ -z "$VARIABLE_NAME" ]; then
    echo "Both --vault-pass-file and --name must be provided."
    display_usage
fi
if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
    echo "Vault password file does not exist: $VAULT_PASSWORD_FILE"
    exit 1
fi
read -s -p "Enter the string to encrypt: " plaintext
echo
encrypted_string=$(echo -n "$plaintext" | ansible-vault encrypt_string --stdin-name "$VARIABLE_NAME" --vault-password-file "$VAULT_PASSWORD_FILE")
echo "$encrypted_string"
