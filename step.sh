#!/bin/bash
set -e

KEY_PATH="$HOME/.ssh/protected_ixguard_key"
SSH_KEY_FILE_URL=${ssh_key_file}
SSH_KEY_PASSPHRASE=${ssh_key_passphrase}

PROTECTED_ARCHIVE="protected.xcarchive"
IXGUARD_GENERATED_FILES_DIRECTORY="ixguard-files"
CONFIG_VERSION=${config_version}

if [ -n "$SSH_KEY_FILE_URL" ] && [ -n "$SSH_KEY_PASSPHRASE" ]; then
    mkdir -p "$HOME/.ssh"

    curl -fSL "$SSH_KEY_FILE_URL" -o "$KEY_PATH"
    chmod 600 "$KEY_PATH"

    eval "$(ssh-agent -s)"

    expect <<EOF
set timeout -1
spawn ssh-add "$KEY_PATH"
expect "Enter passphrase for"
send "$SSH_KEY_PASSPHRASE\r"
expect eof
EOF

else
    echo "SSH key for iXGuard access is missing."
    exit 1
fi

# Process the unprotected xcarchive
guardsquare protect --ssh-agent --no-browser -o "$PROTECTED_ARCHIVE" --force-license-sync --config "$CONFIG_VERSION" --out-dir "$BITRISE_DEPLOY_DIR" "$BITRISE_XCARCHIVE_PATH"

# Make the protected archive available from outside this Step
envman add --key PROTECTED_ARCHIVE --value "$(realpath $BITRISE_DEPLOY_DIR/$PROTECTED_ARCHIVE)"

exit 0
