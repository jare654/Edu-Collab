import 'env.dart';

class ApiConfig {
  static const baseUrl = Env.SUPABASE_REST_URL;
  static const authBaseUrl = Env.SUPABASE_AUTH_URL;
  static const anonKey = Env.SUPABASE_ANON_KEY;
  static const storagePublicBase = Env.SUPABASE_STORAGE_PUBLIC;
  static const avatarsPublicBase = Env.SUPABASE_AVATARS_PUBLIC;
  static const chatWsBase = Env.CHAT_WS_URL;

  static String get storageBaseUrl =>
      baseUrl.replaceFirst('/rest/v1', '/storage/v1');
  static String get supabaseUrl => baseUrl.replaceFirst('/rest/v1', '');
  static String get functionsBaseUrl => '$supabaseUrl/functions/v1';

  static String get storageBucket {
    final marker = '/object/public/';
    final idx = storagePublicBase.indexOf(marker);
    if (idx == -1) return 'assignments';
    return storagePublicBase.substring(idx + marker.length);
  }

  static String get avatarsBucket {
    final marker = '/object/public/';
    final idx = avatarsPublicBase.indexOf(marker);
    if (idx == -1) return 'avatars';
    return avatarsPublicBase.substring(idx + marker.length);
  }

  static String get chatWsUrl {
    if (chatWsBase.contains('YOUR_CHAT_WS_URL')) {
      return 'ws://localhost:8081/ws';
    }
    return chatWsBase;
  }
}
