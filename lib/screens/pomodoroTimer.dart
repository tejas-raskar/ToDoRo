import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  static const maxSeconds = 25 * 60;
  int time = maxSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(seconds: maxSeconds), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  void resetTimer() => setState(() => time = maxSeconds);

  void startTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time > 0) {
        setState(() {
          time--;
        });
      } else {
        stopTimer(reset: false);
      }
    });
  }

  void stopTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }
    setState(() {
      timer?.cancel();
    });
  }

  Widget buildButtons() {
    bool isRunning = timer == null ? false : timer!.isActive;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FilledButton(
          child: isRunning
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.pause_rounded,
                    size: 34,
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 34,
                  ),
                ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (isRunning) {
              stopTimer(reset: false);
              _controller.stop();
            } else {
              startTimer(reset: false);
              _controller.forward();
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.restart_alt_rounded),
          onPressed: () {
            HapticFeedback.mediumImpact();
            stopTimer();
            _controller.reset();
          },
        ),
      ],
    );
  }

  String formatTime(int timeInSeconds) {
    int minutes = timeInSeconds ~/ 60;
    int seconds = timeInSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.help_outline_rounded),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  RichText(
                                    textAlign: TextAlign.left,
                                    text: const TextSpan(
                                        text: 'What is Pomodoro Technique?',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            fontFamily: 'Ubuntu')),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  RichText(
                                    textAlign: TextAlign.left,
                                    text: const TextSpan(
                                        text:
                                            'The Pomodoro Technique is a time management method developed by Francesco Cirillo in the late 1980s.\n',
                                        style: TextStyle(fontSize: 17,fontFamily: 'Ubuntu')),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  RichText(
                                    textAlign: TextAlign.left,
                                    text: const TextSpan(
                                        text:
                                            'The technique uses a timer to break down work into intervals, traditionally 25 minutes in length, separated by short breaks.\n',
                                        style: TextStyle(fontSize: 17,fontFamily: 'Ubuntu')),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                ),
              )
            ],
            title: const Text(
              "Pomodoro",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 360,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(
                            child: Text(
                              formatTime(time),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 40),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(58.0),
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white30,
                              value: _animation.value,
                              strokeWidth: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: buildButtons(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
