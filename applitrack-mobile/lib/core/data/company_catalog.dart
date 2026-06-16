import '../constants/enums.dart';

/// A ready-to-add company in the built-in catalog.
///
/// Every `fetchable` entry here was verified against the live ATS API. Big
/// portals that only render jobs via brittle SSR (Google, Adobe, Microsoft,
/// Apple, Meta, …) are shipped as `custom` deep-links pre-filtered for tech
/// roles (and India where the portal supports it) — tapping opens the page.
class SeedCompany {
  final String name;
  final AtsProvider provider;
  final String? slug;
  final String? careerUrl;
  final CompanyCategory category;
  final Map<String, String> config;
  final List<String> tags;

  const SeedCompany({
    required this.name,
    required this.provider,
    required this.category,
    this.slug,
    this.careerUrl,
    this.config = const {},
    this.tags = const [],
  });
}

/// Curated, verified catalog. Add new entries here and they show up in the
/// in-app catalog automatically.
const List<SeedCompany> kCompanyCatalog = [
  // ---- Big Tech ------------------------------------------------------------
  SeedCompany(
    name: 'Amazon (India · Tech)',
    provider: AtsProvider.amazon,
    category: CompanyCategory.bigTech,
    config: {'loc_query': 'India', 'country': 'IND', 'category': 'software-development'},
    careerUrl: 'https://www.amazon.jobs/en/search?loc_query=India&country=IND',
    tags: ['India', 'Tech'],
  ),
  SeedCompany(
    name: 'Google',
    provider: AtsProvider.custom,
    category: CompanyCategory.bigTech,
    careerUrl:
        'https://www.google.com/about/careers/applications/jobs/results/?category=SOFTWARE_ENGINEERING&category=TECHNICAL_INFRASTRUCTURE_ENGINEERING&category=DATA_CENTER_OPERATIONS&location=India',
    tags: ['India', 'Tech'],
  ),
  SeedCompany(
    name: 'Microsoft',
    provider: AtsProvider.custom,
    category: CompanyCategory.bigTech,
    careerUrl:
        'https://jobs.careers.microsoft.com/global/en/search?lc=India&p=Software%20Engineering',
    tags: ['India', 'Tech'],
  ),
  SeedCompany(
    name: 'Apple',
    provider: AtsProvider.custom,
    category: CompanyCategory.bigTech,
    careerUrl:
        'https://jobs.apple.com/en-in/search?location=india-INDC&team=software-and-services-SFTWR',
    tags: ['India', 'Tech'],
  ),
  SeedCompany(
    name: 'Meta',
    provider: AtsProvider.custom,
    category: CompanyCategory.bigTech,
    careerUrl: 'https://www.metacareers.com/jobs?roles[0]=Software%20Engineering',
    tags: ['Tech'],
  ),
  SeedCompany(
    name: 'Netflix',
    provider: AtsProvider.custom,
    category: CompanyCategory.bigTech,
    careerUrl: 'https://explore.jobs.netflix.net/careers?domain=netflix.com',
    tags: ['Tech'],
  ),

  // ---- Product / SaaS ------------------------------------------------------
  SeedCompany(name: 'Databricks', provider: AtsProvider.greenhouse, slug: 'databricks', category: CompanyCategory.productSaas, tags: ['Data', 'Tech']),
  SeedCompany(name: 'OpenAI', provider: AtsProvider.ashby, slug: 'openai', category: CompanyCategory.productSaas, tags: ['AI', 'Tech']),
  SeedCompany(name: 'Notion', provider: AtsProvider.ashby, slug: 'notion', category: CompanyCategory.productSaas, tags: ['Tech']),
  SeedCompany(name: 'Linear', provider: AtsProvider.ashby, slug: 'linear', category: CompanyCategory.productSaas, tags: ['Tech']),
  SeedCompany(name: 'Figma', provider: AtsProvider.greenhouse, slug: 'figma', category: CompanyCategory.productSaas, tags: ['Design', 'Tech']),
  SeedCompany(name: 'GitLab', provider: AtsProvider.greenhouse, slug: 'gitlab', category: CompanyCategory.productSaas, tags: ['Remote', 'Tech']),
  SeedCompany(name: 'Postman', provider: AtsProvider.greenhouse, slug: 'postman', category: CompanyCategory.productSaas, tags: ['India', 'Tech']),
  SeedCompany(name: 'Asana', provider: AtsProvider.greenhouse, slug: 'asana', category: CompanyCategory.productSaas, tags: ['Tech']),
  SeedCompany(name: 'Dropbox', provider: AtsProvider.greenhouse, slug: 'dropbox', category: CompanyCategory.productSaas, tags: ['Tech']),
  SeedCompany(name: 'Pinterest', provider: AtsProvider.greenhouse, slug: 'pinterest', category: CompanyCategory.productSaas, tags: ['Tech']),
  SeedCompany(name: 'Reddit', provider: AtsProvider.greenhouse, slug: 'reddit', category: CompanyCategory.productSaas, tags: ['Tech']),
  SeedCompany(name: 'Discord', provider: AtsProvider.greenhouse, slug: 'discord', category: CompanyCategory.productSaas, tags: ['Tech']),
  SeedCompany(name: 'Twilio', provider: AtsProvider.greenhouse, slug: 'twilio', category: CompanyCategory.productSaas, tags: ['Tech']),
  SeedCompany(name: 'MongoDB', provider: AtsProvider.greenhouse, slug: 'mongodb', category: CompanyCategory.productSaas, tags: ['Data', 'Tech']),
  SeedCompany(name: 'Elastic', provider: AtsProvider.greenhouse, slug: 'elastic', category: CompanyCategory.productSaas, tags: ['Remote', 'Tech']),
  SeedCompany(name: 'Cloudflare', provider: AtsProvider.greenhouse, slug: 'cloudflare', category: CompanyCategory.productSaas, tags: ['Tech']),
  SeedCompany(name: 'Airbnb', provider: AtsProvider.greenhouse, slug: 'airbnb', category: CompanyCategory.productSaas, tags: ['Tech']),
  SeedCompany(
    name: 'Salesforce',
    provider: AtsProvider.workday,
    category: CompanyCategory.productSaas,
    config: {'tenant': 'salesforce', 'dc': 'wd12', 'site': 'External_Career_Site', 'query': 'software engineer'},
    careerUrl: 'https://salesforce.wd12.myworkdayjobs.com/External_Career_Site',
    tags: ['Tech'],
  ),
  SeedCompany(
    name: 'Adobe',
    provider: AtsProvider.custom,
    category: CompanyCategory.productSaas,
    careerUrl: 'https://careers.adobe.com/us/en/c/engineering-and-product-jobs',
    tags: ['Tech'],
  ),

  // ---- Fintech & Payments --------------------------------------------------
  SeedCompany(name: 'Stripe', provider: AtsProvider.greenhouse, slug: 'stripe', category: CompanyCategory.fintech, tags: ['Tech']),
  SeedCompany(name: 'Coinbase', provider: AtsProvider.greenhouse, slug: 'coinbase', category: CompanyCategory.fintech, tags: ['Crypto', 'Tech']),
  SeedCompany(name: 'Robinhood', provider: AtsProvider.greenhouse, slug: 'robinhood', category: CompanyCategory.fintech, tags: ['Tech']),
  SeedCompany(name: 'Ramp', provider: AtsProvider.ashby, slug: 'ramp', category: CompanyCategory.fintech, tags: ['Tech']),

  // ---- Unicorns & Startups (India) ----------------------------------------
  SeedCompany(name: 'CRED', provider: AtsProvider.lever, slug: 'cred', category: CompanyCategory.unicorn, tags: ['India', 'Tech']),
  SeedCompany(name: 'PhonePe', provider: AtsProvider.greenhouse, slug: 'phonepe', category: CompanyCategory.unicorn, tags: ['India', 'Fintech']),
  SeedCompany(
    name: 'Flipkart',
    provider: AtsProvider.custom,
    category: CompanyCategory.unicorn,
    careerUrl: 'https://www.flipkartcareers.com/#!/joblist',
    tags: ['India'],
  ),
  SeedCompany(
    name: 'Swiggy',
    provider: AtsProvider.custom,
    category: CompanyCategory.unicorn,
    careerUrl: 'https://careers.swiggy.com/#/careers',
    tags: ['India'],
  ),
  SeedCompany(
    name: 'Zomato',
    provider: AtsProvider.custom,
    category: CompanyCategory.unicorn,
    careerUrl: 'https://www.zomato.com/careers',
    tags: ['India'],
  ),
  SeedCompany(
    name: 'Razorpay',
    provider: AtsProvider.custom,
    category: CompanyCategory.unicorn,
    careerUrl: 'https://razorpay.com/jobs/',
    tags: ['India', 'Fintech'],
  ),

  // ---- Semiconductor & Hardware -------------------------------------------
  SeedCompany(
    name: 'NVIDIA',
    provider: AtsProvider.workday,
    category: CompanyCategory.semiconductorHardware,
    config: {'tenant': 'nvidia', 'dc': 'wd5', 'site': 'NVIDIAExternalCareerSite', 'query': 'engineer'},
    careerUrl: 'https://nvidia.wd5.myworkdayjobs.com/NVIDIAExternalCareerSite',
    tags: ['Tech', 'Hardware'],
  ),

  // ---- Indian IT Services --------------------------------------------------
  SeedCompany(name: 'Zoho', provider: AtsProvider.custom, category: CompanyCategory.indianIt, careerUrl: 'https://careers.zohocorp.com/jobs/Careers', tags: ['India']),
  SeedCompany(name: 'Freshworks', provider: AtsProvider.custom, category: CompanyCategory.indianIt, careerUrl: 'https://www.freshworks.com/company/careers/', tags: ['India']),
  SeedCompany(name: 'TCS', provider: AtsProvider.custom, category: CompanyCategory.indianIt, careerUrl: 'https://www.tcs.com/careers', tags: ['India']),
  SeedCompany(name: 'Infosys', provider: AtsProvider.custom, category: CompanyCategory.indianIt, careerUrl: 'https://www.infosys.com/careers/', tags: ['India']),
];
