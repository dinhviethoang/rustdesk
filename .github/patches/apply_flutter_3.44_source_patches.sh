#!/usr/bin/env bash
# Applies the Flutter 3.44-only source/pubspec changes on the fly, in CI only.
#
# Windows arm64 needs Flutter >= 3.44 (the first stable release shipping an arm64 Dart SDK +
# engine), and macOS arm64 builds with 3.44 for its NSTextInputContext crash fix
# (https://github.com/rustdesk/rustdesk/issues/16817). 3.44 renamed DialogTheme/TabBarTheme ->
# *Data and needs newer extended_text/google_fonts. Every other platform is still on Flutter
# 3.24.5, where the old names/versions are required, so these changes are kept OUT of the
# committed sources and applied here instead.
#
# Used by BOTH arm64 builds (flutter-build.yml) and their shared bridge artifact (bridge.yml) so
# they share an identical 3.44 source state -- the generated *.freezed.dart must compile against
# the same Flutter/freezed version the arm64 builds resolve.
#
# Remove this script (and commit the changes) once upstream bumps Flutter across the board.
#
# Run from the repository root. sed is used (not a git-apply patch) because the checked-out
# sources are CRLF on the windows-11-arm runner; the substitutions below are anchor-free and
# therefore CRLF-safe. The calls are GNU sed (`sed -i` without a suffix); the macOS arm64 job
# puts GNU sed first on PATH because BSD sed rejects them.
set -euo pipefail

# KinG-Control: theme đã viết lại (chỉ còn một ThemeData), nên bỏ kiểm tra số lượng anchor cố định
# của bản gốc; chỉ đổi tên API theme cho Flutter 3.27+ và nâng phiên bản dependency, rồi kiểm tra không còn tên cũ.
for f in flutter/lib/common.dart flutter/pubspec.yaml; do
  [[ -f "$f" && -r "$f" ]] || { echo "Flutter 3.44 source patch input is missing or unreadable: $f" >&2; exit 1; }
done

sed -i -E 's/DialogTheme\(/DialogThemeData(/g; s/TabBarTheme\(/TabBarThemeData(/g' flutter/lib/common.dart
sed -i 's/extended_text: 14.0.0/extended_text: 15.0.2/' flutter/pubspec.yaml
sed -i 's/google_fonts: \^6.2.1/google_fonts: ^8.1.0/' flutter/pubspec.yaml

if grep -qE '(DialogTheme|TabBarTheme)\(' flutter/lib/common.dart ||
   ! grep -qF 'extended_text: 15.0.2' flutter/pubspec.yaml ||
   ! grep -qF 'google_fonts: ^8.1.0' flutter/pubspec.yaml; then
  echo "Flutter 3.44 source patches did not produce the expected state." >&2
  exit 1
fi

git --no-pager diff -- flutter/lib/common.dart flutter/pubspec.yaml
