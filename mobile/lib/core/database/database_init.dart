import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Configures sqflite for the current platform.
/// Android/iOS use the native implementation; desktop needs FFI.
void configureDatabaseFactory() {
  if (kIsWeb) return;

  switch (defaultTargetPlatform) {
    case TargetPlatform.linux:
    case TargetPlatform.windows:
    case TargetPlatform.macOS:
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    default:
      break;
  }
}
