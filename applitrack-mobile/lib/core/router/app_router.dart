import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/settings_provider.dart';
import '../../providers/sync_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../widgets/app_shell.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/applications/applications_screen.dart';
import '../../screens/applications/add_application_screen.dart';
import '../../screens/applications/application_detail_screen.dart';
import '../../screens/applications/edit_application_screen.dart';
import '../../screens/applications/add_interview_screen.dart';
import '../../screens/applications/add_contact_screen.dart';
import '../../screens/interviews/interviews_screen.dart';
import '../../screens/analytics/analytics_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/documents/documents_screen.dart';
import '../../screens/sync/sync_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/notifications/notification_import_screen.dart';
import '../../screens/gmail/gmail_sync_screen.dart';
import '../../screens/goals/goals_screen.dart';
import '../../screens/companies/companies_screen.dart';
import '../../screens/companies/add_company_screen.dart';
import '../../screens/companies/company_jobs_screen.dart';
import '../../screens/companies/company_catalog_screen.dart';
import '../../screens/referrals/referrals_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  final settings = ref.watch(settingsNotifierProvider);
  final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Auth state still resolving — don't bounce anywhere yet.
      if (auth.isLoading) return null;

      final loggedIn = auth.valueOrNull != null;
      if (!loggedIn) return loc == '/login' ? null : '/login';

      // Signed in but hasn't seen onboarding.
      if (!settings.onboarded) return loc == '/onboarding' ? null : '/onboarding';

      // Signed in & onboarded — keep them out of the gateway screens.
      if (loc == '/login' || loc == '/onboarding') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/applications',
              builder: (context, state) => const ApplicationsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/companies',
              builder: (context, state) => const CompaniesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/interviews',
              builder: (context, state) => const InterviewsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/applications/add',
        builder: (context, state) => const AddApplicationScreen(),
      ),
      GoRoute(
        path: '/applications/:id',
        builder: (context, state) =>
            ApplicationDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/applications/:id/edit',
        builder: (context, state) =>
            EditApplicationScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/applications/:id/interview/add',
        builder: (context, state) =>
            AddInterviewScreen(applicationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/applications/:id/contact/add',
        builder: (context, state) =>
            AddContactScreen(applicationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/sync',
        builder: (context, state) => const SyncScreen(),
      ),
      GoRoute(
        path: '/notifications/import',
        builder: (context, state) => const NotificationImportScreen(),
      ),
      GoRoute(
        path: '/gmail/sync',
        builder: (context, state) => const GmailSyncScreen(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/referrals',
        builder: (context, state) => const ReferralsScreen(),
      ),
      GoRoute(
        path: '/companies/add',
        builder: (context, state) => const AddCompanyScreen(),
      ),
      GoRoute(
        path: '/companies/catalog',
        builder: (context, state) => const CompanyCatalogScreen(),
      ),
      GoRoute(
        path: '/companies/:id',
        builder: (context, state) =>
            CompanyJobsScreen(companyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/companies/:id/edit',
        builder: (context, state) =>
            AddCompanyScreen(companyId: state.pathParameters['id']!),
      ),
    ],
  );
}
