import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/register_nop_screen.dart';
import 'screens/main_shell.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/detail_pajak_screen.dart';
import 'screens/payment_method_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/payment_success_screen.dart';
import 'screens/check_tax_screen.dart';
import 'screens/select_pbjt_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/linked_bank_screen.dart';
import 'screens/linked_card_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/register-nop',
        builder: (context, state) => const RegisterNopScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final billId = state.extra as String?;
          return DetailPajakScreen(billId: billId);
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final billId = state.extra as String?;
          return PaymentMethodScreen(billId: billId);
        },
      ),
      GoRoute(
        path: '/summary',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return SummaryScreen(
            billId: args?['billId'] as String?,
            bankName: args?['bankName'] as String? ?? 'Mandiri',
            isQris: args?['isQris'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: '/check-tax/:serviceName',
        builder: (context, state) {
          final serviceName = state.pathParameters['serviceName'] ?? 'Pajak';
          return CheckTaxScreen(serviceName: serviceName);
        },
      ),
      GoRoute(
        path: '/select-pbjt',
        builder: (context, state) {
          final npwpd = state.extra as String? ?? '';
          return SelectPbjtScreen(npwpd: npwpd);
        },
      ),
      GoRoute(
        path: '/pin',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return PinScreen(paymentArgs: args);
        },
      ),
      GoRoute(
        path: '/processing',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return ProcessingScreen(paymentArgs: args);
        },
      ),
      GoRoute(
        path: '/faq',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/linked-bank',
        builder: (context, state) => const LinkedBankScreen(),
      ),
      GoRoute(
        path: '/linked-card',
        builder: (context, state) => const LinkedCardScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsScreen(),
      ),
    ],
  );
}
