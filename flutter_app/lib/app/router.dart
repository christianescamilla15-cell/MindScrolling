import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Feature screens
import '../features/bootstrap/bootstrap_screen.dart';
import '../features/challenges/challenges_screen.dart';
import '../features/donations/donations_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/philosophy_map/philosophy_map_screen.dart';
import '../features/premium/premium_screen.dart';
import '../features/premium/redeem_code_screen.dart';
import '../features/authors/author_detail_screen.dart';
import '../features/packs/packs_screen.dart';
import '../features/packs/pack_preview_screen.dart';
import '../features/packs/pack_feed_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/hidden_modes/quiz_screen.dart';
import '../features/hidden_modes/coding_mode_screen.dart';
import '../features/hidden_modes/science_mode_screen.dart';
import '../features/feed/similar_quotes_screen.dart';
import '../features/vault/vault_screen.dart';

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) async {
      if (state.matchedLocation == '/') return null;
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BootstrapScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/vault',
        builder: (context, state) => const VaultScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/philosophy-map',
        builder: (context, state) => const PhilosophyMapScreen(),
      ),
      GoRoute(
        path: '/challenges',
        builder: (context, state) => const ChallengesScreen(),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/author/:slug',
        builder: (context, state) => AuthorDetailScreen(
          authorName: Uri.decodeComponent(state.pathParameters['slug'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/redeem',
        builder: (context, state) => const RedeemCodeScreen(),
      ),
      GoRoute(
        path: '/packs',
        builder: (context, state) => const PacksScreen(),
      ),
      GoRoute(
        path: '/packs/:packId/preview',
        builder: (context, state) {
          final packId =
              Uri.decodeComponent(state.pathParameters['packId'] ?? '');
          final extra =
              state.extra as Map<String, dynamic>? ?? const {};
          return PackPreviewScreen(
            packId: packId,
            packName: extra['packName'] as String? ?? packId,
            packColor: extra['packColor'] as String? ?? '#14B8A6',
          );
        },
      ),
      GoRoute(
        path: '/packs/:packId/feed',
        builder: (context, state) {
          final packId =
              Uri.decodeComponent(state.pathParameters['packId'] ?? '');
          final extra =
              state.extra as Map<String, dynamic>? ?? const {};
          return PackFeedScreen(
            packId: packId,
            packName: extra['packName'] as String? ?? packId,
            packColor: extra['packColor'] as String? ?? '#14B8A6',
          );
        },
      ),
      GoRoute(
        path: '/hidden/science',
        builder: (context, state) => const ScienceModeScreen(),
      ),
      GoRoute(
        path: '/hidden/coding',
        builder: (context, state) => const CodingModeScreen(),
      ),
      GoRoute(
        path: '/quiz/:mode',
        builder: (context, state) {
          final mode = state.pathParameters['mode'] ?? 'science';
          return QuizScreen(mode: mode);
        },
      ),
      GoRoute(
        path: '/similar/:id',
        builder: (context, state) => SimilarQuotesScreen(
          quoteId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/donations',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: DonationsScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(
                color: Color(0xFFF5F0E8),
                fontSize: 48,
                fontFamily: 'Playfair',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(
                color: Color(0x80F5F0E8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text(
                'Go home',
                style: TextStyle(color: Color(0xFF14B8A6)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
});
