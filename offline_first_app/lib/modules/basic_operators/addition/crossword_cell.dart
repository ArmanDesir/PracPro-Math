enum CellType { number, operator, equals, blank, empty, answer }

class CrosswordCell {
  String? value; // Now nullable and mutable
  final CellType type;
  int? answer;
  bool isDraggable;
  bool isCorrect;

  CrosswordCell({
    this.value,
    required this.type,
    this.answer,
    this.isDraggable = false,
    this.isCorrect = false,
  });
}
