// Premium status — always true for v1.0 (Phase 1: free launch).
// All users have full access. IAP will be restored in v2.0.

import 'package:flutter_riverpod/flutter_riverpod.dart';

final premiumProvider = AsyncNotifierProvider<_PremiumNotifier, bool>(
  _PremiumNotifier.new,
);

class _PremiumNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async => true;
}

/// Convenience sync provider — always true in v1.0.
final isPremiumProvider = Provider<bool>((ref) => true);
