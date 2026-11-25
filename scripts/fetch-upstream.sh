#!/usr/bin/env bash
# Fetch the pinned upstream DSH-iOS source into ./upstream.
#
# The upstream repo vendors the iSH-ARM64 emulator, the Objective-C app, the
# guest-rootfs recipes and the test suites -- far more than this wrapper repo
# needs to duplicate. We pin an exact commit (see UPSTREAM) and verify the
# checkout matches it, then apply any local patches from patches/*.patch.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
PIN_FILE="$ROOT/UPSTREAM"
DEST="$ROOT/upstream"

UPSTREAM_REPO="$(sed -n 's/^UPSTREAM_REPO=//p' "$PIN_FILE")"
UPSTREAM_SHA="$(sed -n 's/^UPSTREAM_SHA=//p' "$PIN_FILE")"
[ -n "$UPSTREAM_REPO" ] && [ -n "$UPSTREAM_SHA" ] || {
    echo "error: UPSTREAM_REPO/UPSTREAM_SHA missing in $PIN_FILE" >&2
    exit 1
}

if [ -d "$DEST/.git" ]; then
    echo "reusing existing checkout at $DEST"
else
    echo "fetching ${UPSTREAM_REPO}@${UPSTREAM_SHA}"
    rm -rf "$DEST"
    mkdir -p "$DEST"
    git -C "$DEST" init -q
    git -C "$DEST" remote add origin "https://github.com/${UPSTREAM_REPO}.git"
    git -C "$DEST" fetch --depth 1 origin "$UPSTREAM_SHA"
    git -C "$DEST" checkout -q FETCH_HEAD
fi

CHECKED_OUT="$(git -C "$DEST" rev-parse HEAD)"
if [ "$CHECKED_OUT" != "$UPSTREAM_SHA" ]; then
    echo "error: checkout is $CHECKED_OUT, expected $UPSTREAM_SHA" >&2
    exit 1
fi

if compgen -G "$ROOT/patches/*.patch" > /dev/null; then
    for p in "$ROOT"/patches/*.patch; do
        echo "applying patch: $p"
        git -C "$DEST" apply "$p"
    done
fi

echo "upstream ready: ${UPSTREAM_REPO}@${UPSTREAM_SHA}"
