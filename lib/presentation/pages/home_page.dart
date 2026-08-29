import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/header_widget.dart';
import '../widgets/timer_count_down_widget.dart';
import '../widgets/trivia_rules_widget.dart';

/// A faithful Flutter recreation of the ChemShaa live-trivia waiting screen.
///
/// Add this file to lib/ and open [ChemShaaLiveTriviaPage] from your app.
class ChemShaaLiveTriviaPage extends StatefulWidget {
  const ChemShaaLiveTriviaPage({super.key});

  @override
  State<ChemShaaLiveTriviaPage> createState() =>
      _ChemShaaLiveTriviaPageState();
}

class _ChemShaaLiveTriviaPageState extends State<ChemShaaLiveTriviaPage> {
  static const _showHour = 14;
  static const _showMinute = 0;

  Timer? _timer;
  late DateTime _nextShow;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _nextShow = _getNextShowTime();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  DateTime _getNextShowTime() {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, _showHour, _showMinute);

    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }

    return target;
  }

  void _updateCountdown() {
    final now = DateTime.now();

    if (!now.isBefore(_nextShow)) {
      _nextShow = _getNextShowTime();
    }

    if (mounted) {
      setState(() {
        _remaining = _nextShow.difference(now);
      });
    }
  }

  String get _countdownText {
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

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
    const yellow = Color(0xFFFFDF57);
    const black = Color(0xFF050505);

    return Scaffold(
      backgroundColor: yellow,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height -
                        MediaQuery.paddingOf(context).top -
                        70,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      children: [
                        const Header(),
                        const SizedBox(height: 43),
                        const Text(
                          "Today's live trivia show is scheduled\nfor\nat 2:00 PM",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF101010),
                            fontSize: 21,
                            height: 1.36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 55),
                        const TriviaRulesWidget(),
                        const SizedBox(height: 43),

                        TimerCountDownWidget()
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}





