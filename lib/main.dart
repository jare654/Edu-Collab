import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'features/auth/auth_notifier.dart';
import 'features/auth/auth_repository_impl.dart';
import 'core/network/connectivity_service.dart';
import 'features/assignments/assignments_api.dart';
import 'features/assignments/assignments_local_cache.dart';
import 'features/assignments/assignments_repository_impl.dart';
import 'features/assignments/student_assignments_notifier.dart';
import 'features/group/group_repository_impl.dart';
import 'features/group/group_notifier.dart';
import 'features/chat/chat_repository.dart';
import 'features/chat/meet_notifier.dart';
import 'features/chat/chat_database.dart';
import 'features/resources/resources_repository_impl.dart';
import 'features/resources/resources_notifier.dart';
import 'features/notifications/notifications_repository.dart';
import 'features/notifications/notifications_notifier.dart';
import 'features/notifications/notification_service.dart';
import 'features/notifications/email_log_notifier.dart';
import 'features/lecturer/lecturer_assignments_repository_impl.dart';
import 'features/lecturer/lecturer_assignments_notifier.dart';
import 'features/lecturer/lecturer_submissions_repository_impl.dart';
import 'features/lecturer/lecturer_submissions_notifier.dart';
import 'features/meetings/meeting_service.dart';
import 'features/meetings/meeting_logs_repository.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_mode_notifier.dart';
import 'shared/widgets/app_background.dart';
import 'core/data/json_asset_loader.dart';
import 'core/storage/session_store.dart';
import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/localization/locale_notifier.dart';
import 'core/localization/app_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    anonKey: ApiConfig.anonKey,
  );
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => JsonAssetLoader()),
        Provider(create: (_) => SessionStore()),
        Provider(
          create: (ctx) =>
              ApiClient(ApiConfig.baseUrl, ctx.read<SessionStore>()),
        ),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ChangeNotifierProvider(create: (_) => ThemeModeNotifier()),
        Provider(
          create: (ctx) =>
              AssignmentsApi(ctx.read<ApiClient>(), ctx.read<SessionStore>()),
        ),
        Provider(create: (_) => AssignmentsLocalCache()),
        Provider(
          create: (ctx) => AssignmentsRepositoryImpl(
            ctx.read<AssignmentsApi>(),
            ctx.read<AssignmentsLocalCache>(),
            ctx.read<ConnectivityService>(),
            ctx.read<SessionStore>(),
          ),
        ),
        Provider(
          create: (ctx) => GroupRepositoryImpl(
            ctx.read<ConnectivityService>(),
            ctx.read<JsonAssetLoader>(),
            ctx.read<ApiClient>(),
          ),
        ),
        Provider(
          create: (ctx) => ResourcesRepositoryImpl(
            ctx.read<ConnectivityService>(),
            ctx.read<JsonAssetLoader>(),
            ctx.read<ApiClient>(),
          ),
        ),
        Provider(create: (_) => ChatDatabase(), dispose: (_, db) => db.close()),
        ChangeNotifierProvider(
          create: (ctx) => ChatRepository(ctx.read<ChatDatabase>()),
        ),
        Provider(
          create: (ctx) => AuthRepositoryImpl(
            ctx.read<JsonAssetLoader>(),
            ctx.read<ApiClient>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AuthNotifier(
            ctx.read<AuthRepositoryImpl>(),
            ctx.read<SessionStore>(),
          ),
        ),
        ProxyProvider<AuthNotifier, NotificationsRepository>(
          update: (ctx, auth, previous) =>
              NotificationsRepository(ctx.read<ApiClient>(), auth),
        ),
        Provider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => EmailLogNotifier()),
        Provider(create: (ctx) => MeetingService(ctx.read<ApiClient>())),
        Provider(create: (ctx) => MeetingLogsRepository(ctx.read<ApiClient>())),
        ChangeNotifierProvider(create: (_) => MeetNotifier()),
        ChangeNotifierProxyProvider<AuthNotifier, StudentAssignmentsNotifier>(
          create: (ctx) =>
              StudentAssignmentsNotifier(ctx.read<AssignmentsRepositoryImpl>()),
          update: (ctx, auth, previous) {
            final notifier =
                previous ??
                StudentAssignmentsNotifier(
                  ctx.read<AssignmentsRepositoryImpl>(),
                );
            notifier.ensureFreshForUser(auth.user?.id);
            return notifier;
          },
        ),
        ChangeNotifierProxyProvider2<
          NotificationsRepository,
          AuthNotifier,
          NotificationsNotifier
        >(
          create: (ctx) =>
              NotificationsNotifier(ctx.read<NotificationsRepository>()),
          update: (ctx, repo, auth, previous) {
            final notifier = previous ?? NotificationsNotifier(repo);
            notifier.updateRepository(repo);
            notifier.ensureFreshFor(auth.user?.email);
            return notifier;
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              GroupNotifier(ctx.read<GroupRepositoryImpl>())..load(),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              ResourcesNotifier(ctx.read<ResourcesRepositoryImpl>())..load(),
        ),
        Provider(
          create: (ctx) => LecturerAssignmentsRepositoryImpl(
            ctx.read<JsonAssetLoader>(),
            ctx.read<ApiClient>(),
          ),
        ),
        Provider(
          create: (ctx) => LecturerSubmissionsRepositoryImpl(
            ctx.read<JsonAssetLoader>(),
            ctx.read<ApiClient>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LecturerAssignmentsNotifier(
            ctx.read<LecturerAssignmentsRepositoryImpl>(),
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LecturerSubmissionsNotifier(
            ctx.read<LecturerSubmissionsRepositoryImpl>(),
          ),
        ),
        ProxyProvider<AuthNotifier, GoRouter>(
          update: (context, auth, previous) => previous ?? createRouter(auth),
        ),
      ],
      child: Builder(
        builder: (context) {
          final locale = context.watch<LocaleNotifier>().locale;
          final router = context.watch<GoRouter>();
          final themeMode = context.watch<ThemeModeNotifier>().themeMode;
          return MaterialApp.router(
            title: 'Academic Collaboration',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            builder: (context, child) =>
                AppBackground(child: child ?? const SizedBox.shrink()),
            locale: locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
          );
        },
      ),
    );
  }
}
