# Integration Tests

Run the integration test suite with:

```bash
make integration-tests
```

This runs each test individually to avoid the macOS runner debug connection crash and disables chat WebSocket connections by default.

## Chat WebSocket tests

To enable real WebSocket connections (uses the local mock server on `ws://localhost:8081/ws`):

```bash
ENABLE_CHAT_WS_TESTS=1 make integration-tests
```

When enabled, the script starts `tool/mock_chat_server.dart` in the background and shuts it down automatically after the run.
