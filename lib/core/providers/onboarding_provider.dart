import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the groupId currently being onboarded.
/// null = no onboarding in progress.
final onboardingGroupIdProvider = StateProvider<int?>((ref) => null);
