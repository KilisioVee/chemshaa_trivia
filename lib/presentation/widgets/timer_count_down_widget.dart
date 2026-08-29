import 'dart:async';

import 'package:flutter/material.dart';

/// A complete trivia-countdown panel that counts down to the next 2:00 PM.
///
/// If it is already 2:00 PM or later, it targets 2:00 PM tomorrow.
/// Time is based on the user's device-local timezone.
class TimerCountDownWidget extends StatefulWidget {
  const TimerCountDownWidget({
    super.key,
    this.onComplete,
  });

  final VoidCallback? onComplete;

  @override
  State<TimerCountDownWidget> createState() => _TimerCountDownWidgetState();
}

class _TimerCountDownWidgetState extends State<TimerCountDownWidget> {
  static const Color black = Color(0xFF050505);

  Timer? _timer;
  late DateTime _targetTime;
  Duration _remaining = Duration.zero;
  bool _hasCalledComplete = false;

  @override
  void initState() {
    super.initState();

    _targetTime = _nextTwoPm();
    _updateCountdown();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _updateCountdown(),
    );
  }

  /// Returns 2:00 PM today, or 2:00 PM tomorrow if today's show has passed.
  DateTime _nextTwoPm() {
    final now = DateTime.now();

    var target = DateTime(
      now.year,
      now.month,
      now.day,
      14, // 2 PM
      0,
      0,
    );

    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }

    return target;
  }

  void _updateCountdown() {
    final now = DateTime.now();
    var difference = _targetTime.difference(now);

    if (difference <= Duration.zero) {
      if (!_hasCalledComplete) {
        _hasCalledComplete = true;
        widget.onComplete?.call();
      }

      _targetTime = _nextTwoPm();
      difference = _targetTime.difference(DateTime.now());
    }

    if (!mounted) return;

    setState(() {
      _remaining = difference;
    });
  }

  String get _countdownText {
    final totalSeconds = _remaining.inSeconds.clamp(0, 24 * 60 * 60);

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: black,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 13),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'The live trivia show begins in',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _countdownText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}