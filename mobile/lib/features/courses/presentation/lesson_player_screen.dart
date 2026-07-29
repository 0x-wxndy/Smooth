import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/smooth_button.dart';
import 'lesson_video_launcher.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.title,
    required this.videoAsset,
    this.alreadyCompleted = false,
  });

  final String courseId;
  final String lessonId;
  final String title;
  final String videoAsset;
  final bool alreadyCompleted;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  VideoPlayerController? _controller;
  bool _useExternalPlayer = false;
  String? _externalVideoPath;
  bool _ready = false;
  bool _error = false;
  String? _errorDetail;
  bool _completing = false;

  bool get _isLinuxDesktop => !kIsWeb && Platform.isLinux;

  @override
  void initState() {
    super.initState();
    if (widget.videoAsset.isEmpty) {
      _error = true;
      _errorDetail = 'No video asset linked to this lesson.';
      return;
    }
    if (_isLinuxDesktop) {
      _initExternalPlayer();
    } else {
      _initEmbeddedPlayer();
    }
  }

  Future<void> _initExternalPlayer() async {
    try {
      final path = await LessonVideoLauncher.resolvePlayablePath(widget.videoAsset);
      _externalVideoPath = path;
      await LessonVideoLauncher.openInSystemPlayer(path);
      if (!mounted) return;
      setState(() {
        _useExternalPlayer = true;
        _ready = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _errorDetail = '$e';
      });
    }
  }

  void _initEmbeddedPlayer() {
    final VideoPlayerController controller;
    if (LessonVideoLauncher.isFilePath(widget.videoAsset)) {
      controller = VideoPlayerController.file(File(widget.videoAsset));
    } else {
      controller = VideoPlayerController.asset(widget.videoAsset);
    }
    _controller = controller;
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      controller.play();
    }).catchError((Object e) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _errorDetail = '$e';
      });
    });
  }

  Future<void> _replayExternal() async {
    final path = _externalVideoPath;
    if (path == null) return;
    try {
      await LessonVideoLauncher.openInSystemPlayer(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (widget.alreadyCompleted || _completing) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    setState(() => _completing = true);
    final s = S.of(context);
    final result = await ref.read(databaseProvider).completeLesson(
          userId: userId,
          courseId: widget.courseId,
          lessonId: widget.lessonId,
        );
    ref.invalidate(courseModulesProvider(widget.courseId));
    ref.invalidate(courseProvider(widget.courseId));
    ref.invalidate(coursesProvider);
    ref.invalidate(gamificationProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.alreadyDone
              ? (result.message ?? s.lessonDone)
              : '${result.message ?? s.lessonDone}  ${s.rewardSnack(result.coins, result.xp)}',
        ),
        backgroundColor: result.alreadyDone ? null : AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontSize: 15)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _error
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'Could not load this video asset.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          if (_errorDetail != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _errorDetail!,
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    )
                  : !_ready
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : _useExternalPlayer
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.open_in_new_rounded,
                                    color: AppColors.primary,
                                    size: 56,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Video opened in your system player',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'On Linux desktop, lessons play in mpv/vlc. Watch the video, then mark the lesson complete below.',
                                    style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  OutlinedButton.icon(
                                    onPressed: _replayExternal,
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                                    icon: const Icon(Icons.replay_rounded),
                                    label: const Text('Open video again'),
                                  ),
                                ],
                              ),
                            )
                          : controller == null
                              ? const SizedBox.shrink()
                              : AspectRatio(
                                  aspectRatio: controller.value.aspectRatio == 0
                                      ? 16 / 9
                                      : controller.value.aspectRatio,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      VideoPlayer(controller),
                                      _Controls(controller: controller),
                                    ],
                                  ),
                                ),
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.navy,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.alreadyCompleted ? s.lessonDone : s.completeLesson,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                SmoothButton(
                  label: widget.alreadyCompleted ? s.lessonDone : s.completeLesson,
                  isLoading: _completing,
                  onPressed: _complete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatefulWidget {
  const _Controls({required this.controller});
  final VideoPlayerController controller;

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_tick);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_tick);
    super.dispose();
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final playing = c.value.isPlaying;
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => playing ? c.pause() : c.play(),
          child: Center(
            child: AnimatedOpacity(
              opacity: playing ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
