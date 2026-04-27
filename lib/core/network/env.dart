import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(useConstantCase: true)
// ignore_for_file: constant_identifier_names
abstract class Env {
  @EnviedField(
    obfuscate: false,
    defaultValue: 'https://lcplvoxksxfzondhkppt.supabase.co/rest/v1',
  )
  static const String SUPABASE_REST_URL = _Env.SUPABASE_REST_URL;

  @EnviedField(
    obfuscate: false,
    defaultValue: 'https://lcplvoxksxfzondhkppt.supabase.co/auth/v1',
  )
  static const String SUPABASE_AUTH_URL = _Env.SUPABASE_AUTH_URL;

  @EnviedField(
    obfuscate: false,
    defaultValue: 'sb_publishable_9n-0ZcYK85S8k2Png_11nA_728i8B1L',
  )
  static const String SUPABASE_ANON_KEY = _Env.SUPABASE_ANON_KEY;

  @EnviedField(
    obfuscate: false,
    defaultValue: 'https://lcplvoxksxfzondhkppt.supabase.co/storage/v1/object/public/assignments',
  )
  static const String SUPABASE_STORAGE_PUBLIC = _Env.SUPABASE_STORAGE_PUBLIC;

  @EnviedField(
    obfuscate: false,
    defaultValue: 'https://lcplvoxksxfzondhkppt.supabase.co/storage/v1/object/public/avatars',
  )
  static const String SUPABASE_AVATARS_PUBLIC = _Env.SUPABASE_AVATARS_PUBLIC;

  @EnviedField(
    obfuscate: false,
    defaultValue:
        'wss://lcplvoxksxfzondhkppt.supabase.co/realtime/v1/websocket?apikey=sb_publishable_9n-0ZcYK85S8k2Png_11nA_728i8B1L',
  )
  static const String CHAT_WS_URL = _Env.CHAT_WS_URL;
}
