import 'package:json_annotation/json_annotation.dart';

part 'lesson.g.dart';

enum MathOperator { add, subtract, multiply, divide }

@JsonSerializable()
class Lesson {
  final String id;
  final String title;
  final String description;
  final String classroomId;
  final MathOperator operator;
  final int difficulty;
  final List<String> exerciseIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.classroomId,
    required this.operator,
    required this.difficulty,
    this.exerciseIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  Map<String, dynamic> toJson() => _$LessonToJson(this);

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? classroomId,
    MathOperator? operator,
    int? difficulty,
    List<String>? exerciseIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      classroomId: classroomId ?? this.classroomId,
      operator: operator ?? this.operator,
      difficulty: difficulty ?? this.difficulty,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
