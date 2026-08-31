import 'package:chemshaa_app/presentation/widgets/style_widget.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TriviaRulesWidget extends StatelessWidget {
  const TriviaRulesWidget();

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      color: Color(0xFF101010),
      //fontSize: 13.5,
      fontSize: 16.sp,
      height: 1.37,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Center(
          child: Text(
            'Live Trivia Show Rules:',
            style: TextStyle(
              color: Color(0xFF101010),
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 13),
         NumberedRule(
          number: '1.',
          text:
          'Answer 10 multiple-choice questions correctly during the live trivia show to win cash prizes deposited directly into your mobile money account. Please note: the cash prize is divided equally among all winners.',
          style: textStyle,
        ),
        const SizedBox(height: 13),
         NumberedRule(
          number: '2.',
          text:
          "You're eliminated if you answer incorrectly, skip questions, or don't answer at all.",
          style: textStyle,
        ),
        const SizedBox(height: 20),
         Text(
          'Eliminated? No worries—you can still earn points for correct answers. Stay tuned; something extra sweet is coming soon.',
          style: TextStyle(
            color: Color(0xFF101010),
            fontSize: 15.sp,
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
            child:  Text(
              'Share your feedback on our app',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}