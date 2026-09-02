import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A question model for the live trivia popup.
class TriviaQuestion {
  const TriviaQuestion({
    required this.question,
    required this.choices,
    required this.correctIndex,
  });

  final String question;
  final List<String> choices;
  final int correctIndex;
}

/// Ten ready-to-use randomized trivia questions. Call [shuffledTriviaQuestions]
/// at the beginning of each game to randomize their order.
const liveTriviaQuestions = <TriviaQuestion>[
  TriviaQuestion(
    question: 'Which planet is known as the Red Planet?',
    choices: ['Venus', 'Mars', 'Jupiter', 'Mercury'],
    correctIndex: 1,
  ),
  TriviaQuestion(
    question: 'What is the capital city of Kenya?',
    choices: ['Mombasa', 'Nakuru', 'Nairobi', 'Kisumu'],
    correctIndex: 2,
  ),
  TriviaQuestion(
    question: 'Which ocean is the largest on Earth?',
    choices: ['Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean', 'Pacific Ocean'],
    correctIndex: 3,
  ),
  TriviaQuestion(
    question: 'How many sides does a hexagon have?',
    choices: ['Five', 'Six', 'Seven', 'Eight'],
    correctIndex: 1,
  ),
  TriviaQuestion(
    question: 'Which animal is commonly called the king of the jungle?',
    choices: ['Elephant', 'Lion', 'Leopard', 'Cheetah'],
    correctIndex: 1,
  ),
  TriviaQuestion(
    question: 'What is H₂O more commonly known as?',
    choices: ['Salt', 'Oxygen', 'Water', 'Hydrogen'],
    correctIndex: 2,
  ),
  TriviaQuestion(
    question: 'Which Kenyan athlete won Olympic 800 m gold in Beijing in 2008?',
    choices: ['Faith Kipyegon', 'Pamela Jelimo', 'Vivian Cheruiyot', 'Tegla Loroupe'],
    correctIndex: 1,
  ),
  TriviaQuestion(
    question: 'What is the first month of the year?',
    choices: ['December', 'January', 'February', 'March'],
    correctIndex: 1,
  ),
  TriviaQuestion(
    question: 'Which instrument has black and white keys?',
    choices: ['Guitar', 'Piano', 'Drum', 'Violin'],
    correctIndex: 1,
  ),
  TriviaQuestion(
    question: 'How many days are there in a leap year?',
    choices: ['364', '365', '366', '367'],
    correctIndex: 2,
  ),
];

List<TriviaQuestion> shuffledTriviaQuestions() {
  final questions = List<TriviaQuestion>.from(liveTriviaQuestions);
  questions.shuffle(Random());
  return questions;
}

/// Opens the live trivia experience above the current home screen.
///
/// [useRootNavigator] lets the popup cover a bottom navigation bar, if present.
Future<void> showLiveTriviaPopup(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierLabel: 'Live trivia game',
    barrierColor: Colors.black.withValues(alpha: 0.76),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const _LiveTriviaDialog(),
    transitionBuilder: (_, animation, __, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(opacity: curvedAnimation, child: child),
      );
    },
  );
}

enum _TriviaStage {
  question,
  answerReveal,
  hostTalking,
  nextQuestionLoading,
  finished,
}

class _LiveTriviaDialog extends StatefulWidget {
  const _LiveTriviaDialog();

  @override
  State<_LiveTriviaDialog> createState() => _LiveTriviaDialogState();
}

class _LiveTriviaDialogState extends State<_LiveTriviaDialog> {
  static const _secondsPerQuestion = 10;
  static const _answerRevealDuration = Duration(seconds: 5);
  static const _hostTalkingDuration = Duration(seconds: 7);
  static const _nextQuestionLoadingDuration = Duration(seconds: 4);
  static const _cashPrize = 'KES 50,000';

  static const _correctGreen = Color(0xFF42B64E);
  static const _wrongRed = Color(0xFFE94B45);
  static const _choiceTextDark = Color(0xFF242424);
  static const _choiceBorder = Color(0xFFE1E1E1);

  late final List<TriviaQuestion> _questions;
  Timer? _questionTimer;
  Timer? _stageTimer;

  int _questionIndex = 0;
  int _secondsRemaining = _secondsPerQuestion;
  int? _selectedIndex;
  _TriviaStage _stage = _TriviaStage.question;
  bool _isEliminated = false;

  TriviaQuestion get _currentQuestion => _questions[_questionIndex];
  bool get _hasAnswered => _stage != _TriviaStage.question;
  bool get _isFinished => _stage == _TriviaStage.finished;

  /// A timeout is represented by no selected choice during the answer reveal.
  bool get _isNoAnswer =>
      _selectedIndex == null && _stage == _TriviaStage.answerReveal;

  @override
  void initState() {
    super.initState();
    _questions = shuffledTriviaQuestions();
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _stageTimer?.cancel();
    _secondsRemaining = _secondsPerQuestion;

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _stage != _TriviaStage.question) return;

      if (_secondsRemaining <= 1) {
        _questionTimer?.cancel();
        setState(() => _secondsRemaining = 0);
        _revealTimedOutAnswer();
        return;
      }

      setState(() => _secondsRemaining--);
    });
  }

  void _answerQuestion(int index) {
    if (_stage != _TriviaStage.question) return;

    _questionTimer?.cancel();
    final isCorrect = index == _currentQuestion.correctIndex;

    setState(() {
      _selectedIndex = index;
      _stage = _TriviaStage.answerReveal;
      if (!isCorrect) _isEliminated = true;
    });

    _scheduleHostTalking();
  }

  void _revealTimedOutAnswer() {
    if (_stage != _TriviaStage.question) return;

    setState(() {
      _selectedIndex = null;
      _stage = _TriviaStage.answerReveal;
      _isEliminated = true;
    });

    _scheduleHostTalking();
  }

  /// Shows answer feedback for three seconds, then automatically starts the
  /// full-screen host-speaking stage. No action is required from the user.
  void _scheduleHostTalking() {
    _stageTimer?.cancel();
    _stageTimer = Timer(_answerRevealDuration, () {
      if (!mounted || _stage != _TriviaStage.answerReveal) return;

      setState(() => _stage = _TriviaStage.hostTalking);
      _scheduleNextQuestionLoading();
    });
  }

  void _scheduleNextQuestionLoading() {
    _stageTimer?.cancel();
    _stageTimer = Timer(_hostTalkingDuration, () {
      if (!mounted || _stage != _TriviaStage.hostTalking) return;

      setState(() => _stage = _TriviaStage.nextQuestionLoading);
      _scheduleNextQuestion();
    });
  }

  void _scheduleNextQuestion() {
    _stageTimer?.cancel();
    _stageTimer = Timer(_nextQuestionLoadingDuration, () {
      if (!mounted || _stage != _TriviaStage.nextQuestionLoading) return;
      _loadNextQuestion();
    });
  }

  void _loadNextQuestion() {
    if (_questionIndex == _questions.length - 1) {
      _questionTimer?.cancel();
      _stageTimer?.cancel();
      setState(() => _stage = _TriviaStage.finished);
      return;
    }

    setState(() {
      _questionIndex++;
      _selectedIndex = null;
      _stage = _TriviaStage.question;
    });
    _startQuestionTimer();
  }

  /// Determines each choice background during the answer-reveal state.
  ///
  /// Wrong selection: selected choice is red and the correct one is green.
  /// No answer: correct choice is red, following the requested behaviour.
  Color _choiceColor(int index) {
    if (_stage == _TriviaStage.question) return Colors.white;

    final correctIndex = _currentQuestion.correctIndex;

    if (_selectedIndex == null) {
      return index == correctIndex ? _wrongRed : Colors.white;
    }

    if (_selectedIndex != correctIndex) {
      if (index == _selectedIndex) return _wrongRed;
      if (index == correctIndex) return _correctGreen;
      return Colors.white;
    }

    return index == correctIndex ? _correctGreen : Colors.white;
  }

  Color _choiceTextColor(int index) {
    return _choiceColor(index) == Colors.white ? _choiceTextDark : Colors.white;
  }

  Color _choiceBorderColor(int index) {
    return _choiceColor(index) == Colors.white
        ? _choiceBorder
        : _choiceColor(index);
  }

  String get _answerStatus {
    if (_isNoAnswer) return 'No answer';
    if (_selectedIndex == _currentQuestion.correctIndex) return 'Correct';
    return 'Incorrect';
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _stageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == _TriviaStage.hostTalking ||
        _stage == _TriviaStage.nextQuestionLoading) {
      return Material(
        color: Colors.black,
        child: _stage == _TriviaStage.hostTalking
            ? _buildHostTalkingView()
            : _buildNextQuestionLoadingView(),
      );
    }

    return SafeArea(
      top: false,
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: 80.h,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: _isFinished ? _buildFinishedView() : _buildGameView(),
          ),
        ),
      ),
    );
  }

  Widget _buildGameView() {
    final progress = _secondsRemaining / _secondsPerQuestion;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 15),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 28.w,
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/png/logo.png',
                            width: 10.w,
                            height: 10.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${_questionIndex+1}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 45.w,
                      child: Center(
                        child: Text(
                          _hasAnswered
                              ? _answerStatus
                              : _isEliminated
                              ? 'Eliminated'
                              : 'Live',
                          style: TextStyle(
                            color: _hasAnswered &&
                                _selectedIndex == _currentQuestion.correctIndex
                                ? _correctGreen
                                : _hasAnswered || _isEliminated
                                ? _wrongRed
                                : _correctGreen,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 17.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 10.w,
                            height: 10.w,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2,
                              strokeCap: StrokeCap.round,
                              color: _secondsRemaining <= 5 ? _wrongRed : _correctGreen,
                              backgroundColor: const Color(0xFFE9E9E9),
                            ),
                          ),
                          Text(
                            _secondsRemaining.toString(),
                            style: TextStyle(
                              color: _secondsRemaining <= 5 ? _wrongRed : _choiceTextDark,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                 SizedBox(height: 2.h),
                Text(
                  _currentQuestion.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _choiceTextDark,
                    fontSize: 22.sp,
                    height: 1.12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5.h),
                ...List<Widget>.generate(
                  _currentQuestion.choices.length,
                      (index) => Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: SizedBox(
                      width: 60.w,
                      height: 58,
                      child: OutlinedButton(
                        onPressed: _stage == _TriviaStage.question
                            ? () => _answerQuestion(index)
                            : null,
                        // WidgetStatePropertyAll applies these feedback colors
                        // even when onPressed becomes null (disabled state).
                        style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(0),
                          backgroundColor: WidgetStatePropertyAll(
                            _choiceColor(index),
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            _choiceTextColor(index),
                          ),
                          side: WidgetStatePropertyAll(
                            BorderSide(
                              color: _choiceBorderColor(index),
                              width: 2,
                            ),
                          ),
                          shape: const WidgetStatePropertyAll(StadiumBorder()),
                        ),
                        child: Text(
                          _currentQuestion.choices[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _choiceTextColor(index),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_stage == _TriviaStage.answerReveal) ...[
                  const Text(
                    '',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        _buildStatusBar(),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4B43),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Live',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '462 Views',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        child: Text(
                          'Q${_questionIndex + 1} of ${_questions.length} Questions',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDC38),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Cash Prize',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 3),
                      Text(
                        _cashPrize,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: _isEliminated
                ? const Color(0xFFEF3A3A)
                : const Color(0xFF43A849),
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              _isEliminated ? 'You are eliminated' : "You're still active",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHostAvatar() {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer dotted / sound-wave-inspired circle.
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
          ),

          // Host image.
          Container(
            width: 35.w,
            height: 35.w,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image.asset(
              'assets/png/avatar.png',
              fit: BoxFit.cover,
            ),
          ),

          // A subtle live/mic indicator. Remove this if you have an animated
          // audio-wave package or a custom waveform asset to place here.
          Positioned(
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFFF4035),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHostTalkingView() {
    const hostName = 'David';
    const viewerCount = '233 Views';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
             SizedBox(height: 5.h),

            // Replace with Image.asset if ChemShaa is an image logo.
             Text(
              'ChemShaa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'serif',
              ),
            ),

            SizedBox(height: 10.h),

            _buildHostAvatar(),

            SizedBox(height: 2.h),

            Text(
              'Host: $hostName',
              style:  TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
              ),
            ),

            const Spacer(flex: 3),

            _buildStatusBar(),
          ],
        ),
      ),
    );
  }
  Widget _buildNextQuestionLoadingView() {
    final nextQuestionNumber = _questionIndex + 2;

    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.15,
            colors: [
              Color(0xFF242424),
              Color(0xFF0B0B0B),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Subtle ambient glow behind the main loader.
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFDC38).withValues(alpha: 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFDC38).withValues(alpha: 0.10),
                      blurRadius: 80,
                      spreadRadius: 24,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4438),
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4438).withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fiber_manual_record_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Text(
                          'Question $nextQuestionNumber of ${_questions.length}',
                          style: const TextStyle(
                            color: Color(0xFFE3E3E3),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF151515),
                      border: Border.all(
                        color: const Color(0xFFFFDC38).withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 114,
                          height: 114,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: Color(0xFFFFDC38),
                            backgroundColor: Color(0xFF343434),
                          ),
                        ),
                        Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFDC38),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.quiz_rounded,
                            color: Colors.black,
                            size: 34,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  const Text(
                    'Next question is loading',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Get ready for question $nextQuestionNumber.\\nThe next round begins shortly.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFC7C7C7),
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF43A849),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Stay ready — answer quickly to remain active.',
                            style: TextStyle(
                              color: Color(0xFFE8E8E8),
                              fontSize: 14,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFinishedView() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isEliminated
                ? Icons.sentiment_neutral_rounded
                : Icons.emoji_events_rounded,
            size: 70,
            color: _isEliminated
                ? const Color(0xFF666666)
                : const Color(0xFFFFC107),
          ),
          const SizedBox(height: 20),
          Text(
            _isEliminated ? 'Trivia complete' : 'Congratulations!',
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            _isEliminated
                ? 'Thanks for playing. You completed all ${_questions.length} questions.'
                : 'You answered all questions correctly!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, height: 1.4),
          ),
          const SizedBox(height: 28),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF41AF4B),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4B43),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
