import 'package:go_router/go_router.dart';

import '../../features/groups/presentation/groups_screen.dart';
import '../../features/groups/presentation/group_detail_screen.dart';
import '../../features/groups/presentation/group_form_screen.dart';
import '../../features/participants/presentation/participants_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../core/providers/onboarding_state.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/expenses/presentation/expense_form_screen.dart';
import '../../features/settlements/presentation/settlements_screen.dart';
import '../../features/settlements/presentation/settlement_form_screen.dart';
import '../../features/summary/presentation/summary_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (_, __) => const GroupsScreen(),
    ),
    GoRoute(
      path: '/more',
      builder: (ctx, state) {
        final gid = state.uri.queryParameters['groupId'];
        return MoreScreen(groupId: gid != null ? int.tryParse(gid) : null);
      },
    ),
    GoRoute(
      path: '/group/new',
      builder: (_, __) => const GroupFormScreen(),
    ),
    GoRoute(
      path: '/group/:id/edit',
      builder: (ctx, state) =>
          GroupFormScreen(groupId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/group/:id',
      builder: (ctx, state) =>
          GroupDetailScreen(groupId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/group/:id/participants',
      builder: (ctx, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ParticipantsScreen(
          groupId: id,
          isOnboarding: onboardingGroupId == id,
        );
      },
    ),
    GoRoute(
      path: '/group/:id/categories',
      builder: (ctx, state) {
        final id = int.parse(state.pathParameters['id']!);
        return CategoriesScreen(
          groupId: id,
          isOnboarding: onboardingGroupId == id,
        );
      },
    ),
    GoRoute(
      path: '/group/:id/expenses',
      builder: (ctx, state) =>
          ExpensesScreen(groupId: int.parse(state.pathParameters['id']!)),
      routes: [
        GoRoute(
          path: 'new',
          builder: (ctx, state) => ExpenseFormScreen(
              groupId: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: ':expenseId/edit',
          builder: (ctx, state) => ExpenseFormScreen(
            groupId: int.parse(state.pathParameters['id']!),
            expenseId: int.parse(state.pathParameters['expenseId']!),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/group/:id/settlements',
      builder: (ctx, state) =>
          SettlementsScreen(groupId: int.parse(state.pathParameters['id']!)),
      routes: [
        GoRoute(
          path: 'new',
          builder: (ctx, state) => SettlementFormScreen(
              groupId: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: ':settlementId/edit',
          builder: (ctx, state) => SettlementFormScreen(
            groupId: int.parse(state.pathParameters['id']!),
            settlementId: int.parse(state.pathParameters['settlementId']!),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/group/:id/summary',
      builder: (ctx, state) =>
          SummaryScreen(groupId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);
