// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
  id: json['id'] as String,
  classroomId: json['classroomId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$ContentTypeEnumMap, json['type']),
  fileUrl: json['fileUrl'] as String?,
  fileName: json['fileName'] as String?,
  fileSize: (json['fileSize'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
  'id': instance.id,
  'classroomId': instance.classroomId,
  'title': instance.title,
  'description': instance.description,
  'type': _$ContentTypeEnumMap[instance.type]!,
  'fileUrl': instance.fileUrl,
  'fileName': instance.fileName,
  'fileSize': instance.fileSize,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$ContentTypeEnumMap = {
  ContentType.lesson: 'lesson',
  ContentType.quiz: 'quiz',
  ContentType.exercise: 'exercise',
};
