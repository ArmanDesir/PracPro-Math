// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  classroomId: json['classroomId'] as String,
  operator: $enumDecode(_$MathOperatorEnumMap, json['operator']),
  difficulty: (json['difficulty'] as num).toInt(),
  exerciseIds:
      (json['exerciseIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'classroomId': instance.classroomId,
  'operator': _$MathOperatorEnumMap[instance.operator]!,
  'difficulty': instance.difficulty,
  'exerciseIds': instance.exerciseIds,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isActive': instance.isActive,
};

const _$MathOperatorEnumMap = {
  MathOperator.add: 'add',
  MathOperator.subtract: 'subtract',
  MathOperator.multiply: 'multiply',
  MathOperator.divide: 'divide',
};
