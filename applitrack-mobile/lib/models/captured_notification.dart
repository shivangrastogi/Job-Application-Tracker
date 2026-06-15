import '../core/constants/enums.dart';

class CapturedNotification {
  final String id;
  final String packageName;
  final String appName;
  final String? title;
  final String? body;
  final DateTime receivedAt;
  final bool imported;

  const CapturedNotification({
    required this.id,
    required this.packageName,
    required this.appName,
    this.title,
    this.body,
    required this.receivedAt,
    this.imported = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'packageName': packageName,
        'appName': appName,
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
        'imported': imported,
      };

  factory CapturedNotification.fromJson(Map<String, dynamic> json) =>
      CapturedNotification(
        id: json['id'] as String,
        packageName: json['packageName'] as String,
        appName: json['appName'] as String,
        title: json['title'] as String?,
        body: json['body'] as String?,
        receivedAt: DateTime.parse(json['receivedAt'] as String),
        imported: json['imported'] as bool? ?? false,
      );

  CapturedNotification copyWith({bool? imported}) => CapturedNotification(
        id: id,
        packageName: packageName,
        appName: appName,
        title: title,
        body: body,
        receivedAt: receivedAt,
        imported: imported ?? this.imported,
      );
}

// Parsed result from a notification
class NotificationParseResult {
  final String? company;
  final String? role;
  final ApplicationStatus? suggestedStatus;
  final String description;
  final String sourceLabel; // "Naukri", "LinkedIn", etc.
  final bool isJobRelated;

  const NotificationParseResult({
    this.company,
    this.role,
    this.suggestedStatus,
    required this.description,
    required this.sourceLabel,
    required this.isJobRelated,
  });
}
