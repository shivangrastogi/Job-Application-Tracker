enum ApplicationStatus {
  wishlist,
  applied,
  phoneScreen,
  technicalRound,
  onsiteInterview,
  offerReceived,
  accepted,
  rejected,
  withdrawn,
  ghosted;

  String get label {
    switch (this) {
      case wishlist: return 'Wishlist';
      case applied: return 'Applied';
      case phoneScreen: return 'Phone Screen';
      case technicalRound: return 'Technical';
      case onsiteInterview: return 'Onsite';
      case offerReceived: return 'Offer Received';
      case accepted: return 'Accepted';
      case rejected: return 'Rejected';
      case withdrawn: return 'Withdrawn';
      case ghosted: return 'Ghosted';
    }
  }

  bool get isActive => !isClosed;

  bool get isClosed => const {
    ApplicationStatus.accepted,
    ApplicationStatus.rejected,
    ApplicationStatus.withdrawn,
    ApplicationStatus.ghosted,
  }.contains(this);

  int get pipelineOrder {
    switch (this) {
      case wishlist: return 0;
      case applied: return 1;
      case phoneScreen: return 2;
      case technicalRound: return 3;
      case onsiteInterview: return 4;
      case offerReceived: return 5;
      case accepted: return 6;
      case rejected: return 7;
      case withdrawn: return 8;
      case ghosted: return 9;
    }
  }
}

enum WorkType {
  remote,
  hybrid,
  onsite;

  String get label {
    switch (this) {
      case remote: return 'Remote';
      case hybrid: return 'Hybrid';
      case onsite: return 'Onsite';
    }
  }
}

enum JobSource {
  linkedin,
  naukri,
  indeed,
  company,
  referral,
  other;

  String get label {
    switch (this) {
      case linkedin: return 'LinkedIn';
      case naukri: return 'Naukri';
      case indeed: return 'Indeed';
      case company: return 'Company Website';
      case referral: return 'Referral';
      case other: return 'Other';
    }
  }
}

enum InterviewType {
  phone,
  technical,
  behavioral,
  systemDesign,
  takeHome,
  hr,
  final_;

  String get label {
    switch (this) {
      case phone: return 'Phone';
      case technical: return 'Technical';
      case behavioral: return 'Behavioral';
      case systemDesign: return 'System Design';
      case takeHome: return 'Take-Home';
      case hr: return 'HR';
      case final_: return 'Final';
    }
  }
}

enum InterviewOutcome { passed, failed, pending, noFeedback }

enum DocumentType {
  resume,
  coverLetter,
  portfolio,
  other;

  String get label {
    switch (this) {
      case resume: return 'Resume';
      case coverLetter: return 'Cover Letter';
      case portfolio: return 'Portfolio';
      case other: return 'Other';
    }
  }
}

enum TimelineEventType {
  statusChange,
  note,
  interviewScheduled,
  offerReceived,
  rejection,
  emailDetected,
  notificationDetected,
  manual;
}

/// Applicant-tracking platforms whose public job-board JSON APIs we can read
/// directly from the device (no auth, no backend). `custom` means we only
/// have a careers URL to open in the browser — nothing to fetch (used for
/// portals like Google/Adobe that render jobs via brittle SSR blobs).
enum AtsProvider {
  greenhouse,
  lever,
  ashby,
  smartrecruiters,
  workable,
  recruitee,
  amazon,
  workday,
  custom;

  String get label {
    switch (this) {
      case greenhouse: return 'Greenhouse';
      case lever: return 'Lever';
      case ashby: return 'Ashby';
      case smartrecruiters: return 'SmartRecruiters';
      case workable: return 'Workable';
      case recruitee: return 'Recruitee';
      case amazon: return 'Amazon Jobs';
      case workday: return 'Workday';
      case custom: return 'Open link (no sync)';
    }
  }

  /// Whether this provider supports live job fetching.
  bool get fetchable => this != AtsProvider.custom;

  /// Hint shown under the slug field so the user knows what to type.
  String get slugHint {
    switch (this) {
      case greenhouse:
        return 'Board token, e.g. "stripe" from boards.greenhouse.io/stripe';
      case lever:
        return 'Company slug, e.g. "netflix" from jobs.lever.co/netflix';
      case ashby:
        return 'Org slug, e.g. "openai" from jobs.ashbyhq.com/openai';
      case smartrecruiters:
        return 'Company id, e.g. "Square" from careers.smartrecruiters.com/Square';
      case workable:
        return 'Subdomain, e.g. "acme" from acme.workable.com';
      case recruitee:
        return 'Subdomain, e.g. "acme" from acme.recruitee.com';
      case amazon:
        return 'No slug needed — set location & keyword below';
      case workday:
        return 'Paste the Workday careers URL above and we fill this in';
      case custom:
        return 'No live jobs — we just open the careers page';
    }
  }
}

/// Buckets used to group companies on the Companies screen and in the catalog.
enum CompanyCategory {
  bigTech,
  productSaas,
  fintech,
  indianIt,
  unicorn,
  semiconductorHardware,
  consultingGcc,
  other;

  String get label {
    switch (this) {
      case bigTech: return 'Big Tech (FAANG+)';
      case productSaas: return 'Product / SaaS';
      case fintech: return 'Fintech & Payments';
      case indianIt: return 'Indian IT Services';
      case unicorn: return 'Unicorns & Startups';
      case semiconductorHardware: return 'Semiconductor & Hardware';
      case consultingGcc: return 'Consulting & GCCs';
      case other: return 'Other';
    }
  }
}

/// Normalised work arrangement for fetched career jobs.
enum CareerWorkType {
  remote,
  hybrid,
  onsite,
  unknown;

  String get label {
    switch (this) {
      case remote: return 'Remote';
      case hybrid: return 'Hybrid';
      case onsite: return 'Onsite';
      case unknown: return 'Other';
    }
  }
}

enum GoalPeriod {
  daily,
  weekly,
  monthly;

  String get label {
    switch (this) {
      case daily: return 'Daily';
      case weekly: return 'Weekly';
      case monthly: return 'Monthly';
    }
  }

  String get unit {
    switch (this) {
      case daily: return 'today';
      case weekly: return 'this week';
      case monthly: return 'this month';
    }
  }
}

/// Where a referral request comes from.
enum ReferralSourceType {
  googleForm,
  group,
  linkedin,
  person;

  String get label {
    switch (this) {
      case googleForm: return 'Google Form';
      case group: return 'WhatsApp / Telegram';
      case linkedin: return 'LinkedIn';
      case person: return 'Employee referral';
    }
  }

  /// Whether opening this source means filling a form (enables prefill).
  bool get isForm => this == ReferralSourceType.googleForm;
}

/// Pipeline for an individual referral request.
enum ReferralStatus {
  requested,
  referred,
  applied,
  rejected,
  noResponse;

  String get label {
    switch (this) {
      case requested: return 'Requested';
      case referred: return 'Referred';
      case applied: return 'Applied';
      case rejected: return 'Rejected';
      case noResponse: return 'No Response';
    }
  }

  bool get isClosed =>
      this == ReferralStatus.rejected || this == ReferralStatus.noResponse;

  int get order {
    switch (this) {
      case requested: return 0;
      case referred: return 1;
      case applied: return 2;
      case rejected: return 3;
      case noResponse: return 4;
    }
  }
}

enum GoalMetric {
  /// Any application logged in the app (createdAt within the window).
  applicationsAdded,
  /// Applications actually submitted (appliedDate within the window).
  applicationsApplied,
  /// Interviews scheduled within the window.
  interviews;

  String get label {
    switch (this) {
      case applicationsAdded: return 'Applications logged';
      case applicationsApplied: return 'Applications submitted';
      case interviews: return 'Interviews';
    }
  }

  String get shortLabel {
    switch (this) {
      case applicationsAdded: return 'logged';
      case applicationsApplied: return 'applied';
      case interviews: return 'interviews';
    }
  }
}
