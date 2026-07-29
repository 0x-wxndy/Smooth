import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/database_init.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/brand_splash_screen.dart';
import 'shared/data/database/app_database.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDatabaseFactory();
  runApp(const ProviderScope(child: BootstrapApp()));
}

/// Loads the local database before showing the main app.
class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  Locale _locale = const Locale('fr');
  late final Future<void> _initFuture = _initialize();

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('smooth_locale') ?? 'fr';
    _locale = Locale(code);

    await Future.wait([
      AppDatabase.instance.init(),
      Future<void>.delayed(const Duration(milliseconds: 1600)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: BrandSplashScreen(locale: _locale),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: AppColors.background,
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to start app',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const SmoothApp();
      },
    );
  }
}
