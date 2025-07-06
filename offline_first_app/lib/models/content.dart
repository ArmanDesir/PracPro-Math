import 'package:json_annotation/json_annotation.dart';

part 'content.g.dart';

enum ContentType { lesson, quiz, exercise }

@JsonSerializable()
class Content {
  final String id;
  final String classroomId;
  final String title;
  final String description;
  final ContentType type;
  final String? fileUrl;
  final String? fileName;
  final int fileSize;
  final DateTime createdAt;
  final DateTime updatedAt;

  Content({
    required this.id,
    required this.classroomId,
    required this.title,
    required this.description,
    required this.type,
    this.fileUrl,
    this.fileName,
    required this.fileSize,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Content.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);
  Map<String, dynamic> toJson() => _$ContentToJson(this);

  Content copyWith({
    String? id,
    String? classroomId,
    String? title,
    String? description,
    ContentType? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Content(
      id: id ?? this.id,
      classroomId: classroomId ?? this.classroomId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
