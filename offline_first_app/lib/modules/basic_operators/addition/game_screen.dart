import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addition Games'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GameCard(
              title: 'Crossword Math',
              icon: Icons.grid_on,
              onSelect: (difficulty) {
                // TODO: Navigate to Crossword game with difficulty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Crossword Math - $difficulty')),
                );
              },
            ),
            const SizedBox(height: 24),
            _GameCard(
              title: 'Ninja Math',
              icon: Icons.sports_martial_arts,
              onSelect: (difficulty) {
                // TODO: Navigate to Ninja Math game with difficulty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ninja Math - $difficulty')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function(String difficulty) onSelect;
  const _GameCard({
    required this.title,
    required this.icon,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 36, color: Colors.purple),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Choose difficulty:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DifficultyButton(label: 'Easy', onTap: () => onSelect('Easy')),
                _DifficultyButton(
                  label: 'Medium',
                  onTap: () => onSelect('Medium'),
                ),
                _DifficultyButton(label: 'Hard', onTap: () => onSelect('Hard')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DifficultyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}
