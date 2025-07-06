import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _selected = -1;
  int _score = 0;
  int _current = 0;
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is 2 + 3?',
      'options': ['4', '5', '6', '7'],
      'answer': 1,
    },
    {
      'question': 'What is 1 + 6?',
      'options': ['5', '6', '7', '8'],
      'answer': 2,
    },
    {
      'question': 'What is 4 + 4?',
      'options': ['6', '7', '8', '9'],
      'answer': 2,
    },
  ];

  void _next() {
    if (_selected == _questions[_current]['answer']) _score++;
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = -1;
      });
    } else {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Quiz Complete!'),
              content: Text('Your score: \\$_score/\\${_questions.length}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_current];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addition Quiz'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question \\${_current + 1} of \\${_questions.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              q['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              q['options'].length,
              (i) => Card(
                color: _selected == i ? Colors.orangeAccent : Colors.white,
                child: ListTile(
                  title: Text(q['options'][i]),
                  onTap: () => setState(() => _selected = i),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selected == -1 ? null : _next,
              child: Text(
                _current == _questions.length - 1 ? 'Finish' : 'Next',
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
