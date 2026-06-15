import '../../models/job_application.dart';

/// Friendly labels for applications captured link-first, before company/role
/// have been filled in. Falls back to the job link's host so cards never render
/// blank.
extension JobApplicationDisplay on JobApplication {
  String get displayCompany {
    if (company.trim().isNotEmpty) return company;
    final host = Uri.tryParse(jobUrl ?? '')?.host ?? '';
    final clean = host.replaceFirst('www.', '');
    return clean.isNotEmpty ? clean : 'Untitled job';
  }

  String get displayRole =>
      role.trim().isNotEmpty ? role : 'Tap to add details';
}
