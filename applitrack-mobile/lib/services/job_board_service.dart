import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/enums.dart';
import '../models/career_job.dart';
import '../models/company.dart';

/// Thrown when a company's openings cannot be fetched, with a human-readable
/// reason the UI can show.
class JobBoardException implements Exception {
  final String message;
  JobBoardException(this.message);
  @override
  String toString() => message;
}

/// Result of inferring a provider from a pasted careers URL.
class UrlDetection {
  final AtsProvider provider;
  final String? slug;
  final Map<String, String> config;
  UrlDetection(this.provider, {this.slug, this.config = const {}});
}

/// Fetches and normalises live job openings from public ATS job-board APIs.
///
/// Every supported provider exposes an unauthenticated JSON endpoint that works
/// from a mobile HTTP client (no CORS, no backend). We map each provider's shape
/// into a common [CareerJob].
class JobBoardService {
  static final _client = http.Client();
  static const _timeout = Duration(seconds: 20);

  static Future<List<CareerJob>> fetchJobs(Company company) async {
    if (!company.provider.fetchable) {
      throw JobBoardException(
          '${company.name} uses a custom careers page — open it in the browser.');
    }

    // Amazon & Workday use config rather than a single slug.
    switch (company.provider) {
      case AtsProvider.amazon:
        return _amazon(company);
      case AtsProvider.workday:
        return _workday(company);
      default:
        break;
    }

    final slug = company.slug?.trim();
    if (slug == null || slug.isEmpty) {
      throw JobBoardException('No ${company.provider.label} slug set for ${company.name}.');
    }

    switch (company.provider) {
      case AtsProvider.greenhouse:
        return _greenhouse(company, slug);
      case AtsProvider.lever:
        return _lever(company, slug);
      case AtsProvider.ashby:
        return _ashby(company, slug);
      case AtsProvider.smartrecruiters:
        return _smartrecruiters(company, slug);
      case AtsProvider.workable:
        return _workable(company, slug);
      case AtsProvider.recruitee:
        return _recruitee(company, slug);
      case AtsProvider.amazon:
      case AtsProvider.workday:
      case AtsProvider.custom:
        throw JobBoardException('Cannot fetch ${company.provider.label}.');
    }
  }

  static Future<dynamic> _getJson(String url) async {
    http.Response res;
    try {
      res = await _client
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(_timeout);
    } catch (e) {
      throw JobBoardException('Network error — check your connection.');
    }
    if (res.statusCode == 404) {
      throw JobBoardException('Company not found — double-check the slug.');
    }
    if (res.statusCode >= 400) {
      throw JobBoardException('Job board returned error ${res.statusCode}.');
    }
    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw JobBoardException('Unexpected response from job board.');
    }
  }

  // --- Greenhouse -----------------------------------------------------------
  // https://boards-api.greenhouse.io/v1/boards/{token}/jobs?content=true
  static Future<List<CareerJob>> _greenhouse(Company c, String slug) async {
    final data = await _getJson(
        'https://boards-api.greenhouse.io/v1/boards/$slug/jobs?content=true');
    final jobs = (data['jobs'] as List?) ?? const [];
    return jobs.map((j) {
      final m = j as Map<String, dynamic>;
      final depts = (m['departments'] as List?) ?? const [];
      final dept = depts.isNotEmpty ? depts.first['name'] as String? : null;
      final loc = (m['location'] as Map?)?['name'] as String?;
      return CareerJob(
        id: 'gh_${m['id']}',
        companyId: c.id,
        companyName: c.name,
        title: (m['title'] as String?)?.trim() ?? 'Untitled',
        location: loc,
        department: dept,
        workType: _inferWorkType(loc),
        url: m['absolute_url'] as String?,
        postedAt: _parseDate(m['updated_at']),
      );
    }).toList();
  }

  // --- Lever ----------------------------------------------------------------
  // https://api.lever.co/v0/postings/{company}?mode=json
  static Future<List<CareerJob>> _lever(Company c, String slug) async {
    final data = await _getJson('https://api.lever.co/v0/postings/$slug?mode=json');
    final jobs = (data as List?) ?? const [];
    return jobs.map((j) {
      final m = j as Map<String, dynamic>;
      final cat = (m['categories'] as Map?) ?? const {};
      final loc = cat['location'] as String?;
      final commitment = cat['commitment'] as String?;
      final workplace = m['workplaceType'] as String?;
      return CareerJob(
        id: 'lv_${m['id']}',
        companyId: c.id,
        companyName: c.name,
        title: (m['text'] as String?)?.trim() ?? 'Untitled',
        location: loc,
        department: cat['team'] as String? ?? cat['department'] as String?,
        employmentType: commitment,
        workType: _inferWorkType(workplace ?? loc),
        url: m['hostedUrl'] as String?,
        postedAt: _parseEpoch(m['createdAt']),
      );
    }).toList();
  }

  // --- Ashby ----------------------------------------------------------------
  // https://api.ashbyhq.com/posting-api/job-board/{org}
  static Future<List<CareerJob>> _ashby(Company c, String slug) async {
    final data = await _getJson(
        'https://api.ashbyhq.com/posting-api/job-board/$slug?includeCompensation=false');
    final jobs = (data['jobs'] as List?) ?? const [];
    return jobs.map((j) {
      final m = j as Map<String, dynamic>;
      final loc = m['location'] as String?;
      final isRemote = m['isRemote'] == true;
      return CareerJob(
        id: 'as_${m['id']}',
        companyId: c.id,
        companyName: c.name,
        title: (m['title'] as String?)?.trim() ?? 'Untitled',
        location: loc,
        department: m['department'] as String? ?? m['team'] as String?,
        employmentType: m['employmentType'] as String?,
        workType: isRemote ? CareerWorkType.remote : _inferWorkType(loc),
        url: m['jobUrl'] as String? ?? m['applyUrl'] as String?,
        postedAt: _parseDate(m['publishedAt'] ?? m['publishedDate']),
      );
    }).toList();
  }

  // --- SmartRecruiters ------------------------------------------------------
  // https://api.smartrecruiters.com/v1/companies/{company}/postings
  static Future<List<CareerJob>> _smartrecruiters(Company c, String slug) async {
    final data = await _getJson(
        'https://api.smartrecruiters.com/v1/companies/$slug/postings?limit=100');
    final jobs = (data['content'] as List?) ?? const [];
    return jobs.map((j) {
      final m = j as Map<String, dynamic>;
      final loc = m['location'] as Map?;
      final city = loc?['city'] as String?;
      final country = loc?['country'] as String?;
      final remote = loc?['remote'] == true;
      final locText = [city, country].where((s) => s != null && s.isNotEmpty).join(', ');
      final id = m['id'];
      return CareerJob(
        id: 'sr_$id',
        companyId: c.id,
        companyName: c.name,
        title: (m['name'] as String?)?.trim() ?? 'Untitled',
        location: locText.isEmpty ? null : locText,
        department: (m['department'] as Map?)?['label'] as String?,
        employmentType: (m['typeOfEmployment'] as Map?)?['label'] as String?,
        workType: remote ? CareerWorkType.remote : _inferWorkType(locText),
        url: 'https://jobs.smartrecruiters.com/$slug/$id',
        postedAt: _parseDate(m['releasedDate']),
      );
    }).toList();
  }

  // --- Workable -------------------------------------------------------------
  // https://apply.workable.com/api/v1/widget/accounts/{subdomain}?details=true
  static Future<List<CareerJob>> _workable(Company c, String slug) async {
    final data = await _getJson(
        'https://apply.workable.com/api/v1/widget/accounts/$slug?details=true');
    final jobs = (data['jobs'] as List?) ?? const [];
    return jobs.map((j) {
      final m = j as Map<String, dynamic>;
      final city = m['city'] as String?;
      final country = m['country'] as String?;
      final locText = [city, country].where((s) => s != null && s.isNotEmpty).join(', ');
      final remote = m['telecommuting'] == true || m['remote'] == true;
      return CareerJob(
        id: 'wk_${m['shortcode'] ?? m['id']}',
        companyId: c.id,
        companyName: c.name,
        title: (m['title'] as String?)?.trim() ?? 'Untitled',
        location: locText.isEmpty ? null : locText,
        department: m['department'] as String?,
        employmentType: m['employment_type'] as String?,
        workType: remote ? CareerWorkType.remote : _inferWorkType(locText),
        url: m['url'] as String? ?? m['application_url'] as String?,
        postedAt: _parseDate(m['published_on'] ?? m['created_at']),
      );
    }).toList();
  }

  // --- Recruitee ------------------------------------------------------------
  // https://{subdomain}.recruitee.com/api/offers/
  static Future<List<CareerJob>> _recruitee(Company c, String slug) async {
    final data = await _getJson('https://$slug.recruitee.com/api/offers/');
    final jobs = (data['offers'] as List?) ?? const [];
    return jobs.map((j) {
      final m = j as Map<String, dynamic>;
      final loc = m['location'] as String? ?? m['city'] as String?;
      final remote = m['remote'] == true;
      return CareerJob(
        id: 'rc_${m['id']}',
        companyId: c.id,
        companyName: c.name,
        title: (m['title'] as String?)?.trim() ?? 'Untitled',
        location: loc,
        department: m['department'] as String?,
        employmentType: m['employment_type_code'] as String?,
        workType: remote ? CareerWorkType.remote : _inferWorkType(loc),
        url: m['careers_url'] as String? ?? m['careers_apply_url'] as String?,
        postedAt: _parseDate(m['published_at']),
      );
    }).toList();
  }

  // --- Amazon (amazon.jobs) -------------------------------------------------
  // https://www.amazon.jobs/en/search.json?loc_query=India&country=IND&category[]=software-development
  static Future<List<CareerJob>> _amazon(Company c) async {
    final cfg = c.config;
    final loc = cfg['loc_query'] ?? 'India';
    final country = cfg['country'] ?? 'IND';
    final query = cfg['query'] ?? '';
    final category = cfg['category']; // e.g. software-development
    final params = <String>[
      'loc_query=${Uri.encodeComponent(loc)}',
      'country=${Uri.encodeComponent(country)}',
      'result_limit=100',
      'sort=recent',
      if (query.isNotEmpty) 'base_query=${Uri.encodeComponent(query)}',
      if (category != null && category.isNotEmpty)
        'category[]=${Uri.encodeComponent(category)}',
    ];
    final data =
        await _getJson('https://www.amazon.jobs/en/search.json?${params.join('&')}');
    final jobs = (data['jobs'] as List?) ?? const [];
    return jobs.map((j) {
      final m = j as Map<String, dynamic>;
      final path = m['job_path'] as String?;
      return CareerJob(
        id: 'az_${m['id_icims'] ?? m['id']}',
        companyId: c.id,
        companyName: c.name,
        title: (m['title'] as String?)?.trim() ?? 'Untitled',
        location: m['normalized_location'] as String? ??
            [m['city'], m['state']].where((s) => s != null).join(', '),
        department: m['job_category'] as String? ?? m['business_category'] as String?,
        employmentType: m['job_schedule_type'] as String?,
        workType: _inferWorkType(m['normalized_location'] as String?),
        url: path == null ? null : 'https://www.amazon.jobs$path',
        postedAt: _parseDate(m['updated_time']) ?? _parseAmazonDate(m['posted_date']),
      );
    }).toList();
  }

  // --- Workday (generic tenant) ---------------------------------------------
  // POST https://{tenant}.{dc}.myworkdayjobs.com/wday/cxs/{tenant}/{site}/jobs
  static Future<List<CareerJob>> _workday(Company c) async {
    final cfg = c.config;
    final tenant = cfg['tenant'];
    final dc = cfg['dc'];
    final site = cfg['site'];
    if (tenant == null || dc == null || site == null) {
      throw JobBoardException(
          'Workday needs tenant, data-center and site — re-paste the careers URL.');
    }
    final base = 'https://$tenant.$dc.myworkdayjobs.com';
    final api = '$base/wday/cxs/$tenant/$site/jobs';
    final search = cfg['query'] ?? '';
    final all = <CareerJob>[];
    // Workday caps page size at 20; pull up to 5 pages.
    for (var offset = 0; offset < 100; offset += 20) {
      final data = await _postJson(api, {
        'appliedFacets': <String, dynamic>{},
        'limit': 20,
        'offset': offset,
        'searchText': search,
      });
      final postings = (data['jobPostings'] as List?) ?? const [];
      if (postings.isEmpty) break;
      for (final p in postings) {
        final m = p as Map<String, dynamic>;
        final ext = m['externalPath'] as String?;
        all.add(CareerJob(
          id: 'wd_${m['bulletFields'] is List && (m['bulletFields'] as List).isNotEmpty ? (m['bulletFields'] as List).first : ext}',
          companyId: c.id,
          companyName: c.name,
          title: (m['title'] as String?)?.trim() ?? 'Untitled',
          location: m['locationsText'] as String?,
          workType: _inferWorkType(m['locationsText'] as String?),
          url: ext == null ? null : '$base$ext',
          postedAt: null, // Workday only gives relative text ("Posted 6 Days Ago")
        ));
      }
      if (postings.length < 20) break;
    }
    return all;
  }

  /// Inspects a pasted careers URL and returns the provider + slug/config we can
  /// fetch with. Returns null when nothing matched (caller should treat as
  /// custom / open-in-browser).
  static UrlDetection? detectFromUrl(String raw) {
    final url = raw.trim();
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();

    // Greenhouse: boards.greenhouse.io/{token} or job-boards.greenhouse.io/{token}
    if (host.contains('greenhouse.io') && segs.isNotEmpty) {
      return UrlDetection(AtsProvider.greenhouse, slug: segs.first);
    }
    // Lever: jobs.lever.co/{company}
    if (host.contains('lever.co') && segs.isNotEmpty) {
      return UrlDetection(AtsProvider.lever, slug: segs.first);
    }
    // Ashby: jobs.ashbyhq.com/{org}
    if (host.contains('ashbyhq.com') && segs.isNotEmpty) {
      return UrlDetection(AtsProvider.ashby, slug: segs.first);
    }
    // SmartRecruiters: careers.smartrecruiters.com/{company}
    if (host.contains('smartrecruiters.com') && segs.isNotEmpty) {
      return UrlDetection(AtsProvider.smartrecruiters, slug: segs.first);
    }
    // Workable: {company}.workable.com or apply.workable.com/{company}
    if (host.endsWith('workable.com')) {
      final sub = host.split('.').first;
      if (sub != 'apply' && sub != 'www') {
        return UrlDetection(AtsProvider.workable, slug: sub);
      }
      if (segs.isNotEmpty) return UrlDetection(AtsProvider.workable, slug: segs.first);
    }
    // Recruitee: {company}.recruitee.com
    if (host.endsWith('recruitee.com')) {
      return UrlDetection(AtsProvider.recruitee, slug: host.split('.').first);
    }
    // Amazon: amazon.jobs
    if (host.contains('amazon.jobs')) {
      final q = uri.queryParameters;
      return UrlDetection(AtsProvider.amazon, config: {
        'loc_query': q['loc_query'] ?? 'India',
        'country': q['country'] ?? 'IND',
        if ((q['base_query'] ?? '').isNotEmpty) 'query': q['base_query']!,
      });
    }
    // Workday: {tenant}.{dc}.myworkdayjobs.com/.../{site}
    if (host.contains('myworkdayjobs.com')) {
      final parts = host.split('.');
      // parts: [tenant, dc, myworkdayjobs, com]
      if (parts.length >= 2) {
        final tenant = parts[0];
        final dc = parts[1];
        // Site is the last meaningful path segment that isn't a locale or "job".
        String? site;
        for (final s in segs) {
          if (s.length == 5 && s.contains('-')) continue; // locale like en-US
          if (s.toLowerCase() == 'job' || s.toLowerCase() == 'jobs') continue;
          site = s;
          break;
        }
        if (site != null) {
          return UrlDetection(AtsProvider.workday,
              config: {'tenant': tenant, 'dc': dc, 'site': site});
        }
      }
    }
    return null;
  }

  // --- Helpers --------------------------------------------------------------
  static Future<dynamic> _postJson(String url, Map<String, dynamic> body) async {
    http.Response res;
    try {
      res = await _client
          .post(Uri.parse(url),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body))
          .timeout(_timeout);
    } catch (e) {
      throw JobBoardException('Network error — check your connection.');
    }
    if (res.statusCode == 404) {
      throw JobBoardException('Company not found — double-check the URL.');
    }
    if (res.statusCode >= 400) {
      throw JobBoardException('Job board returned error ${res.statusCode}.');
    }
    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw JobBoardException('Unexpected response from job board.');
    }
  }

  static DateTime? _parseAmazonDate(dynamic v) {
    // Amazon posted_date looks like "June 13, 2026".
    if (v is! String || v.isEmpty) return null;
    const months = {
      'january': 1, 'february': 2, 'march': 3, 'april': 4, 'may': 5,
      'june': 6, 'july': 7, 'august': 8, 'september': 9, 'october': 10,
      'november': 11, 'december': 12,
    };
    final m = RegExp(r'(\w+)\s+(\d+),\s+(\d+)').firstMatch(v);
    if (m == null) return null;
    final month = months[m.group(1)!.toLowerCase()];
    if (month == null) return null;
    return DateTime(
        int.parse(m.group(3)!), month, int.parse(m.group(2)!));
  }

  static CareerWorkType _inferWorkType(String? text) {
    if (text == null) return CareerWorkType.unknown;
    final t = text.toLowerCase();
    if (t.contains('remote')) return CareerWorkType.remote;
    if (t.contains('hybrid')) return CareerWorkType.hybrid;
    if (t.contains('on-site') || t.contains('onsite') || t.contains('office')) {
      return CareerWorkType.onsite;
    }
    return CareerWorkType.unknown;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    if (v is int) return _parseEpoch(v);
    return null;
  }

  static DateTime? _parseEpoch(dynamic v) {
    if (v is int) {
      // Lever uses milliseconds.
      final ms = v > 100000000000 ? v : v * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return null;
  }
}
