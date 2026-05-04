#!/usr/bin/env bash
# Verify every native lib in the latest profile/release APK is 16 KB-aligned.
#
# Phase 3 pre-flight check (Task 32 demo-day prep). Run after `flutter build
# apk --profile` or `--release`. Catches the flutter_gemma Native Assets
# stale-cache regression where libLiteRtLm.so ships with p_align=0x1000
# despite the package CHANGELOG claiming 16 KB compliance — the bundled
# tarball is keyed only on `android_arm64`, not the native version, so an
# older download silently survives flutter_gemma version bumps.
#
# Usage: bash tool/check_16kb_aligned.sh [path/to/app.apk]
# Defaults to build/app/outputs/flutter-apk/app-profile.apk.
#
# Requires: NDK r27+ on PATH (for llvm-readelf), unzip.
#
# Exits 0 when all LOAD segments have p_align >= 16384, non-zero otherwise.

set -euo pipefail

APK=${1:-build/app/outputs/flutter-apk/app-profile.apk}
if [[ ! -f "$APK" ]]; then
  echo "APK not found: $APK" >&2
  echo "Run 'flutter build apk --profile' first." >&2
  exit 2
fi

# Locate llvm-readelf from any installed NDK r27+.
READELF=""
if command -v llvm-readelf >/dev/null 2>&1; then
  READELF=llvm-readelf
elif [[ -n "${ANDROID_HOME:-}" || -n "${LOCALAPPDATA:-}" ]]; then
  NDK_BASE="${ANDROID_HOME:-$LOCALAPPDATA/Android/Sdk}/ndk"
  if [[ -d "$NDK_BASE" ]]; then
    LATEST=$(ls "$NDK_BASE" | sort -V | tail -1)
    for sub in linux-x86_64 darwin-x86_64 windows-x86_64; do
      C="$NDK_BASE/$LATEST/toolchains/llvm/prebuilt/$sub/bin/llvm-readelf"
      [[ -x "$C" || -x "$C.exe" ]] && READELF=$([[ -x "$C.exe" ]] && echo "$C.exe" || echo "$C") && break
    done
  fi
fi
if [[ -z "$READELF" ]]; then
  echo "llvm-readelf not found. Install Android NDK r27+ or put it on PATH." >&2
  exit 2
fi

WORK=$(mktemp -d)
trap "rm -rf '$WORK'" EXIT
unzip -q -o "$APK" "lib/arm64-v8a/*" -d "$WORK"

bad=0
for so in "$WORK"/lib/arm64-v8a/*.so; do
  bn=$(basename "$so")
  while read -r align; do
    [[ -z "$align" ]] && continue
    val=$((align))
    if (( val < 16384 )); then
      printf '  BAD  %s  p_align=%s (need >= 0x4000)\n' "$bn" "$align"
      bad=$((bad + 1))
    fi
  done < <("$READELF" -lW "$so" | awk '/LOAD/ {print $NF}' | sort -u)
done

if (( bad > 0 )); then
  echo
  echo "FAIL: $bad LOAD segment(s) below 16 KB. App will refuse to load on" >&2
  echo "      Android 15+ devices booted with 16 KB pages." >&2
  echo "      If a flutter_gemma library is at fault, wipe its Native Assets" >&2
  echo "      cache and rebuild:" >&2
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "        rm -rf \"\$LOCALAPPDATA/flutter_gemma/native\"" >&2
  else
    echo "        rm -rf ~/.cache/flutter_gemma/native" >&2
    echo "        rm -rf ~/Library/Caches/flutter_gemma/native  # macOS" >&2
  fi
  echo "        flutter clean && flutter build apk --profile" >&2
  exit 1
fi

echo "OK: all native libs in $APK are 16 KB-aligned."
