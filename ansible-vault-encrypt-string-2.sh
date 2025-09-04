#!/bin/bash
function prompt_with_completion {
    local prompt_message="$1"
    local default_value="$2"
    local input

    read -e -p "$prompt_message" -i "$default_value" input
    echo "$input"
}
plaintext=$(prompt_with_completion "Enter the string to encrypt: ")
if [ -z "$plaintext" ]; then
    echo "No string entered. Exiting."
    exit 1
fi
VAULT_PASSWORD_FILE=$(prompt_with_completion "Enter the path to the vault password file: " "$HOME/")
if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
    echo "Vault password file does not exist: $VAULT_PASSWORD_FILE"
    exit 1
fi
VARIABLE_NAME=$(prompt_with_completion "Enter the variable name: ")
encrypted_string=$(echo -n "$plaintext" | ansible-vault encrypt_string --stdin-name "$VARIABLE_NAME" --vault-password-file "$VAULT_PASSWORD_FILE" 2>&1)
if [ $? -eq 0 ]; then

    echo "$encrypted_string" | xsel --clipboard
else

    zenity --error --title="Encryption Failed" --text="An error occurred during encryption:\n\n$encrypted_string"
    exit 1
fi
