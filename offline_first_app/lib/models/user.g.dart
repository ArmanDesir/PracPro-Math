// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  photoUrl: json['photoUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isOnline: json['isOnline'] as bool? ?? false,
  lastSyncTime: json['lastSyncTime'] as String?,
  userType: $enumDecode(_$UserTypeEnumMap, json['userType']),
  teacherCode: json['teacherCode'] as String?,
  classroomIds:
      (json['classroomIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  classroomId: json['classroomId'] as String?,
  grade: (json['grade'] as num?)?.toInt(),
  teacherId: json['teacherId'] as String?,
  contactNumber: json['contactNumber'] as String?,
  studentId: json['studentId'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'photoUrl': instance.photoUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isOnline': instance.isOnline,
  'lastSyncTime': instance.lastSyncTime,
  'userType': _$UserTypeEnumMap[instance.userType]!,
  'teacherCode': instance.teacherCode,
  'classroomIds': instance.classroomIds,
  'classroomId': instance.classroomId,
  'grade': instance.grade,
  'teacherId': instance.teacherId,
  'contactNumber': instance.contactNumber,
  'studentId': instance.studentId,
};

const _$UserTypeEnumMap = {
  UserType.student: 'student',
  UserType.teacher: 'teacher',
};
