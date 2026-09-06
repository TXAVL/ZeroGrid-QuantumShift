import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/engine/board_state.dart';
import '../../core/engine/replay_recorder.dart';
import '../../core/localization/txa_language.dart';
import '../../state/theme_notifier.dart';

/// Modal trình phát Ghost Replay timelapse
class ReplayViewerModal extends ConsumerStatefulWidget {
  final GhostReplayData replay;

  const ReplayViewerModal({super.key, required this.replay});

  @override
  ConsumerState<ReplayViewerModal> createState() => _ReplayViewerModalState();
}

class _ReplayViewerModalState extends ConsumerState<ReplayViewerModal> {
  late BoardState _currentBoard;
  int _currentStepIndex = 0;
  bool _isPlaying = false;
  Timer? _playbackTimer;
  final int _playbackSpeedMs = 400; // 400ms mỗi bước

  @override
  void initState() {
    super.initState();
    _resetToStart();
    _startPlayback();
  }

  void _resetToStart() {
    _currentBoard = BoardState.fromGrid(
      widget.replay.initialGrid,
      maxK: widget.replay.maxK,
    );
    _currentStepIndex = 0;
  }

  void _startPlayback() {
    _isPlaying = true;
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(Duration(milliseconds: _playbackSpeedMs), (timer) {
      if (_currentStepIndex < widget.replay.steps.length) {
        final step = widget.replay.steps[_currentStepIndex];
        final moveResult = _currentBoard.applyMove(step.row, step.col);
        setState(() {
          _currentBoard = moveResult.newState;
          _currentStepIndex++;
        });
      } else {
        timer.cancel();
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _playbackTimer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      if (_currentStepIndex >= widget.replay.steps.length) {
        _resetToStart();
      }
      _startPlayback();
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final langCode = ref.watch(languageProvider);
    final totalSteps = widget.replay.steps.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: palette.boardFrame,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: palette.accentNeon, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history_toggle_off_rounded, color: palette.accentNeon),
                    const SizedBox(width: 8),
                    Text(
                      TxaLanguage.tr('replay_viewer_title', langCode),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: palette.accentNeon,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Mini board representation
            Container(
              width: 240,
              height: 240,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: List.generate(_currentBoard.size, (r) {
                  return Expanded(
                    child: Row(
                      children: List.generate(_currentBoard.size, (c) {
                        final val = _currentBoard.getValue(r, c);
                        final cellColor = palette.getColorForValue(val);
                        final isZero = (val == 0);

                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isZero ? palette.cellInactive : cellColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isZero ? palette.cellInactive : cellColor,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$val',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isZero ? palette.textSecondary : cellColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Progress text
            Text(
              '${TxaLanguage.tr('replay_step_label', langCode)}: $_currentStepIndex / $totalSteps',
              style: TextStyle(color: palette.textSecondary, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay, color: Colors.white),
                  onPressed: () {
                    _playbackTimer?.cancel();
                    setState(() {
                      _resetToStart();
                      _startPlayback();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 40,
                    color: palette.accentNeon,
                  ),
                  onPressed: _togglePlayPause,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
