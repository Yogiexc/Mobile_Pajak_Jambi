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
import 'screens/receipt_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/linked_bank_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/other_taxes_screen.dart';
import 'screens/pbb_list_screen.dart';
import 'utils/page_transitions.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            AppPage.fade(state, const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            AppPage.fadeUp(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            AppPage.fadeUp(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/register-nop',
        pageBuilder: (context, state) =>
            AppPage.slide(state, const RegisterNopScreen()),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                AppPage.fade(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) =>
                AppPage.fade(state, const HistoryScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                AppPage.fade(state, const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/detail',
        pageBuilder: (context, state) {
          final billId = state.extra as String?;
          return AppPage.slide(state, DetailPajakScreen(billId: billId));
        },
      ),
      GoRoute(
        path: '/payment',
        pageBuilder: (context, state) {
          final billId = state.extra as String?;
          return AppPage.slide(state, PaymentMethodScreen(billId: billId));
        },
      ),
      GoRoute(
        path: '/summary',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return AppPage.slide(
            state,
            SummaryScreen(
              billId: args?['billId'] as String?,
              bankName: args?['bankName'] as String? ?? 'Mandiri',
              isQris: args?['isQris'] as bool? ?? false,
            ),
          );
        },
      ),
      GoRoute(
        path: '/success',
        pageBuilder: (context, state) =>
            AppPage.scaleFade(state, const PaymentSuccessScreen()),
      ),
      GoRoute(
        path: '/receipt',
        pageBuilder: (context, state) {
          final transactionId = state.extra as String? ?? '';
          return AppPage.slide(state, ReceiptScreen(transactionId: transactionId));
        },
      ),
      GoRoute(
        path: '/check-tax/:serviceName',
        pageBuilder: (context, state) {
          final encodedServiceName =
              state.pathParameters['serviceName'] ?? 'Pajak';
          final serviceName = Uri.decodeComponent(encodedServiceName);
          return AppPage.slide(state, CheckTaxScreen(serviceName: serviceName));
        },
      ),
      GoRoute(
        path: '/select-pbjt',
        pageBuilder: (context, state) {
          final npwpd = state.extra as String? ?? '';
          return AppPage.slide(state, SelectPbjtScreen(npwpd: npwpd));
        },
      ),
      GoRoute(
        path: '/pin',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return AppPage.fadeUp(state, PinScreen(paymentArgs: args));
        },
      ),
      GoRoute(
        path: '/processing',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return AppPage.fade(state, ProcessingScreen(paymentArgs: args));
        },
      ),
      GoRoute(
        path: '/faq',
        pageBuilder: (context, state) =>
            AppPage.slide(state, const FaqScreen()),
      ),
      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) =>
            AppPage.slide(state, const EditProfileScreen()),
      ),
      GoRoute(
        path: '/linked-bank',
        pageBuilder: (context, state) =>
            AppPage.slide(state, const LinkedBankScreen()),
      ),
      GoRoute(
        path: '/pbb-list',
        pageBuilder: (context, state) =>
            AppPage.slide(state, const PbbListScreen()),
      ),
      GoRoute(
        path: '/other-taxes',
        pageBuilder: (context, state) =>
            AppPage.slide(state, const OtherTaxesScreen()),
      ),
      GoRoute(
        path: '/privacy-policy',
        pageBuilder: (context, state) =>
            AppPage.slide(state, const PrivacyPolicyScreen()),
      ),
      GoRoute(
        path: '/terms',
        pageBuilder: (context, state) =>
            AppPage.slide(state, const TermsScreen()),
      ),
    ],
  );
}
