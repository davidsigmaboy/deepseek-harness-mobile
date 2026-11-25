# Legal notice

The build orchestration in this repository (Makefile, `scripts/fetch-upstream.sh`,
the GitHub Actions workflow, and the docs) is BSD-3-Clause licensed by
davidsigmaboy — see [LICENSE](LICENSE).

## The produced app is GPL-3.0

The unsigned IPA built by this pipeline is a **GPL-3.0** work:

- It statically links the **iSH / iSH-ARM64** userspace Linux emulator,
  licensed under the GNU GPL v3 (with iSH's additional App Store terms).
- The iOS app sources are fetched at build time from the pinned upstream in
  [UPSTREAM](UPSTREAM), a GPL-3.0 fork of [everettjf/dsh-ios](https://github.com/everettjf/dsh-ios).
- [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) itself is MIT-licensed,
  as are Alpine Linux package sources and Node.js where applicable.

Because the binary is GPL, anyone distributing the IPA must make the complete
corresponding source available under GPL-3.0. The source is publicly available
at the upstream repository named in [UPSTREAM](UPSTREAM); this repository
records the exact commit pinned for every build.

Not affiliated with DeepSeek, the iSH project, or Apple.
