import 'package:cloud_firestore/cloud_firestore.dart';

class Classroom {
  final String id;
  final String name;
  final String teacherId;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> studentIds;
  final List<String> pendingStudentIds;
  final List<String> lessonIds;
  final List<String> quizIds;
  final String? code;
  final bool isActive;
  final String? firebaseId;
  final bool isSynced;

  Classroom({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.studentIds = const [],
    this.pendingStudentIds = const [],
    this.lessonIds = const [],
    this.quizIds = const [],
    this.code,
    this.isActive = true,
    this.firebaseId,
    this.isSynced = false,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        throw Exception('Invalid date format for Classroom');
      }
    }

    return Classroom(
      id: json['id'] as String,
      name: json['name'] as String,
      teacherId: json['teacherId'] as String,
      description: json['description'] as String,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      studentIds:
          (json['studentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      pendingStudentIds:
          (json['pendingStudentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lessonIds:
          (json['lessonIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      quizIds:
          (json['quizIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      code: json['code'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      firebaseId: json['firebaseId'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'teacherId': teacherId,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'studentIds': studentIds,
    'pendingStudentIds': pendingStudentIds,
    'lessonIds': lessonIds,
    'quizIds': quizIds,
    'code': code,
    'isActive': isActive,
    'firebaseId': firebaseId,
    'isSynced': isSynced,
  };

  Classroom copyWith({
    String? id,
    String? name,
    String? teacherId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? studentIds,
    List<String>? pendingStudentIds,
    List<String>? lessonIds,
    List<String>? quizIds,
    String? code,
    bool? isActive,
    String? firebaseId,
    bool? isSynced,
  }) {
    return Classroom(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentIds: studentIds ?? this.studentIds,
      pendingStudentIds: pendingStudentIds ?? this.pendingStudentIds,
      lessonIds: lessonIds ?? this.lessonIds,
      quizIds: quizIds ?? this.quizIds,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
      firebaseId: firebaseId ?? this.firebaseId,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
