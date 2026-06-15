// Mirrors lib/core/constants/enums.dart so web data stays compatible with the
// mobile app (values are stored as these exact string keys).

export const ApplicationStatus = {
  wishlist: { label: 'Wishlist', order: 0, color: '#9E9E9E' },
  applied: { label: 'Applied', order: 1, color: '#3B82F6' },
  phoneScreen: { label: 'Phone Screen', order: 2, color: '#06B6D4' },
  technicalRound: { label: 'Technical', order: 3, color: '#F97316' },
  onsiteInterview: { label: 'Onsite', order: 4, color: '#8B5CF6' },
  offerReceived: { label: 'Offer Received', order: 5, color: '#22C55E' },
  accepted: { label: 'Accepted', order: 6, color: '#10B981' },
  rejected: { label: 'Rejected', order: 7, color: '#EF4444' },
  withdrawn: { label: 'Withdrawn', order: 8, color: '#6B7280' },
  ghosted: { label: 'Ghosted', order: 9, color: '#D97706' },
};
export const STATUS_KEYS = Object.keys(ApplicationStatus);
export const CLOSED_STATUSES = ['accepted', 'rejected', 'withdrawn', 'ghosted'];
export const isActiveStatus = (s) => !CLOSED_STATUSES.includes(s);
export const statusColor = (s) => ApplicationStatus[s]?.color || '#9E9E9E';
export const statusLabel = (s) => ApplicationStatus[s]?.label || s;
export const PIPELINE_STAGES = [
  'wishlist', 'applied', 'phoneScreen', 'technicalRound', 'onsiteInterview', 'offerReceived',
];

export const WorkType = {
  remote: 'Remote', hybrid: 'Hybrid', onsite: 'Onsite',
};

export const JobSource = {
  linkedin: 'LinkedIn', naukri: 'Naukri', indeed: 'Indeed',
  company: 'Company Website', referral: 'Referral', other: 'Other',
};

export const DocumentType = {
  resume: 'Resume', coverLetter: 'Cover Letter', portfolio: 'Portfolio', other: 'Other',
};

export const InterviewType = {
  phone: 'Phone', technical: 'Technical', behavioral: 'Behavioral',
  systemDesign: 'System Design', takeHome: 'Take-Home', hr: 'HR', final_: 'Final',
};

// ── ATS providers (live job sync) ──
export const AtsProvider = {
  greenhouse: { label: 'Greenhouse', fetchable: true, hint: 'Board token, e.g. "stripe" from boards.greenhouse.io/stripe' },
  lever: { label: 'Lever', fetchable: true, hint: 'Company slug, e.g. "netflix" from jobs.lever.co/netflix' },
  ashby: { label: 'Ashby', fetchable: true, hint: 'Org slug, e.g. "openai" from jobs.ashbyhq.com/openai' },
  smartrecruiters: { label: 'SmartRecruiters', fetchable: true, hint: 'Company id, e.g. "Square"' },
  workable: { label: 'Workable', fetchable: true, hint: 'Subdomain, e.g. "acme"' },
  recruitee: { label: 'Recruitee', fetchable: true, hint: 'Subdomain, e.g. "acme"' },
  amazon: { label: 'Amazon Jobs', fetchable: true, hint: 'Set location & keyword below' },
  workday: { label: 'Workday', fetchable: true, hint: 'Paste the Workday careers URL to auto-fill' },
  custom: { label: 'Open link (no sync)', fetchable: false, hint: 'No live jobs — we just open the careers page' },
};
export const isFetchable = (p) => !!AtsProvider[p]?.fetchable;

export const CompanyCategory = {
  bigTech: 'Big Tech (FAANG+)',
  productSaas: 'Product / SaaS',
  fintech: 'Fintech & Payments',
  indianIt: 'Indian IT Services',
  unicorn: 'Unicorns & Startups',
  semiconductorHardware: 'Semiconductor & Hardware',
  consultingGcc: 'Consulting & GCCs',
  other: 'Other',
};
export const CATEGORY_KEYS = Object.keys(CompanyCategory);

export const CareerWorkType = {
  remote: 'Remote', hybrid: 'Hybrid', onsite: 'Onsite', unknown: 'Other',
};

// ── Goals ──
export const GoalPeriod = {
  daily: { label: 'Daily', unit: 'today' },
  weekly: { label: 'Weekly', unit: 'this week' },
  monthly: { label: 'Monthly', unit: 'this month' },
};
export const GoalMetric = {
  applicationsAdded: { label: 'Applications logged', short: 'logged' },
  applicationsApplied: { label: 'Applications submitted', short: 'applied' },
  interviews: { label: 'Interviews', short: 'interviews' },
};

// ── Referrals ──
export const ReferralSourceType = {
  googleForm: { label: 'Google Form', isForm: true },
  group: { label: 'WhatsApp / Telegram', isForm: false },
  linkedin: { label: 'LinkedIn', isForm: false },
  person: { label: 'Employee referral', isForm: false },
};
export const ReferralStatus = {
  requested: { label: 'Requested', color: '#3B82F6' },
  referred: { label: 'Referred', color: '#8B5CF6' },
  applied: { label: 'Applied', color: '#22C55E' },
  rejected: { label: 'Rejected', color: '#EF4444' },
  noResponse: { label: 'No Response', color: '#9E9E9E' },
};
