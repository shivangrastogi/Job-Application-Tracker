import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../core/constants/enums.dart';
import '../models/captured_email.dart';
import 'firebase_service.dart';

// ── Sync range enum ────────────────────────────────────────────────

enum GmailSyncRange {
  week('Last 7 days', 7),
  month('Last 30 days', 30),
  threeMonths('Last 3 months', 90),
  sixMonths('Last 6 months', 180),
  year('Last 1 year', 365),
  allTime('All time', null),
  custom('Custom range', -1);

  const GmailSyncRange(this.label, this.days);
  final String label;
  final int? days;

  bool get isCustom => days == -1;
  bool get isAllTime => days == null;

  DateTime? get defaultSince {
    if (days == null || days! < 0) return null;
    return DateTime.now().subtract(Duration(days: days!));
  }
}

// ── Gmail service ──────────────────────────────────────────────────

class GmailService {
  static const _base = 'https://gmail.googleapis.com/gmail/v1/users/me';
  static const _scope = 'https://www.googleapis.com/auth/gmail.readonly';

  // Separate GoogleSignIn instance that declares the gmail scope upfront.
  // This is necessary on Android: account.authentication.accessToken only
  // includes scopes from the GoogleSignIn constructor — requestScopes() alone
  // doesn't cause the token to be re-issued with new scopes.
  static final _gmailGsi = GoogleSignIn(scopes: [_scope]);

  static Future<bool> hasAccess() async {
    try {
      // Try silent sign-in first — succeeds if user previously authorized
      final account = await _gmailGsi.signInSilently();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestAccess() async {
    try {
      final account = await _gmailGsi.signIn();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _token() async {
    try {
      var account = _gmailGsi.currentUser;
      account ??= await _gmailGsi.signInSilently();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.accessToken;
    } catch (_) {
      return null;
    }
  }

  static String _buildQuery(DateTime? since, DateTime? until) {
    final domains = [
      'naukri.com', 'linkedin.com', 'indeed.com', 'shine.com',
      'glassdoor.com', 'unstop.com', 'internshala.com', 'cutshort.io',
      'hirist.tech', 'monsterindia.com', 'foundit.in', 'wellfound.com',
      'naukrigulf.com', 'apnatime.in',
    ];
    final domainQ = domains.map((d) => 'from:$d').join(' OR ');

    final subjectKeywords = [
      'shortlisted', '"interview invitation"', '"job offer"', '"offer letter"',
      '"thank you for applying"', '"application received"', '"not selected"',
      'rejected', '"regret to inform"', '"selected for"', '"next round"',
      '"resume viewed"', '"profile viewed"', '"application shortlisted"',
      '"congratulations"', '"we regret"',
    ];
    final subjectQ = subjectKeywords.map((k) => 'subject:$k').join(' OR ');

    var q = '(($domainQ) OR ($subjectQ)) -from:me';

    if (since != null) {
      final d = '${since.year}/${_pad(since.month)}/${_pad(since.day)}';
      q += ' after:$d';
    }
    if (until != null) {
      final d = '${until.year}/${_pad(until.month)}/${_pad(until.day)}';
      q += ' before:$d';
    }
    return q;
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  // ── Fetch ──────────────────────────────────────────────────────

  static Future<List<CapturedEmail>> fetchEmails({
    DateTime? since,
    DateTime? until,
    void Function(int fetched, int total)? onProgress,
  }) async {
    final token = await _token();
    if (token == null) throw Exception('Not signed in');

    final headers = {'Authorization': 'Bearer $token'};
    final q = _buildQuery(since, until);

    // 1. Collect message IDs across pages
    final ids = <String>[];
    String? pageToken;
    do {
      final params = <String, String>{'q': q, 'maxResults': '500'};
      if (pageToken != null) params['pageToken'] = pageToken;
      final url = Uri.https('gmail.googleapis.com',
          '/gmail/v1/users/me/messages', params);
      final resp = await http.get(url, headers: headers);
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        throw Exception('Gmail access denied. Tap "Grant Access" to authorize.');
      }
      if (resp.statusCode != 200) break;
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final msgs =
          (body['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      ids.addAll(msgs.map((m) => m['id'] as String));
      pageToken = body['nextPageToken'] as String?;
    } while (pageToken != null && ids.length < 2000);

    if (ids.isEmpty) return [];
    onProgress?.call(0, ids.length);

    // 2. Fetch metadata in parallel batches of 15
    final emails = <CapturedEmail>[];
    const batchSize = 15;
    for (var i = 0; i < ids.length; i += batchSize) {
      final batch = ids.sublist(i, (i + batchSize).clamp(0, ids.length));
      final futures = batch.map((id) => _fetchOne(id, token));
      final results = await Future.wait(futures);
      emails.addAll(results.whereType<CapturedEmail>());
      onProgress?.call(emails.length, ids.length);
    }

    return emails;
  }

  static Future<CapturedEmail?> _fetchOne(String id, String token) async {
    try {
      final url = Uri.parse(
        'https://gmail.googleapis.com/gmail/v1/users/me/messages/$id'
        '?format=metadata'
        '&metadataHeaders=From'
        '&metadataHeaders=Subject'
        '&metadataHeaders=Date',
      );
      final resp = await http.get(
          url, headers: {'Authorization': 'Bearer $token'});
      if (resp.statusCode != 200) return null;
      return _parseMsg(jsonDecode(resp.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static CapturedEmail? _parseMsg(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final tid = json['threadId'] as String?;
    if (id == null || tid == null) return null;

    final snippet = (json['snippet'] as String? ?? '').replaceAll('&#39;', "'");
    final ms = int.tryParse(json['internalDate'] as String? ?? '0') ?? 0;
    final date = ms > 0
        ? DateTime.fromMillisecondsSinceEpoch(ms)
        : DateTime.now();

    final hdrs = ((json['payload'] as Map?)?['headers'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    String? from, subject;
    for (final h in hdrs) {
      switch ((h['name'] as String?)?.toLowerCase()) {
        case 'from':
          from = h['value'] as String?;
        case 'subject':
          subject = h['value'] as String?;
      }
    }

    String fromEmail = '';
    String? fromName;
    if (from != null) {
      final m = RegExp(r'^(.*?)\s*<([^>]+)>$').firstMatch(from.trim());
      if (m != null) {
        fromName = m.group(1)?.trim().replaceAll('"', '');
        fromEmail = m.group(2)!.trim();
      } else {
        fromEmail = from.trim();
      }
    }

    return CapturedEmail(
      id: id,
      threadId: tid,
      fromName: fromName?.isNotEmpty == true ? fromName : null,
      fromEmail: fromEmail,
      subject: subject,
      snippet: snippet,
      date: date,
    );
  }

  // ── Parser ─────────────────────────────────────────────────────

  static const _sourceMap = {
    'naukri.com': 'Naukri',
    'linkedin.com': 'LinkedIn',
    'indeed.com': 'Indeed',
    'shine.com': 'Shine',
    'glassdoor.com': 'Glassdoor',
    'unstop.com': 'Unstop',
    'internshala.com': 'Internshala',
    'cutshort.io': 'Cutshort',
    'hirist.tech': 'Hirist',
    'monsterindia.com': 'Monster India',
    'foundit.in': 'Foundit',
    'wellfound.com': 'Wellfound',
    'naukrigulf.com': 'NaukriGulf',
    'apnatime.in': 'Apna',
  };

  static String sourceFor(String email) {
    final domain = email.split('@').last.toLowerCase();
    for (final e in _sourceMap.entries) {
      if (domain.contains(e.key)) return e.value;
    }
    return 'Email';
  }

  static EmailParseResult parse(CapturedEmail email) {
    final sub = (email.subject ?? '').toLowerCase();
    final snip = email.snippet.toLowerCase();
    final text = '$sub $snip';
    final src = sourceFor(email.fromEmail);

    bool has(List<String> kws) => kws.any(text.contains);

    ApplicationStatus? status;
    String desc = src != 'Email' ? 'Email from $src' : 'Job-related email';

    if (has(['shortlist', 'shortlisted', 'selected for next', 'congratulat',
        'moving forward', 'next round', 'advance to', 'progressed'])) {
      status = ApplicationStatus.phoneScreen;
      desc = 'Shortlisted — advancing to next stage';
    } else if (has(['interview', 'interview invitation', 'invit.*interview',
        'schedule.*interview', 'discussion with', 'virtual interview',
        'online interview', 'telephonic'])) {
      status = ApplicationStatus.technicalRound;
      desc = 'Interview invitation received';
    } else if (has(['offer letter', 'formal offer', 'pleased to offer',
        'extend an offer', 'job offer', 'offer of employment'])) {
      status = ApplicationStatus.offerReceived;
      desc = 'Job offer received';
    } else if (has(['regret', 'not selected', 'not moving forward',
        'unfortunately', 'other candidates', 'not proceed', 'rejected',
        'we regret', 'unable to move'])) {
      status = ApplicationStatus.rejected;
      desc = 'Application not selected';
    } else if (has(['application received', 'thank you for apply',
        'received your application', 'acknowledge', 'successfully applied',
        'application submitted'])) {
      status = ApplicationStatus.applied;
      desc = 'Application acknowledged';
    } else if (has(['resume viewed', 'profile viewed', 'recruiter viewed',
        'your profile has been'])) {
      desc = 'Resume / profile viewed';
    } else if (has(['follow up', 'following up', 'update on your application',
        'regarding your application'])) {
      desc = 'Application follow-up';
    }

    // Try to extract company name from subject
    String? company;
    final compMatch = RegExp(
      r'(?:at|from|for|with|by)\s+([A-Z][A-Za-z0-9\s&.]+?)(?:\s+-|\s+for|\.|,|$)',
    ).firstMatch(email.subject ?? '');
    if (compMatch != null) {
      company = compMatch.group(1)?.trim();
    }

    final isJobRelated = status != null ||
        src != 'Email' ||
        has(['job', 'application', 'interview', 'offer', 'position',
            'opportunity', 'career', 'recruit', 'hiring', 'vacancy']);

    return EmailParseResult(
      company: company,
      suggestedStatus: status,
      description: desc,
      sourceLabel: src,
      isJobRelated: isJobRelated,
    );
  }
}
