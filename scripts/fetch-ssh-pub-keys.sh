#!/bin/bash

# GitHub username
GITHUB_USER="$1"

# Fetch the keys
GITHUB_KEYS=$(curl -s "https://github.com/${GITHUB_USER}.keys")

# Check if keys were fetched successfully
if [ -z "$GITHUB_KEYS" ]; then
  echo "Failed to fetch keys or no keys found for user ${GITHUB_USER}"
  exit 1
fi

# Process the keys into a YAML-compatible format
FORMATTED_KEYS=""
while IFS= read -r key; do
  FORMATTED_KEYS="${FORMATTED_KEYS}        - ${key}\n"
done <<< "$GITHUB_KEYS"

# Remove the trailing newline
FORMATTED_KEYS=${FORMATTED_KEYS%\\n}

FILES=(
    "matchbox/examples/ignition/flatcar-install-k8s.yaml"
    "matchbox/examples/ignition/flatcar-enable-k8s.yaml"
    "matchbox/examples/ignition/flatcar-install.yaml"
    "matchbox/examples/ignition/flatcar.yaml"
)

update_ssh_keys() {
    local file="$1"
    local temp_file="${file}.temp"
    
    # Check if file exists
    if [ ! -f "$file" ]; then
        echo "Error: File $file does not exist"
        return 1
    fi
    
    echo "Updating SSH keys in $file..."
    
    # Clear existing SSH keys
    yq eval '.passwd.users[0].ssh_authorized_keys = []' "$file" > "$temp_file"
    
    # Add each key from GITHUB_KEYS
    echo "$GITHUB_KEYS" | while IFS= read -r key; do
        if [ -n "$key" ]; then  # Only add non-empty keys
            yq eval --inplace '.passwd.users[0].ssh_authorized_keys += ["'"$key"'"]' "$temp_file"
        fi
    done
    
    # Replace the original file
    mv "$temp_file" "$file"
    echo "Updated $file successfully"
}

# Update SSH keys in each file
for file in "${FILES[@]}"; do
    update_ssh_keys "$file"
done


echo "SSH keys updated successfully!"
