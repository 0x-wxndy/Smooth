import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class AsyncContent<T> extends StatelessWidget {
  const AsyncContent({
    super.key,
    required this.value,
    required this.builder,
    this.loading,
  });

  final AsyncSnapshot<T> value;
  final Widget Function(T data) builder;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    if (value.connectionState == ConnectionState.waiting) {
      return loading ?? const Center(child: CircularProgressIndicator());
    }
    if (value.hasError) {
      return Center(child: Text('Error: ${value.error}'));
    }
    final data = value.data;
    if (data == null) {
      return const Center(child: Text('No data'));
    }
    return builder(data);
  }
}

/// Helper for Riverpod AsyncValue
class AsyncValueContent<T> extends StatelessWidget {
  const AsyncValueContent({
    super.key,
    required this.value,
    required this.builder,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading ?? const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
      ),
      data: builder,
    );
  }
}
