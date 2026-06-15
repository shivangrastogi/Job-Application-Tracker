import '../core/constants/enums.dart';
import '../models/captured_notification.dart';

// Known job-platform package names
const _knownPackages = {
  'com.naukri.android': 'Naukri',
  'com.linkedin.android': 'LinkedIn',
  'com.indeed.android.jobsearch': 'Indeed',
  'com.shine.android': 'Shine',
  'com.glassdoor.app': 'Glassdoor',
  'com.monster.monsterJobs': 'Monster',
  'com.unstop.unstopapp': 'Unstop',
  'com.internshala.app': 'Internshala',
  'com.freshersworld.jobs': 'FreshersWorld',
};

class NotificationParser {
  static String? appNameFor(String packageName) => _knownPackages[packageName];

  static bool isJobApp(String packageName) =>
      _knownPackages.containsKey(packageName);

  static NotificationParseResult parse(CapturedNotification n) {
    final title = (n.title ?? '').toLowerCase();
    final body = (n.body ?? '').toLowerCase();
    final combined = '$title $body';
    final source = n.appName;

    // ── Naukri-specific patterns ──────────────────────────
    if (n.packageName == 'com.naukri.android') {
      // "Recruiter wants you to call! For your applied role at COMPANY"
      final recruiterMatch = RegExp(
              r'for your applied role at (.+?)(?:\s*$)',
              caseSensitive: false)
          .firstMatch(n.body ?? '');
      if (recruiterMatch != null) {
        final company = _toTitleCase(recruiterMatch.group(1)?.trim() ?? '');
        return NotificationParseResult(
          company: company,
          suggestedStatus: ApplicationStatus.phoneScreen,
          description: 'Recruiter contacted you about role at $company',
          sourceLabel: source,
          isJobRelated: true,
        );
      }

      // "Status of your application has changed / resume viewed"
      if (combined.contains('resume') && combined.contains('view')) {
        final company = _extractCompanyFromBody(n.body ?? '');
        return NotificationParseResult(
          company: company,
          description: 'Resume viewed${company != null ? ' at $company' : ''}',
          sourceLabel: source,
          isJobRelated: true,
        );
      }

      // "Shortlisted" / "Congratulations"
      if (combined.contains('shortlist') || combined.contains('congratulat')) {
        final company = _extractCompanyFromBody(n.body ?? '');
        return NotificationParseResult(
          company: company,
          suggestedStatus: ApplicationStatus.phoneScreen,
          description: 'Shortlisted${company != null ? ' at $company' : ''}',
          sourceLabel: source,
          isJobRelated: true,
        );
      }

      // "Not selected" / "Rejected"
      if (combined.contains('not selected') ||
          combined.contains('not moving forward') ||
          combined.contains('rejected')) {
        final company = _extractCompanyFromBody(n.body ?? '');
        return NotificationParseResult(
          company: company,
          suggestedStatus: ApplicationStatus.rejected,
          description: 'Application rejected${company != null ? ' at $company' : ''}',
          sourceLabel: source,
          isJobRelated: true,
        );
      }

      // "Offer"
      if (combined.contains('offer')) {
        final company = _extractCompanyFromBody(n.body ?? '');
        return NotificationParseResult(
          company: company,
          suggestedStatus: ApplicationStatus.offerReceived,
          description: 'Offer received${company != null ? ' from $company' : ''}',
          sourceLabel: source,
          isJobRelated: true,
        );
      }

      // "Interview" scheduled
      if (combined.contains('interview')) {
        final company = _extractCompanyFromBody(n.body ?? '');
        return NotificationParseResult(
          company: company,
          suggestedStatus: ApplicationStatus.technicalRound,
          description: 'Interview update${company != null ? ' at $company' : ''}',
          sourceLabel: source,
          isJobRelated: true,
        );
      }

      // Status changed (generic)
      if (title.contains('status') && title.contains('changed')) {
        return NotificationParseResult(
          description: n.body ?? 'Application status updated',
          sourceLabel: source,
          isJobRelated: true,
        );
      }
    }

    // ── LinkedIn patterns ─────────────────────────────────
    if (n.packageName == 'com.linkedin.android') {
      if (combined.contains('application was viewed') ||
          combined.contains('profile was viewed')) {
        return NotificationParseResult(
          description: 'Your LinkedIn profile/application was viewed',
          sourceLabel: source,
          isJobRelated: true,
        );
      }
      if (combined.contains('message') && combined.contains('recruiter')) {
        return NotificationParseResult(
          suggestedStatus: ApplicationStatus.phoneScreen,
          description: 'Recruiter message on LinkedIn',
          sourceLabel: source,
          isJobRelated: true,
        );
      }
      if (combined.contains('congratulat') || combined.contains('offer')) {
        return NotificationParseResult(
          suggestedStatus: ApplicationStatus.offerReceived,
          description: 'LinkedIn: ${n.title ?? 'Application update'}',
          sourceLabel: source,
          isJobRelated: true,
        );
      }
    }

    // ── Indeed patterns ───────────────────────────────────
    if (n.packageName == 'com.indeed.android.jobsearch') {
      if (combined.contains('resume') && combined.contains('view')) {
        return NotificationParseResult(
          description: 'Indeed: Resume viewed',
          sourceLabel: source,
          isJobRelated: true,
        );
      }
      if (combined.contains('interview')) {
        return NotificationParseResult(
          suggestedStatus: ApplicationStatus.technicalRound,
          description: 'Indeed: Interview update',
          sourceLabel: source,
          isJobRelated: true,
        );
      }
    }

    // Generic: any app with "application" keyword
    if (combined.contains('application') &&
        (combined.contains('status') ||
            combined.contains('update') ||
            combined.contains('view') ||
            combined.contains('interview') ||
            combined.contains('offer') ||
            combined.contains('reject'))) {
      return NotificationParseResult(
        description: n.title ?? n.body ?? 'Application update',
        sourceLabel: source,
        isJobRelated: true,
      );
    }

    return NotificationParseResult(
      description: n.title ?? n.body ?? '',
      sourceLabel: source,
      isJobRelated: false,
    );
  }

  static String? _extractCompanyFromBody(String body) {
    // "at COMPANY", "from COMPANY", "for COMPANY"
    final match = RegExp(
      r'(?:at|from|for)\s+([A-Z][A-Za-z0-9\s&.,]+?)(?:\s+(?:for|is|are|has|have|was|to|in|on|and)|[.!?,]|$)',
    ).firstMatch(body);
    if (match != null) {
      final candidate = match.group(1)?.trim();
      if (candidate != null && candidate.length > 1 && candidate.length < 60) {
        return _toTitleCase(candidate);
      }
    }
    return null;
  }

  static String _toTitleCase(String s) {
    return s.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }
}
