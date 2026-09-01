import 'dart:async';

import 'package:chemshaa_app/presentation/pages/trivia_question_page.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../widgets/timer_count_down_widget.dart';
import '../widgets/trivia_rules_widget.dart';

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


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color yellow = const Color(0xFFFFDC38);

    return Scaffold(
      backgroundColor: yellow,
      appBar: AppBar(
        toolbarHeight: 5.5.h,
        backgroundColor:yellow,
        centerTitle: true,
        title:    Row(
          children: [
            Expanded(
              flex: 9,
              child: Padding(
                padding:  EdgeInsets.only(left:8.w),
                child: Center(
                  child: Image.asset("assets/png/chemshaa.png",width: 35.w,),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                tooltip: 'More options',
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF101010),
                  size: 25,
                ),
              ),
            )
          ],
        ),

      ),
      body: SafeArea(
        bottom: false,
        child: Container(
          color: yellow,
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
                    child: Column(
                      children: [
                         SizedBox(height: 4.h),
                         Padding(
                           padding:  EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 0),
                           child: Text(
                            "Today's live trivia show is scheduled\nfor\nat 2:00 PM",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF101010),
                              fontSize: 18.sp,
                              height: 1.36,
                              fontWeight: FontWeight.w700,
                            ),
                                                   ),
                         ),
                        SizedBox(height: 5.h),
                        Padding(
                          padding:  EdgeInsets.fromLTRB(5.w, 0, 5.w, 0),
                          child: const TriviaRulesWidget(),
                        ),
                         SizedBox(height: 4.h),

                        Padding(
                          padding:  EdgeInsets.fromLTRB(0, 3.h, 0, 3.h),
                          child: GestureDetector(
                            onTap: ()=>showLiveTriviaPopup(context),
                              child: TimerCountDownWidget()),
                        )
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}





