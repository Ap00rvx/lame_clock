import 'package:flutter/material.dart';
import 'dart:async';
import '../models/math_problem.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';

class MathChallengeDialog extends StatefulWidget {
  final VoidCallback? onSuccess;
  final int? alarmId;

  const MathChallengeDialog({super.key, this.onSuccess, this.alarmId});

  @override
  State<MathChallengeDialog> createState() => _MathChallengeDialogState();
}

class _MathChallengeDialogState extends State<MathChallengeDialog>
    with TickerProviderStateMixin {
  late MathProblem _currentProblem;
  final TextEditingController _answerController = TextEditingController();
  int _attempts = 0;
  int _problemsSolved = 0;
  final int _requiredProblems = 3; // Number of problems to solve
  Timer? _alarmTimer;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
    _startAlarmSound();

    // Setup shake animation for wrong answers
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    _alarmTimer?.cancel();
    _shakeController.dispose();
    AudioService.stopAlarmSound();
    super.dispose();
  }

  void _generateNewProblem() {
    setState(() {
      _currentProblem = MathProblem.generate();
      _answerController.clear();
      _attempts = 0;
    });
  }

  void _startAlarmSound() {
    // Start playing alarm sound and vibrating
    AudioService.playAlarmSound();

    // Set up a timer to keep the alarm going
    _alarmTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        AudioService.playAlarmSound();
      } else {
        timer.cancel();
      }
    });
  }

  void _checkAnswer() {
    final userAnswer = int.tryParse(_answerController.text);

    if (userAnswer == null) {
      _showWrongAnswerFeedback('Please enter a valid number');
      return;
    }

    if (_currentProblem.isCorrectAnswer(userAnswer)) {
      setState(() {
        _problemsSolved++;
      });

      if (_problemsSolved >= _requiredProblems) {
        _onAllProblemsCompleted();
      } else {
        _showCorrectAnswerFeedback();
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _generateNewProblem();
          }
        });
      }
    } else {
      _showWrongAnswerFeedback('Wrong answer! Try again.');
    }
  }

  void _showCorrectAnswerFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Correct! ${_requiredProblems - _problemsSolved} more to go.',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showWrongAnswerFeedback(String message) {
    setState(() {
      _attempts++;
    });

    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    _answerController.clear();
  }

  void _onAllProblemsCompleted() {
    // Stop alarm sound and cancel notifications
    AudioService.stopAlarmSound();
    _alarmTimer?.cancel();

    if (widget.alarmId != null) {
      NotificationService.cancelNotification(widget.alarmId!);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Great job! Alarm turned off.'),
        backgroundColor: Colors.green,
      ),
    );

    // Call success callback
    widget.onSuccess?.call();

    // Close dialog
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing by back button
      child: AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Icon(Icons.alarm, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Solve to Stop Alarm!'),
          ],
        ),
        content: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: _problemsSolved / _requiredProblems,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Problem $_problemsSolved/$_requiredProblems',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Math problem
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentProblem.problemText,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Answer input
                  TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Your Answer',
                      border: const OutlineInputBorder(),
                      errorText: _attempts > 2
                          ? 'Hint: The answer is ${_currentProblem.correctAnswer}'
                          : null,
                    ),
                    onSubmitted: (_) => _checkAnswer(),
                    autofocus: true,
                  ),

                  if (_attempts > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Attempts: $_attempts',
                      style: TextStyle(color: Colors.red[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: _checkAnswer, child: const Text('Submit')),
          if (_attempts > 5)
            TextButton(
              onPressed: _generateNewProblem,
              child: const Text('New Problem'),
            ),
        ],
      ),
    );
  }
}
