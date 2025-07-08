import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'widgets/game_button.dart';
import 'game_theme.dart';

class NinjaMathGameScreen extends StatefulWidget {
  final String difficulty;
  const NinjaMathGameScreen({super.key, required this.difficulty});

  @override
  State<NinjaMathGameScreen> createState() => _NinjaMathGameScreenState();
}

class _NinjaMathGameScreenState extends State<NinjaMathGameScreen> {
  late int _remainingSeconds;
  late Timer _timer;
  bool _gameFinished = false;
  int _score = 0;
  int _current = 0;
  late List<_TargetRound> _rounds;
  List<int> _selected = [];
  int _totalRounds = 10;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _setTimer();
    _rounds = _generateRounds();
    _startTimer();
  }

  void _setTimer() {
    if (widget.difficulty == 'Easy') {
      _remainingSeconds = 300;
    } else if (widget.difficulty == 'Medium') {
      _remainingSeconds = 420;
    } else {
      _remainingSeconds = 600;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _finishGame();
      }
    });
  }

  List<_TargetRound> _generateRounds() {
    int max = 10;
    if (widget.difficulty == 'Medium') max = 20;
    if (widget.difficulty == 'Hard') max = 50;
    List<_TargetRound> list = [];
    for (int i = 0; i < _totalRounds; i++) {
      // Generate 4-5 random numbers, pick a random subset as the solution
      int numCount = 4 + _random.nextInt(2); // 4 or 5
      List<int> numbers = List.generate(
        numCount,
        (_) => 1 + _random.nextInt(max),
      );
      numbers.shuffle();
      int solutionCount =
          2 + _random.nextInt(numCount - 1); // at least 2 numbers
      List<int> solution = numbers.sublist(0, solutionCount);
      int target = solution.reduce((a, b) => a + b);
      list.add(_TargetRound(target: target, numbers: numbers));
    }
    return list;
  }

  void _finishGame() {
    _timer.cancel();
    setState(() {
      _gameFinished = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Game Over!'),
            content: Text(
              'Your score: $_score/$_totalRounds\nTime left: ${_formatTime(_remainingSeconds)}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _toggleSelect(int n) {
    setState(() {
      if (_selected.contains(n)) {
        _selected.remove(n);
      } else {
        _selected.add(n);
      }
    });
  }

  void _submit() {
    final round = _rounds[_current];
    int sum = _selected.fold(0, (a, b) => a + b);
    if (sum == round.target) {
      _score++;
    }
    if (_current < _totalRounds - 1) {
      setState(() {
        _current++;
        _selected.clear();
      });
    } else {
      _finishGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_gameFinished) return const SizedBox.shrink();
    final round = _rounds[_current];
    return Scaffold(
      backgroundColor: GameTheme.background,
      appBar: AppBar(
        title: Text(
          'Ninja Math (${widget.difficulty})',
          style: GameTheme.tileText,
        ),
        backgroundColor: GameTheme.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: GameTheme.tileText.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMascot(),
            const SizedBox(height: 12),
            _buildTarget(round.target),
            const SizedBox(height: 16),
            Text(
              'Current sum: ${_selected.fold(0, (a, b) => a + b)}',
              style: GameTheme.tileText,
            ),
            const SizedBox(height: 32),
            _buildNumberBank(round.numbers),
            const SizedBox(height: 32),
            GameButton(
              text: 'Submit',
              onTap: _selected.isNotEmpty ? _submit : () {},
              color: _selected.isNotEmpty ? GameTheme.primary : GameTheme.tile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascot() {
    // Placeholder ninja mascot area for hints/feedback
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: GameTheme.mascot,
          radius: 28,
          child: Icon(Icons.sports_martial_arts, color: Colors.white, size: 36),
        ),
        const SizedBox(width: 12),
        Text('Be a Math Ninja!', style: GameTheme.mascotText),
      ],
    );
  }

  Widget _buildTarget(int target) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: GameTheme.accent,
        borderRadius: BorderRadius.circular(GameTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Target: $target',
        style: GameTheme.bigNumber.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildNumberBank(List<int> numbers) {
    return Wrap(
      spacing: 16,
      children:
          numbers
              .map(
                (n) => GestureDetector(
                  onTap: () => _toggleSelect(n),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          _selected.contains(n)
                              ? GameTheme.correct
                              : GameTheme.tileBank,
                      borderRadius: BorderRadius.circular(
                        GameTheme.borderRadius,
                      ),
                      border: Border.all(color: GameTheme.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$n',
                      style: GameTheme.tileText.copyWith(color: Colors.black),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _TargetRound {
  final int target;
  final List<int> numbers;
  _TargetRound({required this.target, required this.numbers});
}
