# NeuralNote releases

Public release downloads for **NeuralNote**, local voice-to-text for developers on Apple Silicon Macs.
Hold a hotkey, speak, and the text lands wherever your cursor is: Claude Code, Cursor, the terminal, Slack.

This repository only hosts release files. The source code is private.

## Install or update

```bash
curl -fsSL https://neuralnote.pages.dev/install.sh | bash
```

The installer downloads `NeuralNote.zip` from the latest release here, checks it against `NeuralNote.zip.sha256`, verifies the code signature, and copies `NeuralNote.app` into `/Applications`.

Requires an Apple Silicon Mac (M1 or later) on macOS 13.5 or newer.

## Why it isn't notarized

NeuralNote is signed with a stable self-signed identity ("NeuralNote Self-Signed") and is not notarized by Apple yet.
A browser-downloaded app that isn't notarized is blocked by Gatekeeper; files fetched with `curl` are not, which is why installs go through the script.
Notarization comes once sales cover Apple's Developer Program fee.

## Release files

| File | Purpose |
|---|---|
| `NeuralNote.zip` | The app, used by the installer |
| `NeuralNote.zip.sha256` | SHA-256 checksum of the zip |
| `NeuralNote-Installer.dmg` | Manual install (Gatekeeper will warn) |

## Pricing

30-day free trial with every feature, then $29 once: https://neuralnote.pages.dev
