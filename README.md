# Guardsquare Protect

Protect your iOS and Android app archives with Guardsquare.

<details>
<summary>Description</summary>

Protect your app archive before export to take advantage of the advanced security features offered by Guardsquare.

### Configuring the Step

Before you start:

- Make sure you have a valid Guardsquare configuration
- Add your Guardsquare SSH key to the environment secrets

The step automatically:

- Installs Guardsquare CLI if not already present
- Sets up SSH authentication using ssh-agent
- Detects app paths from Bitrise environment variables

To configure the Step:

1. _SSH Key_: Private key registered in env secrets for Guardsquare authentication (required)
2. _Config Version_: Version of the Guardsquare configuration to use (optional, defaults to `production@latest`)
3. _Protected App Name_: Name for the protected output file (optional, auto-detected based on app type)
4. _App Path_: Path to the app to protect (optional, auto-detected from Bitrise environment variables)

### Auto-detection Features

The step automatically detects:

- **App Path**: Uses `$BITRISE_XCARCHIVE_PATH` (iOS), `$BITRISE_APK_PATH` (Android APK), or `$BITRISE_AAB_PATH` (Android AAB)
- **Protected App Name**: Defaults to `protected.xcarchive`, `protected.apk`, or `protected.aab` based on the detected app type

### How It Works

1. **SSH Setup**: Creates SSH key at `~/.ssh/id_guardsquare` with secure permissions (600) and configures ssh-agent
2. **CLI Installation**: Checks for Guardsquare CLI and auto-installs from `https://platform.guardsquare.com/cli/install.sh` if missing
3. **App Detection**: Prioritizes manual `app_path` input, then checks Bitrise environment variables in order
4. **Protection**: Runs `guardsquare protect` with flags:
   - `--ssh-agent`: Uses ssh-agent for authentication
   - `--no-browser`: Runs in non-interactive mode
   - `--force-license-sync`: Ensures license validation
   - `--jvmargs "-Ddisable.zip64.support"`: Disables ZIP64 support for compatibility
   - `--out-dir $BITRISE_DEPLOY_DIR`: Outputs to Bitrise deploy directory
5. **Scanning**: Runs `guardsquare scan` on the protected app with mapping file
   - Non-blocking: Scan failures only show a warning and don't fail the pipeline
   - Useful for security analysis and vulnerability detection
6. **Output**: Exports `PROTECTED_APP_PATH` environment variable with full path to protected app

</details>

## 🧩 Get started

Add this step directly to your workflow in the [Bitrise Workflow Editor](https://devcenter.bitrise.io/steps-and-workflows/steps-and-workflows-index/).

You can also run this step directly with [Bitrise CLI](https://github.com/bitrise-io/bitrise).

### Examples

#### iOS Workflow

```yaml
workflows:
  ios-protect:
    steps:
      - certificate-and-profile-installer@1: {}
      - xcode-archive@5:
          inputs:
            - configuration: Release
      - git::https://github.com/npinney/bitrise-step-ixguard-protect.git@main:
          inputs:
            - guardsquare_ssh_key: $GUARDSQUARE_SSH_KEY
            - guardsquare_config_version: "production@latest"
            # app_path and protected_app_name auto-detected
```

#### Android APK Workflow

```yaml
workflows:
  android-apk-protect:
    steps:
      - android-build@1:
          inputs:
            - variant: release
      - git::https://github.com/npinney/bitrise-step-ixguard-protect.git@main:
          inputs:
            - guardsquare_ssh_key: $GUARDSQUARE_SSH_KEY
            # Uses $BITRISE_APK_PATH automatically
```

#### Android AAB Workflow

```yaml
workflows:
  android-aab-protect:
    steps:
      - android-build@1:
          inputs:
            - variant: release
            - build_type: aab
      - git::https://github.com/npinney/bitrise-step-ixguard-protect.git@main:
          inputs:
            - guardsquare_ssh_key: $GUARDSQUARE_SSH_KEY
            # Uses $BITRISE_AAB_PATH automatically
```

## ⚙️ Configuration

<details>
<summary>Inputs</summary>

| Key                          | Description                                                                                                                           | Flags    | Default                |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------- |
| `guardsquare_ssh_key`        | Private key for Guardsquare authentication. Should be registered in environment secrets.                                              | required | `$GUARDSQUARE_SSH_KEY` |
| `guardsquare_config_version` | Version of the Guardsquare configuration to use.                                                                                      | optional | `production@latest`    |
| `protected_app_name`         | Name for the protected app output file. Auto-detected based on app type if not provided.                                              | optional | Auto-detected          |
| `app_path`                   | Path to the app to protect. Auto-detects from `$BITRISE_XCARCHIVE_PATH`, `$BITRISE_APK_PATH`, or `$BITRISE_AAB_PATH` if not provided. | optional | Auto-detected          |

</details>

<details>
<summary>Outputs</summary>

| Environment Variable | Description                                                                                                                    |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `PROTECTED_APP_PATH` | The full path to the protected app file in `$BITRISE_DEPLOY_DIR`. Use this to reference the protected app in subsequent steps. |

</details>

Learn more about developing steps:

- [Create your own step](https://devcenter.bitrise.io/contributors/create-your-own-step/)
- [Testing your Step](https://devcenter.bitrise.io/contributors/testing-and-versioning-your-steps/)
