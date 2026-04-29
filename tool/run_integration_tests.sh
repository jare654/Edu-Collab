#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SERVER_PID=""
if [[ "${ENABLE_CHAT_WS_TESTS:-0}" == "1" ]]; then
  dart run "$ROOT_DIR/tool/mock_chat_server.dart" >/tmp/mock_chat_server.log 2>&1 &
  SERVER_PID=$!

  cleanup() {
    if [[ -n "${SERVER_PID}" ]] && kill -0 "$SERVER_PID" >/dev/null 2>&1; then
      kill "$SERVER_PID" >/dev/null 2>&1 || true
    fi
  }
  trap cleanup EXIT
fi

cd "$ROOT_DIR"

FLAGS=(--dart-define=DISABLE_GOOGLE_FONTS=true)
if [[ "${ENABLE_CHAT_WS_TESTS:-0}" != "1" ]]; then
  FLAGS+=(--dart-define=DISABLE_CHAT_WS=true)
fi

flutter test integration_test/login_submit_flow_test.dart -d macos "${FLAGS[@]}"
flutter test integration_test/lecturer_create_assignment_flow_test.dart -d macos "${FLAGS[@]}"
flutter test integration_test/student_resource_flow_test.dart -d macos "${FLAGS[@]}"
flutter test integration_test/student_group_chat_flow_test.dart -d macos "${FLAGS[@]}"
flutter test integration_test/student_profile_flow_test.dart -d macos "${FLAGS[@]}"
flutter test integration_test/student_analytics_flow_test.dart -d macos "${FLAGS[@]}"
flutter test integration_test/student_notifications_flow_test.dart -d macos "${FLAGS[@]}"
