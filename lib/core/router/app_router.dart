import 'package:go_router/go_router.dart';

import '../../features/groups/presentation/groups_screen.dart';
import '../../features/groups/presentation/group_detail_screen.dart';
import '../../features/groups/presentation/group_form_screen.dart';
import '../../features/participants/presentation/participants_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/expenses/presentation/expense_form_screen.dart';
import '../../features/settlements/presentation/settlements_screen.dart';
import '../../features/settlements/presentation/settlement_form_screen.dart';
import '../../features/summary/presentation/summary_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const GroupsScreen(),
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
      routes: [
        GoRoute(
          path: 'participants',
          builder: (ctx, state) => ParticipantsScreen(
              groupId: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: 'categories',
          builder: (ctx, state) => CategoriesScreen(
              groupId: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: 'expenses',
          builder: (ctx, state) => ExpensesScreen(
              groupId: int.parse(state.pathParameters['id']!)),
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
          path: 'settlements',
          builder: (ctx, state) => SettlementsScreen(
              groupId: int.parse(state.pathParameters['id']!)),
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
                settlementId:
                    int.parse(state.pathParameters['settlementId']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'summary',
          builder: (ctx, state) => SummaryScreen(
              groupId: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: 'analytics',
          builder: (ctx, state) => AnalyticsScreen(
              groupId: int.parse(state.pathParameters['id']!)),
        ),
      ],
    ),
  ],
);
