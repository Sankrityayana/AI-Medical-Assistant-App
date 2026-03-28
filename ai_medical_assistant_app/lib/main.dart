import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'shared/widgets/blue_gradient_background.dart';
import 'shared/widgets/disclaimer_dialog.dart';
import 'shared/widgets/home_shell.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _disclaimerAccepted = false;
  bool _checkedDisclaimer = false;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('disclaimer_accepted') ?? false;
    await ref.read(authControllerProvider).checkSession();
    if (mounted) {
      setState(() {
        _disclaimerAccepted = accepted;
        _checkedDisclaimer = true;
      });
    }
  }

  Future<void> _acceptDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_accepted', true);
    if (mounted) {
      setState(() => _disclaimerAccepted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authStatusProvider);

    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: !_checkedDisclaimer
          ? const _AppStartupScreen()
          : Stack(
              children: [
                authStatus == AuthStatus.authenticated ? const HomeShell() : const LoginScreen(),
                if (!_disclaimerAccepted)
                  Builder(
                    builder: (context) {
                      if (!_dialogShown) {
                        _dialogShown = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => DisclaimerDialog(onAccepted: _acceptDisclaimer),
                          );
                        });
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
    );
  }
}

class _AppStartupScreen extends StatelessWidget {
  const _AppStartupScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: BlueGradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.health_and_safety_rounded, color: scheme.primary, size: 30),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppStrings.appName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Loading your secure health workspace...',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 18),
                      const LinearProgressIndicator(minHeight: 5),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
