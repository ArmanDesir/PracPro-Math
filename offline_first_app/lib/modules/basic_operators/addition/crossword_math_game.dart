import 'package:flutter/material.dart';
import 'package:offline_first_app/modules/basic_operators/addition/crossword_cell.dart';
import 'package:offline_first_app/modules/basic_operators/addition/crossword_grid_generator.dart';

import 'dart:async';
import 'game_theme.dart';

enum CellType { number, operator, equals, blank, empty, star }

class CrosswordMathGameScreen extends StatefulWidget {
  final String difficulty;
  const CrosswordMathGameScreen({super.key, required this.difficulty});

  @override
  State<CrosswordMathGameScreen> createState() =>
      _CrosswordMathGameScreenState();
}

class _CrosswordMathGameScreenState extends State<CrosswordMathGameScreen>
    with TickerProviderStateMixin {
  late int _remainingSeconds;
  late Timer _timer;
  bool _gameFinished = false;
  late List<List<CrosswordCell>> _crosswordGrid;
  late List<int> _numberBank;
  late int _gridSize;
  late List<TextEditingController> _controllers;
  int _correct = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _setDifficulty();
    _setTimer();
    _crosswordGrid = CrosswordGridGenerator.getGrid(
      widget.difficulty.toLowerCase(),
    );
    _setupCrosswordGrid();
    _startTimer();
  }

  void _setDifficulty() {
    if (widget.difficulty == 'Easy') {
      _gridSize = 3;
    } else if (widget.difficulty == 'Medium') {
      _gridSize = 5;
    } else {
      _gridSize = 7;
    }
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
        setState(() => _remainingSeconds--);
      } else {
        _finishGame();
      }
    });
  }

  void _setupCrosswordGrid() {
    _numberBank = [];
    for (var row in _crosswordGrid) {
      for (var cell in row) {
        if (cell.type == CellType.blank && cell.answer != null) {
          _numberBank.add(cell.answer!);
        }
      }
    }
    _numberBank.shuffle();

    _controllers = [];
    for (var row in _crosswordGrid) {
      for (var cell in row) {
        if (cell.type == CellType.blank) {
          _controllers.add(TextEditingController());
        }
      }
    }

    _gameFinished = false;
    _correct = 0;
    _total = _controllers.length;
  }

  void _finishGame() {
    _timer.cancel();
    setState(() => _gameFinished = true);
    int correct = _countCorrectBlanks();
    int total = _totalBlanks();
    _showFeedbackDialog(correct, total);
  }

  int _countCorrectBlanks() {
    int correct = 0;
    for (var row in _crosswordGrid) {
      for (var cell in row) {
        if (cell.type == CellType.blank && cell.value == cell.answer) {
          correct++;
        }
      }
    }
    return correct;
  }

  int _totalBlanks() {
    int total = 0;
    for (var row in _crosswordGrid) {
      for (var cell in row) {
        if (cell.type == CellType.blank) total++;
      }
    }
    return total;
  }

  void _checkAnswers() {
    int idx = 0;
    int correct = 0;
    for (var row in _crosswordGrid) {
      for (var cell in row) {
        if (cell.type == CellType.blank) {
          final text = _controllers[idx].text.trim();
          final value = int.tryParse(text);
          if (value == null && text.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter valid numbers only')),
            );
            return;
          }
          cell.value = value as String?;
          if (value != null && value == cell.answer) {
            correct++;
          }
          idx++;
        }
      }
    }
    setState(() {
      _gameFinished = true;
      _correct = correct;
    });
    _showFeedbackDialog(_correct, _total);
  }

  void _showFeedbackDialog(int correct, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Great Job!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    correct == total ? Icons.emoji_events : Icons.star,
                    color: correct == total ? Colors.amber : Colors.yellow[700],
                    size: 64,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You got $correct out of $total correct!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  correct == total
                      ? 'Amazing! You solved the puzzle!'
                      : 'Keep practicing and try again!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    for (var c in _controllers) {
                      c.clear();
                    }
                    for (var row in _crosswordGrid) {
                      for (var cell in row) {
                        if (cell.type == CellType.blank) {
                          cell.value = null;
                        }
                      }
                    }
                    _setupCrosswordGrid();
                  });
                },
                child: const Text('Try Again'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int blankIdx = 0;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < _crosswordGrid.length; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < _crosswordGrid[i].length; j++)
                    (() {
                      final cell = _crosswordGrid[i][j];
                      switch (cell.type) {
                        case CellType.number:
                          return buildTile(cell.value.toString());
                        case CellType.operator:
                          return buildTile("+");
                        case CellType.equals:
                          return buildTile("=");
                        case CellType.blank:
                          return buildTile(
                            "",
                            isEditable: true,
                            controller: _controllers[blankIdx++],
                          );
                        case CellType.empty:
                        default:
                          return const SizedBox(width: 60, height: 60);
                      }
                    })(),
                ],
              ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                for (var n in _numberBank)
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$n',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkAnswers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Check Answers',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Correct: $_correct / $_total',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTile(
    String text, {
    bool isEditable = false,
    TextEditingController? controller,
  }) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GameTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child:
          isEditable
              ? TextField(
                controller: controller,
                style: GameTheme.tileText,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: InputBorder.none),
              )
              : Text(text, style: GameTheme.tileText),
    );
  }
}

// You must also define CrosswordGridGenerator.getGrid(difficulty) elsewhere
// using the sample structure you already have.
