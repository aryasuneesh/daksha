#!/usr/bin/env bash
# Exits non-zero if any network-related import or permission is found in lib/ or android/.
set -e

FAIL=0

echo "=== Scanning lib/ for network imports ==="
if grep -rn \
    -e 'dart:io.*HttpClient' \
    -e "package:http/" \
    -e "package:dio/" \
    -e "firebase_" \
    -e "sentry" \
    -e 'https\?://[a-zA-Z]' \
    lib/ 2>/dev/null; then
  echo "ERROR: network-related code found in lib/"
  FAIL=1
else
  echo "OK: no network imports in lib/"
fi

echo ""
echo "=== Scanning android/ for INTERNET permission ==="
if grep -rn '<uses-permission.*android\.permission\.INTERNET' android/ 2>/dev/null; then
  echo "ERROR: INTERNET permission found in android/"
  FAIL=1
else
  echo "OK: no INTERNET permission in android/"
fi

exit $FAIL
