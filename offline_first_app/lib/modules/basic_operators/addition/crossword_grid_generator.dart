// utils/crossword_grid_generator.dart
import 'crossword_cell.dart';

class CrosswordGridGenerator {
  static List<List<CrosswordCell>> getGrid(String difficulty) {
    if (difficulty.toLowerCase() == 'easy') {
      return _easyGrid();
    }
    // Return empty 5x5 if no match
    return List.generate(
      5,
      (_) => List.generate(
        5,
        (_) => CrosswordCell(value: '', type: CellType.empty),
      ),
    );
  }

  static List<List<CrosswordCell>> _easyGrid() {
    return [
      [
        CrosswordCell(value: '3', type: CellType.number),
        CrosswordCell(value: '+', type: CellType.operator),
        CrosswordCell(value: '4', type: CellType.number),
        CrosswordCell(value: '+', type: CellType.operator),
        CrosswordCell(value: '8', type: CellType.answer),
      ],
      [
        CrosswordCell(value: '+', type: CellType.operator),
        CrosswordCell(value: '', type: CellType.blank, answer: 5),
        CrosswordCell(value: '+', type: CellType.operator),
        CrosswordCell(value: '', type: CellType.blank, answer: 3),
        CrosswordCell(value: '10', type: CellType.answer),
      ],
      [
        CrosswordCell(value: '1', type: CellType.number),
        CrosswordCell(value: '+', type: CellType.operator),
        CrosswordCell(value: '6', type: CellType.number),
        CrosswordCell(value: '+', type: CellType.operator),
        CrosswordCell(value: '9', type: CellType.answer),
      ],
      [
        CrosswordCell(value: '=', type: CellType.equals),
        CrosswordCell(value: '=', type: CellType.equals),
        CrosswordCell(value: '=', type: CellType.equals),
        CrosswordCell(value: '=', type: CellType.equals),
        CrosswordCell(value: '=', type: CellType.equals),
      ],
      [
        CrosswordCell(value: '4', type: CellType.answer),
        CrosswordCell(value: '', type: CellType.blank, answer: 6),
        CrosswordCell(value: '', type: CellType.blank, answer: 3),
        CrosswordCell(value: '', type: CellType.blank, answer: 6),
        CrosswordCell(value: '13', type: CellType.answer),
      ],
    ];
  }
}
