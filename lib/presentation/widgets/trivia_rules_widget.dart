import 'package:chemshaa_app/presentation/widgets/style_widget.dart';
import 'package:flutter/material.dart';

class TriviaRulesWidget extends StatelessWidget {
  const TriviaRulesWidget();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Color(0xFF101010),
      fontSize: 13.5,
      height: 1.37,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Live Trivia Show Rules:',
            style: TextStyle(
              color: Color(0xFF101010),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 13),
        const NumberedRule(
          number: '1.',
          text:
          'Answer 10 multiple-choice questions correctly during the live trivia show to win cash prizes deposited directly into your mobile money account. Please note: the cash prize is divided equally among all winners.',
          style: textStyle,
        ),
        const SizedBox(height: 13),
        const NumberedRule(
          number: '2.',
          text:
          "You're eliminated if you answer incorrectly, skip questions, or don't answer at all.",
          style: textStyle,
        ),
        const SizedBox(height: 20),
        const Text(
          'Eliminated? No worries—you can still earn points for correct answers. Stay tuned; something extra sweet is coming soon.',
          style: TextStyle(
            color: Color(0xFF101010),
            fontSize: 13.5,
            height: 1.37,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 13),
        Center(
          child: TextButton(
            onPressed: () {
              // Replace with navigation to your feedback page or external URL.
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: const Color(0xFF101010),
            ),
            child: const Text(
              'Share your feedback on our app',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}