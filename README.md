# Ariadne releases

Release feed for **Ariadne**, a native macOS knowledge-graph app. The app's
source lives in a private repository — this repo only hosts the release
assets its auto-updater consumes.

## Install (Apple Silicon, macOS 14+)

**One-liner** (no Gatekeeper friction — recommended):

```sh
curl -fsSL https://raw.githubusercontent.com/epenedos/Ariadne-releases/main/install.sh | sh
```

Installs the latest release into `/Applications` (override with
`ARIADNE_INSTALL_DIR`). Re-run it any time — it also updates in place.

**Installer package**: download `Ariadne.pkg` from the
[latest release](https://github.com/epenedos/Ariadne-releases/releases/latest)
and double-click. The package is unsigned, so macOS will ask you to allow it
once under **System Settings → Privacy & Security → Open Anyway**; the app it
installs is not quarantined and launches normally afterwards.

Either way, the installed app **keeps itself up to date**: it checks this
repo's releases on launch and daily, installs silently, and prompts to
relaunch.

## Notes

- Apple Silicon only (arm64), macOS 14 Sonoma or newer.
- The app is ad-hoc signed (no Developer ID): trust comes from TLS and this
  GitHub account. macOS may re-ask for permissions (e.g. Contacts) after an
  update, since the signing identity changes per build.
