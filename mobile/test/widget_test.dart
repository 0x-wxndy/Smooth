import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_app/app.dart';
import 'package:smooth_app/core/database/database_init.dart';
import 'package:smooth_app/shared/data/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  configureDatabaseFactory();

  testWidgets('Smooth app smoke test', (tester) async {
    await AppDatabase.instance.init();
    await tester.pumpWidget(const ProviderScope(child: SmoothApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Smooth'), findsWidgets);
  });
}
