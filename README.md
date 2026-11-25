# DeepSeek Harness Mobile

DeepSeek Harness (`dsh`) — the open-source agent harness from
[deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) —
running as a **native iOS/iPadOS app**, built into an **unsigned IPA by
GitHub Actions** so anyone can install it for free.

The app embeds an Alpine Linux guest (Node.js + `@deepseek-ai/dsh`) inside an
iSH-ARM64 emulator and shows the harness Web UI in a WKWebView. The agent,
shell and sessions run entirely on the device; only model inference calls the
online API key you configure in the app. Requires iOS/iPadOS 16+.

## How this repo works

This repo is the packaging/distribution harness. The app source is pinned to a
verified upstream commit (see [`UPSTREAM`](UPSTREAM)) and fetched at build time
by [`scripts/fetch-upstream.sh`](scripts/fetch-upstream.sh):

- **Upstream:** [wjc19980523-glitch/dsh-ios-ipa](https://github.com/wjc19980523-glitch/dsh-ios-ipa),
  itself a fork of [everettjf/dsh-ios](https://github.com/everettjf/dsh-ios),
  which integrates [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness)
  (MIT) with the [iSH / iSH-ARM64](https://github.com/ish-app/ish) Linux
  emulator (GPLv3).
- **Build:** [`.github/workflows/build-ipa.yml`](.github/workflows/build-ipa.yml)
  runs on a free `macos-15` runner: fetch pinned source → build the iSH-ARM64
  emulator → build/restore the Alpine+Node+dsh guest image → generate the
  Xcode project → archive → package an **unsigned IPA** with a SHA-256
  checksum.
- **Customize:** drop `*.patch` files in [`patches/`](patches/README.md) to
  modify the app before building, or bump the pin in [`UPSTREAM`](UPSTREAM).

### Build triggers

| Event | Result |
|---|---|
| Push to `main` | IPA uploaded as a workflow artifact (`DSH-unsigned-ipa`) |
| Tag `v*` (e.g. `v1.1.0`) | IPA published as a **GitHub Release** |
| Actions ▸ "Build DSH iOS" ▸ Run workflow | Manual build |

The first build per upstream pin is slow (the guest image is built inside the
emulator: ~30–60 min); later builds reuse the cached image. Subsequent builds
with the same pin take ~10–20 minutes.

## Install the IPA for free (no paid developer account)

The IPA is unsigned on purpose — Apple requires a signature, but that signature
can come from a **free Apple ID**:

1. Download the IPA from the [Releases](../../releases) page (or the workflow
   artifact) and verify it:
   `shasum -a 256 DSH-*.ipa` must match the published `ipa.sha256`.
2. Re-sign and install with any of these (all work with a free Apple ID):
   - **Sideloadly** (Windows/Mac) — drag the IPA in, sign in, install.
   - **AltStore** or **SideStore** — sideloads over Wi-Fi and can refresh the
     signature automatically.
   - **Scarlet / ESign / Feather** (on-device).
3. Free Apple IDs sign apps for **7 days** — refresh weekly (AltStore/Feather
   automate this). A paid Apple Developer account signs for one year instead.
4. On the device: Settings ▸ General ▸ VPN & Device Management ▸ trust the
   developer profile; enable Developer Mode (Settings ▸ Privacy & Security)
   when iOS asks. Then open DSH and add your model API key in the app.

## Build on your own Mac

```bash
brew install meson ninja lld libarchive
gem install xcodeproj
make ipa        # unsigned .xcarchive in upstream/build/
```

## License and credits

**GPL-3.0** — the app statically links the GPLv3 iSH/iSH-ARM64 emulator, so
the whole app is GPL. See [LICENSE](LICENSE).

- [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) — the agent harness (MIT)
- [everettjf/dsh-ios](https://github.com/everettjf/dsh-ios) — original iOS integration
- [wjc19980523-glitch/dsh-ios-ipa](https://github.com/wjc19980523-glitch/dsh-ios-ipa) — pinned build source
- [ish-app/ish](https://github.com/ish-app/ish) · [OpenMinis/ish-arm64](https://github.com/OpenMinis/ish-arm64) — the emulator (GPLv3)
- [Alpine Linux](https://alpinelinux.org), Node.js, DeepSeek Harness npm packages

Not affiliated with DeepSeek, iSH, or Apple. You are responsible for complying
with the model API terms of whichever provider key you configure.
