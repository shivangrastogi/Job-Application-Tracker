import '../core/constants/enums.dart';

class CapturedEmail {
  final String id;
  final String threadId;
  final String? fromName;
  final String fromEmail;
  final String? subject;
  final String snippet;
  final DateTime date;
  final bool imported;

  const CapturedEmail({
    required this.id,
    required this.threadId,
    this.fromName,
    required this.fromEmail,
    this.subject,
    required this.snippet,
    required this.date,
    this.imported = false,
  });

  String get gmailUrl => 'https://mail.google.com/mail/u/0/#all/$threadId';

  String get displaySender => fromName?.isNotEmpty == true ? fromName! : fromEmail;

  CapturedEmail copyWith({bool? imported}) => CapturedEmail(
        id: id,
        threadId: threadId,
        fromName: fromName,
        fromEmail: fromEmail,
        subject: subject,
        snippet: snippet,
        date: date,
        imported: imported ?? this.imported,
      );
}

class EmailParseResult {
  final String? company;
  final ApplicationStatus? suggestedStatus;
  final String description;
  final String sourceLabel;
  final bool isJobRelated;

  const EmailParseResult({
    this.company,
    this.suggestedStatus,
    required this.description,
    required this.sourceLabel,
    required this.isJobRelated,
  });
}
