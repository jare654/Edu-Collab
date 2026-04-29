import 'package:go_router/go_router.dart';
import '../../features/auth/auth_notifier.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/create_account_screen.dart';
import '../../features/auth/verify_code_screen.dart';
import '../../features/auth/start_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/assignments/assignment_detail_screen.dart';
import '../../features/assignments/assignment_submission_screen.dart';
import '../../features/assignments/student_assignments_screen.dart';
import '../../features/chat/group_chat_list_screen.dart';
import '../../features/chat/group_chat_screen.dart';
import '../../features/group/group_overview_screen.dart';
import '../../features/group/group_detail_screen.dart';
import '../../features/group/create_group_screen.dart';
import '../../features/home/student_home_screen.dart';
import '../../features/resources/resource_library_screen.dart';
import '../../features/resources/resource_detail_screen.dart';
import '../../features/analytics/student_analytics_screen.dart';
import '../../features/profile/student_profile_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/lecturer/lecturer_dashboard_screen.dart';
import '../../features/lecturer/lecturer_assignments_screen.dart';
import '../../features/lecturer/lecturer_submissions_screen.dart';
import '../../features/lecturer/lecturer_grade_screen.dart';
import '../../features/lecturer/lecturer_groups_screen.dart';
import '../../features/lecturer/lecturer_profile_screen.dart';
import '../../features/lecturer/lecturer_analytics_screen.dart';
import '../../features/lecturer/lecturer_create_assignment_screen.dart';
import '../../features/lecturer/lecturer_group_manage_screen.dart';
import '../../features/misc/empty_error_state_screen.dart';
import '../../features/group/group_analytics_screen.dart';
import '../../features/notes/notes_screen.dart';
import '../../features/notes/note_editor_screen.dart';
import '../../features/bookmarks/bookmarks_screen.dart';
import '../../features/meetings/schedule_session_screen.dart';
import '../../features/meetings/meeting_logs_screen.dart';
import '../../features/meetings/call_logs_screen.dart';
import '../../shared/widgets/student_scaffold.dart';
import '../../shared/widgets/lecturer_scaffold.dart';

GoRouter createRouter(AuthNotifier auth) {
  return GoRouter(
    refreshListenable: auth,
    initialLocation: '/splash',
    redirect: (context, state) {
      if (auth.loading) return null;
      final loggedIn = auth.isAuthenticated;
      final loc = state.matchedLocation;
      if (!loggedIn) {
        if (loc == '/start' ||
            loc == '/splash' ||
            loc == '/onboarding' ||
            loc == '/login' ||
            loc == '/signup' ||
            loc == '/forgot-password' ||
            loc == '/verify') {
          return null;
        }
        return '/start';
      }
      if (loc == '/start' ||
          loc == '/splash' ||
          loc == '/onboarding' ||
          loc == '/login' ||
          loc == '/signup' ||
          loc == '/verify') {
        return auth.role == null
            ? '/login'
            : (auth.role!.name == 'student'
                  ? '/student/home'
                  : '/lecturer/dashboard');
      }
      if (auth.role?.name == 'student' && loc.startsWith('/lecturer')) {
        return '/student/home';
      }
      if (auth.role?.name == 'lecturer' && loc.startsWith('/student')) {
        return '/lecturer/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, _) => const SplashScreen()),
      GoRoute(path: '/start', builder: (context, _) => const StartScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, _) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, _) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, _) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, _) => const VerifyCodeScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/misc/empty',
        builder: (context, _) => const EmptyErrorStateScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          final location = state.matchedLocation;
          int index = 0;
          if (location.startsWith('/student/assignments')) index = 1;
          if (location.startsWith('/student/groups')) index = 2;
          if (location.startsWith('/student/chat')) index = 3;
          if (location.startsWith('/student/calls')) index = 4;
          if (location.startsWith('/student/profile')) index = 5;
          return StudentScaffold(
            index: index,
            onTap: (i) {
              switch (i) {
                case 0:
                  context.go('/student/home');
                  break;
                case 1:
                  context.go('/student/assignments');
                  break;
                case 2:
                  context.go('/student/groups');
                  break;
                case 3:
                  context.go('/student/chat');
                  break;
                case 4:
                  context.go('/student/calls');
                  break;
                case 5:
                  context.go('/student/profile');
                  break;
              }
            },
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/student/home',
            builder: (context, _) => const StudentHomeScreen(),
          ),
          GoRoute(
            path: '/student/assignments',
            builder: (context, _) => const StudentAssignmentsScreen(),
          ),
          GoRoute(
            path: '/student/assignments/:id',
            builder: (_, state) => AssignmentDetailScreen(
              assignmentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/student/assignments/:id/submit',
            builder: (_, state) => AssignmentSubmissionScreen(
              assignmentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/student/notes',
            builder: (context, _) => const NotesScreen(),
          ),
          GoRoute(
            path: '/student/notes/create',
            builder: (context, _) => const NoteEditorScreen(isNew: true),
          ),
          GoRoute(
            path: '/student/notes/view',
            builder: (context, _) => const NoteEditorScreen(isNew: false),
          ),
          GoRoute(
            path: '/student/bookmarks',
            builder: (context, _) => const BookmarksScreen(),
          ),
          GoRoute(
            path: '/student/schedule_session',
            builder: (context, _) => const ScheduleSessionScreen(),
          ),
          GoRoute(
            path: '/student/resources',
            builder: (context, _) => const ResourceLibraryScreen(),
          ),
          GoRoute(
            path: '/student/resources/:id',
            builder: (_, state) =>
                ResourceDetailScreen(resourceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/student/groups',
            builder: (context, _) => const GroupOverviewScreen(),
          ),
          GoRoute(
            path: '/student/groups/create',
            builder: (context, _) => const CreateGroupScreen(),
          ),
          GoRoute(
            path: '/student/groups/:id',
            builder: (_, state) =>
                GroupDetailScreen(groupId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/student/groups/:id/analytics',
            builder: (_, state) =>
                GroupAnalyticsScreen(groupId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/student/chat',
            builder: (context, _) => const GroupChatListScreen(),
          ),
          GoRoute(
            path: '/student/chat/group/:id',
            builder: (_, state) =>
                GroupChatScreen(groupId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/student/calls',
            builder: (context, _) => const CallLogsScreen(),
          ),
          GoRoute(
            path: '/student/analytics',
            builder: (context, _) => const StudentAnalyticsScreen(),
          ),
          GoRoute(
            path: '/student/profile',
            builder: (context, _) => const StudentProfileScreen(),
          ),
          GoRoute(
            path: '/student/notifications',
            builder: (context, _) => const NotificationsScreen(),
          ),
        ],
      ),

      ShellRoute(
        builder: (context, state, child) {
          final location = state.matchedLocation;
          int index = 0;
          if (location.startsWith('/lecturer/assignments')) index = 1;
          if (location.startsWith('/lecturer/groups')) index = 2;
          if (location.startsWith('/lecturer/chat')) index = 3;
          if (location.startsWith('/lecturer/calls')) index = 4;
          if (location.startsWith('/lecturer/analytics')) index = 5;
          if (location.startsWith('/lecturer/profile')) index = 6;
          return LecturerScaffold(
            index: index,
            onTap: (i) {
              switch (i) {
                case 0:
                  context.go('/lecturer/dashboard');
                  break;
                case 1:
                  context.go('/lecturer/assignments');
                  break;
                case 2:
                  context.go('/lecturer/groups');
                  break;
                case 3:
                  context.go('/lecturer/chat');
                  break;
                case 4:
                  context.go('/lecturer/calls');
                  break;
                case 5:
                  context.go('/lecturer/analytics');
                  break;
                case 6:
                  context.go('/lecturer/profile');
                  break;
              }
            },
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/lecturer/dashboard',
            builder: (context, _) => const LecturerDashboardScreen(),
          ),
          GoRoute(
            path: '/lecturer/assignments',
            builder: (context, _) => const LecturerAssignmentsScreen(),
          ),
          GoRoute(
            path: '/lecturer/assignments/create',
            builder: (context, _) => const LecturerCreateAssignmentScreen(),
          ),
          GoRoute(
            path: '/lecturer/assignments/:id/submissions',
            builder: (_, state) => LecturerSubmissionsScreen(
              assignmentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/lecturer/assignments/:id/grade',
            builder: (_, state) =>
                LecturerGradeScreen(assignmentId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/lecturer/groups',
            builder: (context, _) => const LecturerGroupsScreen(),
          ),
          GoRoute(
            path: '/lecturer/groups/:id',
            builder: (_, state) =>
                GroupDetailScreen(groupId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/lecturer/groups/manage',
            builder: (context, _) => const LecturerGroupManageScreen(),
          ),
          GoRoute(
            path: '/lecturer/groups/create',
            builder: (context, _) => const CreateGroupScreen(),
          ),
          GoRoute(
            path: '/lecturer/chat',
            builder: (context, _) => const GroupChatListScreen(),
          ),
          GoRoute(
            path: '/lecturer/chat/group/:id',
            builder: (_, state) =>
                GroupChatScreen(groupId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/lecturer/calls',
            builder: (context, _) => const CallLogsScreen(),
          ),
          GoRoute(
            path: '/lecturer/analytics',
            builder: (context, _) => const LecturerAnalyticsScreen(),
          ),
          GoRoute(
            path: '/lecturer/profile',
            builder: (context, _) => const LecturerProfileScreen(),
          ),
          GoRoute(
            path: '/lecturer/meetings',
            builder: (context, _) => const MeetingLogsScreen(),
          ),
        ],
      ),
    ],
  );
}
