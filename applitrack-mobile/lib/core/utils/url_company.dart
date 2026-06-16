/// Guess the employer from a job link so link-first capture still gets a
/// company. ATS hosts put the company in the slug; generic career sites in the
/// domain; job boards (LinkedIn/Naukri/…) keep it in the path, so we return ''.
String guessCompanyFromUrl(String? url) {
  if (url == null || url.trim().isEmpty) return '';
  final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
  if (uri == null || uri.host.isEmpty) return '';
  final host = uri.host.replaceFirst(RegExp(r'^www\.'), '');
  final parts = uri.pathSegments.where((s) => s.isNotEmpty).toList();

  // ATS providers where the slug is the company.
  if (host.endsWith('greenhouse.io') && parts.isNotEmpty) return _titleize(parts.first);
  if (host.endsWith('lever.co') && parts.isNotEmpty) return _titleize(parts.first);
  if (host.endsWith('ashbyhq.com') && parts.isNotEmpty) return _titleize(parts.first);
  if (host == 'apply.workable.com' && parts.isNotEmpty) return _titleize(parts.first);
  if (host.endsWith('.workable.com')) return _titleize(host.split('.').first);
  if (host.endsWith('.recruitee.com')) return _titleize(host.split('.').first);
  if (host.contains('smartrecruiters.com') && parts.isNotEmpty) return _titleize(parts.first);
  if (host.contains('myworkdayjobs.com')) return _titleize(host.split('.').first);

  // Job boards: company lives in the path, not the host → can't guess.
  const boards = [
    'linkedin.com', 'naukri.com', 'indeed.com', 'glassdoor.com', 'wellfound.com',
    'instahyre.com', 'monster.com', 'ziprecruiter.com', 'dice.com', 'simplyhired.com',
    'foundit.in', 'shine.com', 'timesjobs.com', 'angel.co',
  ];
  for (final b in boards) {
    if (host == b || host.endsWith('.$b')) return '';
  }

  // Otherwise treat as a company career site: use the second-level domain.
  final segs = host.split('.');
  final second = segs.length >= 2 ? segs[segs.length - 2] : segs.first;
  const ignore = {
    'careers', 'jobs', 'job', 'apply', 'work', 'hire', 'boards',
    'recruiting', 'talent', 'www', 'co',
  };
  if (ignore.contains(second)) return '';
  return _titleize(second);
}

/// Loose check that a string is a usable web link (parses to a host with a dot).
bool looksLikeUrl(String? s) {
  if (s == null || s.trim().isEmpty) return false;
  final uri = Uri.tryParse(s.startsWith('http') ? s : 'https://$s');
  return uri != null && uri.host.contains('.');
}

/// Canonical form of a URL for duplicate comparison: lowercased host+path+query,
/// no fragment, no trailing slash.
String normalizeUrl(String? url) {
  if (url == null || url.trim().isEmpty) return '';
  final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
  if (uri == null || uri.host.isEmpty) {
    return url.trim().toLowerCase().replaceAll(RegExp(r'/+$'), '');
  }
  final query = uri.query.isEmpty ? '' : '?${uri.query}';
  return '${uri.host}${uri.path}$query'
      .toLowerCase()
      .replaceAll(RegExp(r'/+$'), '');
}

String _titleize(String s) => s
    .replaceAll(RegExp(r'[-_]+'), ' ')
    .split(' ')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ')
    .trim();
