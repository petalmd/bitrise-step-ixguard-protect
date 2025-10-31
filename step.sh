#!/bin/bash
set -e

LICENSE_FILE="ixguard-license.txt"
PROTECTED_ARCHIVE="protected.xcarchive"
IXGUARD_GENERATED_FILES_DIRECTORY="ixguard-files"
CONFIG_VERSION="production@latest"

# Download licenses
if [ -n "${BITRISEIO_IXGUARD_LICENSE_URL}" ]; then
    curl ${BITRISEIO_IXGUARD_LICENSE_URL} -o "$LICENSE_FILE"
else
    echo "Need to import the ixguard license file into Bitrise."
    exit 1
fi

# Set config version
if [ -n "${BITRISEIO_IXGUARD_CONFIG_VERSION}" ]; then
    CONFIG_VERSION="${BITRISEIO_IXGUARD_CONFIG_VERSION}"
fi

# Process the unprotected xcarchive
guardsquare protect --ssh-agent --no-browser -o "$IXGUARD_GENERATED_FILES_DIRECTORY/$PROTECTED_ARCHIVE" --force-license-sync --config "$CONFIG_VERSION" --out-dir "$IXGUARD_GENERATED_FILES_DIRECTORY" "$BITRISE_XCARCHIVE_PATH"

# Make the protected archive available from outside this Step
envman add --key PROTECTED_ARCHIVE --value "$(realpath $PROTECTED_ARCHIVE)"

zip -r "$IXGUARD_GENERATED_FILES_DIRECTORY.zip" "$IXGUARD_GENERATED_FILES_DIRECTORY"
mv "$IXGUARD_GENERATED_FILES_DIRECTORY.zip" "$BITRISE_DEPLOY_DIR/"

exit 0
