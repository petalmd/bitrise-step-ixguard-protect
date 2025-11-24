#!/bin/bash
set -e

KEY_PATH="$HOME/.ssh/id_guardsquare"

GUARDSQUARE_SSH_KEY=${guardsquare_ssh_key}

GUARDSQUARE_CONFIG_VERSION=${guardsquare_config_version:-"production@latest"}
PROTECTED_APP_NAME=${protected_app_name}

# Auto-detect app path from Bitrise environment variables
if [[ -n "${app_path}" ]]; then
    APP_PATH="${app_path}"
elif [[ -n "${BITRISE_XCARCHIVE_PATH}" ]]; then
    APP_PATH="${BITRISE_XCARCHIVE_PATH}"
    PROTECTED_APP_NAME=${PROTECTED_APP_NAME:-"protected.xcarchive"}
elif [[ -n "${BITRISE_APK_PATH}" ]]; then
    APP_PATH="${BITRISE_APK_PATH}"
    PROTECTED_APP_NAME=${PROTECTED_APP_NAME:-"protected.apk"}
elif [[ -n "${BITRISE_AAB_PATH}" ]]; then
    APP_PATH="${BITRISE_AAB_PATH}"
    PROTECTED_APP_NAME=${PROTECTED_APP_NAME:-"protected.aab"}
else
    echo "Error: No app path found. Set app_path input or ensure BITRISE_XCARCHIVE_PATH, BITRISE_APK_PATH, or BITRISE_AAB_PATH is available."
    exit 1
fi

echo "Using app path: $APP_PATH"
echo "Using protected app name: $PROTECTED_APP_NAME"
echo "Using guardsquare config version: $GUARDSQUARE_CONFIG_VERSION"

mkdir -p "$HOME/.ssh"

echo "$GUARDSQUARE_SSH_KEY" > "$KEY_PATH"
chmod 600 "$KEY_PATH"

eval "$(ssh-agent -s)"

ssh-add "$KEY_PATH"


# Process the app
if ! command -v guardsquare >/dev/null 2>&1; then
    echo "Guardsquare CLI not found, installing..."
    curl -sS https://platform.guardsquare.com/cli/install.sh | sh -s -- --yes
fi

echo "Protecting app..."
guardsquare protect --ssh-agent --no-browser --force-license-sync --jvmargs "-Ddisable.zip64.support" --config "$GUARDSQUARE_CONFIG_VERSION" --out-dir "$BITRISE_DEPLOY_DIR" -o "$PROTECTED_APP_NAME" "$APP_PATH"

echo "Scanning app..."
if ! guardsquare scan "$BITRISE_DEPLOY_DIR/$PROTECTED_APP_NAME" --ssh-agent --mapping-file "$BITRISE_DEPLOY_DIR/mapping.txt"; then
    echo "Warning: Guardsquare scan failed"
fi

envman add --key PROTECTED_APP_PATH --value "$(realpath $BITRISE_DEPLOY_DIR/$PROTECTED_APP_NAME)"
echo "Env PROTECTED_APP_PATH is available with value: $(realpath $BITRISE_DEPLOY_DIR/$PROTECTED_APP_NAME)"

exit 0
