# Local patches

Drop `*.patch` files here to modify the upstream source before building.
`scripts/fetch-upstream.sh` applies every patch in this directory (in sorted
order) with `git apply` right after the pinned upstream checkout.

Generate a patch after editing files inside `upstream/`:

```bash
cd upstream
git diff > ../patches/0001-my-change.patch
```

Keep patches small and textual; if a patch stops applying after an upstream
bump, update the pin in `UPSTREAM` and re-create the diff.
