// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Contact _$ContactFromJson(Map<String, dynamic> json) => _Contact(
  id: json['id'] as String,
  applicationId: json['applicationId'] as String,
  name: json['name'] as String,
  title: json['title'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  linkedinUrl: json['linkedinUrl'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ContactToJson(_Contact instance) => <String, dynamic>{
  'id': instance.id,
  'applicationId': instance.applicationId,
  'name': instance.name,
  'title': instance.title,
  'email': instance.email,
  'phone': instance.phone,
  'linkedinUrl': instance.linkedinUrl,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
};
