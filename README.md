# NeuralNote releases

Public release downloads for **NeuralNote**, local voice-to-text for developers on Apple Silicon Macs.
Hold a hotkey, speak, and the text lands wherever your cursor is: Claude Code, Cursor, the terminal, Slack.

This repository only hosts release files and the installer. The source code is private.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/aniiirudhh/neuralnote-releases/main/install.sh | bash
```

You can [read the script](install.sh) first. It downloads `NeuralNote.zip` from the latest release in this repository, checks it against `NeuralNote.zip.sha256`, confirms the app is signed with NeuralNote's own certificate, and copies `NeuralNote.app` into `/Applications`. That is all it does.

Run the same command again to update. The app also checks for new releases when it starts.

To install a specific version, add `NEURALNOTE_VERSION`:

```bash
curl -fsSL https://raw.githubusercontent.com/aniiirudhh/neuralnote-releases/main/install.sh | NEURALNOTE_VERSION=0.1.1 bash
```

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

30-day free trial with every feature, then $29 once. Licenses are not on sale yet.

Website: https://neuralnote-adr.pages.dev
