abstract class FeatureFlags {
  static const bool enableUploadStub =
      bool.fromEnvironment('FEATURE_UPLOAD_STUB', defaultValue: true);
  static const bool disableChatWs =
      bool.fromEnvironment('DISABLE_CHAT_WS', defaultValue: false);
  static const bool allowLocalAuth =
      bool.fromEnvironment('ALLOW_LOCAL_AUTH', defaultValue: false);
  static const bool enableVideoCalls =
      bool.fromEnvironment('ENABLE_VIDEO_CALLS', defaultValue: true);
  static const bool showChatConfig =
      bool.fromEnvironment('SHOW_CHAT_CONFIG', defaultValue: false);
}
