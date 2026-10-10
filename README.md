# NeuralNote releases

Public release downloads for **NeuralNote**, local voice-to-text for developers on Apple Silicon Macs.
Hold a hotkey, speak, and the text lands wherever your cursor is: Claude Code, Cursor, the terminal, Slack.

This repository only hosts release files and the installer. The source code is private.

## Install

NeuralNote is in prerelease testing. Install the current test build (v0.1.0):

```bash
curl -fsSL https://raw.githubusercontent.com/aniiirudhh/neuralnote-releases/main/install.sh | NEURALNOTE_VERSION=0.1.0 bash
```

You can [read the script](install.sh) first. It downloads `NeuralNote.zip` for that version from this repository's releases, checks it against `NeuralNote.zip.sha256`, verifies the code signature, and copies `NeuralNote.app` into `/Applications`. That is all it does.

Once a stable release exists, the same command without `NEURALNOTE_VERSION=...` installs the latest stable version.

Requires an Apple Silicon Mac (M1 or later) on macOS 13.5 or newer. On first launch the app downloads the Whisper speech model once (about 1.6 GB).

## Why it isn't notarized

NeuralNote is signed with a stable self-signed identity ("NeuralNote Self-Signed") and is not notarized by Apple yet.
A browser-downloaded app that isn't notarized is blocked by Gatekeeper; files fetched with `curl` are not quarantined, which is why installs go through the script.
Notarization comes once sales cover Apple's Developer Program fee.

## Release files

| File | Purpose |
|---|---|
| `NeuralNote.zip` | The app, used by the installer |
| `NeuralNote.zip.sha256` | SHA-256 checksum of the zip |

## Pricing

30-day free trial with every feature, then $29 once. The website and checkout are not live yet.
