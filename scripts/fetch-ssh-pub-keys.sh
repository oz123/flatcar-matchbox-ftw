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

# Use yq to update the YAML file
yq eval '.passwd.users[0].ssh_authorized_keys = []' matchbox/examples/ignition/flatcar-install.yaml > temp.yaml

# Now add each key
echo "$GITHUB_KEYS" | while IFS= read -r key; do
  yq eval --inplace '.passwd.users[0].ssh_authorized_keys += ["'"$key"'"]' temp.yaml
done

# Replace the original file
mv temp.yaml matchbox/examples/ignition/flatcar-install.yaml

echo "SSH keys updated successfully!"
