import 'dart:async';

import 'package:cleanhouse/components/RoomTask.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

class CleaningDetailPage extends StatefulWidget {
  // In the constructor, require a roomRask.
  const CleaningDetailPage({super.key, required this.room_task});

  // Declare a field that holds the Todo.
  final RoomTask room_task;

  @override
  State<CleaningDetailPage> createState() => _CleaningDetailPageState();
}

extension StringCasingExtension on String {
  String get toCapitalized =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String get toTitleCase => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized)
      .join(' ');
}

class _CleaningDetailPageState extends State<CleaningDetailPage> {
  bool? isRealTask = false;
  bool? isClean = false;
  bool? isNeedToClean = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(widget.room_task.task_name.toTitleCase,
              style: TextStyle(fontSize: 40)),
          SizedBox(width: 200.0, height: 20.0),
          Text(widget.room_task.room_name.toTitleCase,
              style: TextStyle(fontSize: 30)),
          SizedBox(width: 200.0, height: 100.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Is this a real task?", style: TextStyle(fontSize: 15)),
              Checkbox(
                  value: isRealTask,
                  onChanged: (bool? value) {
                    setState(() {
                      isRealTask = value;
                    });
                  }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Mark as clean?", style: TextStyle(fontSize: 15)),
              Checkbox(
                  value: isClean,
                  onChanged: (bool? value) {
                    setState(() {
                      isClean = value;
                    });
                    Navigator.pop(context, {
                      'is_clean': true
                    });
                  }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Mark as need to clean?", style: TextStyle(fontSize: 15)),
              Checkbox(
                  value: isNeedToClean,
                  onChanged: (bool? value) {
                    setState(() {
                      isNeedToClean = value;
                    });
                    Navigator.pop(context, {
                      'is_needs_clean': true
                    });
                  }),
            ],
          ),
          SizedBox(
            width: 200.0,
            height: 200.0,
            child: MyStopwatch(isRealTask),
          )
        ],
      )),
    );
  }
}

class MyStopwatch extends StatefulWidget {
  late bool? _isRealTaskSet;
  bool _is_buttons_visible = true;

  MyStopwatch(bool? isRealTaskSet) {
    this._isRealTaskSet = isRealTaskSet;
  }

  @override
  State<MyStopwatch> createState() => _MyStopwatchState();
}

class _MyStopwatchState extends State<MyStopwatch> {
  final Stopwatch _stopwatch = Stopwatch();
  late Duration _elapsedTime;
  late String _elapsedTimeString;
  late Timer timer;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

// initialize confettiController
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    _elapsedTime = Duration.zero;
    _elapsedTimeString = _formatElapsedTime(_elapsedTime);

    // Create a timer that runs a callback every 100 milliseconds to update UI
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        // Update elapsed time only if the stopwatch is running
        if (_stopwatch.isRunning) {
          _updateElapsedTime();
        }
      });
    });
  }

  // Start/Stop button callback
  Future<void> _startOrStopStopwatch() async {
    if (!_stopwatch.isRunning) {
      // Start the stopwatch and update elapsed time
      _stopwatch.start();
      KeepScreenOn.turnOn();
      _updateElapsedTime();
    } else {
      // Stop the stopwatch
      _stopwatch.stop();
      KeepScreenOn.turnOff();
      widget._is_buttons_visible = false;
      _confettiController.play();
      await Future.delayed(const Duration(seconds: 3));
      final Map response = {
        'duration_ms': _elapsedTime.inMilliseconds,
        'is_real': widget._isRealTaskSet
      };
      Navigator.pop(context, response);
    }
  }


  // // Reset button callback
  // void _resetStopwatch() {
  //   // Reset the stopwatch to zero and update elapsed time
  //   _stopwatch.reset();
  //   _updateElapsedTime();
  // }

  void _pauseStopwatch() {
    _stopwatch.stop();
  }

  // void _cancelStopwatch() {
  //   Navigator.pop(context, 0);
  // }

  // Update elapsed time and formatted time string
  void _updateElapsedTime() {
    setState(() {
      _elapsedTime = _stopwatch.elapsed;
      _elapsedTimeString = _formatElapsedTime(_elapsedTime);
    });
  }

  // Format a Duration into a string (MM:SS.SS)
  String _formatElapsedTime(Duration time) {
    return '${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(time.inMilliseconds % 1000 ~/ 100).toString()}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 40,
                  minBlastForce: 5,
                  emissionFrequency: 0.1,
                  numberOfParticles: 20,
                  gravity: 0, // particles will pop-up
                )),

            // Display elapsed time
            Visibility(
                visible: widget._is_buttons_visible,
                child: Text(
                  _elapsedTimeString,
                  style: const TextStyle(fontSize: 40.0),
                )),

            const SizedBox(height: 30.0),

            // Start/Stop and Reset buttons
            Visibility(
              visible: widget._is_buttons_visible,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _startOrStopStopwatch,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            _stopwatch.isRunning ? Colors.blue : Colors.green)),
                    child: _stopwatch.isRunning
                        ? Icon(Icons.stop, size: 40, color: Colors.black)
                        : Icon(Icons.play_arrow, size: 40, color: Colors.black),
                  ),
                  const SizedBox(width: 20.0),
                  ElevatedButton(
                    onPressed: _pauseStopwatch,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>((Colors.grey))),
                    child:
                        const Icon(Icons.pause, size: 40, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
