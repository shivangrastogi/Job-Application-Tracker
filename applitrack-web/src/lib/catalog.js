// Verified catalog of top MNCs (mirrors lib/core/data/company_catalog.dart).
export const CATALOG = [
  // Big Tech
  { name: 'Amazon (India · Tech)', provider: 'amazon', category: 'bigTech', config: { loc_query: 'India', country: 'IND', category: 'software-development' }, careerUrl: 'https://www.amazon.jobs/en/search?loc_query=India&country=IND', tags: ['India', 'Tech'] },
  { name: 'Google', provider: 'custom', category: 'bigTech', careerUrl: 'https://www.google.com/about/careers/applications/jobs/results/?category=SOFTWARE_ENGINEERING&location=India', tags: ['India', 'Tech'] },
  { name: 'Microsoft', provider: 'custom', category: 'bigTech', careerUrl: 'https://jobs.careers.microsoft.com/global/en/search?lc=India&p=Software%20Engineering', tags: ['India', 'Tech'] },
  { name: 'Apple', provider: 'custom', category: 'bigTech', careerUrl: 'https://jobs.apple.com/en-in/search?location=india-INDC', tags: ['India', 'Tech'] },
  { name: 'Meta', provider: 'custom', category: 'bigTech', careerUrl: 'https://www.metacareers.com/jobs?roles[0]=Software%20Engineering', tags: ['Tech'] },
  { name: 'Netflix', provider: 'custom', category: 'bigTech', careerUrl: 'https://explore.jobs.netflix.net/careers', tags: ['Tech'] },
  // Product / SaaS
  { name: 'Databricks', provider: 'greenhouse', slug: 'databricks', category: 'productSaas', tags: ['Data'] },
  { name: 'OpenAI', provider: 'ashby', slug: 'openai', category: 'productSaas', tags: ['AI'] },
  { name: 'Notion', provider: 'ashby', slug: 'notion', category: 'productSaas', tags: ['Tech'] },
  { name: 'Linear', provider: 'ashby', slug: 'linear', category: 'productSaas', tags: ['Tech'] },
  { name: 'Figma', provider: 'greenhouse', slug: 'figma', category: 'productSaas', tags: ['Design'] },
  { name: 'GitLab', provider: 'greenhouse', slug: 'gitlab', category: 'productSaas', tags: ['Remote'] },
  { name: 'Postman', provider: 'greenhouse', slug: 'postman', category: 'productSaas', tags: ['India'] },
  { name: 'Asana', provider: 'greenhouse', slug: 'asana', category: 'productSaas', tags: ['Tech'] },
  { name: 'Dropbox', provider: 'greenhouse', slug: 'dropbox', category: 'productSaas', tags: ['Tech'] },
  { name: 'Pinterest', provider: 'greenhouse', slug: 'pinterest', category: 'productSaas', tags: ['Tech'] },
  { name: 'Reddit', provider: 'greenhouse', slug: 'reddit', category: 'productSaas', tags: ['Tech'] },
  { name: 'Discord', provider: 'greenhouse', slug: 'discord', category: 'productSaas', tags: ['Tech'] },
  { name: 'Twilio', provider: 'greenhouse', slug: 'twilio', category: 'productSaas', tags: ['Tech'] },
  { name: 'MongoDB', provider: 'greenhouse', slug: 'mongodb', category: 'productSaas', tags: ['Data'] },
  { name: 'Elastic', provider: 'greenhouse', slug: 'elastic', category: 'productSaas', tags: ['Remote'] },
  { name: 'Cloudflare', provider: 'greenhouse', slug: 'cloudflare', category: 'productSaas', tags: ['Tech'] },
  { name: 'Airbnb', provider: 'greenhouse', slug: 'airbnb', category: 'productSaas', tags: ['Tech'] },
  { name: 'Salesforce', provider: 'workday', category: 'productSaas', config: { tenant: 'salesforce', dc: 'wd12', site: 'External_Career_Site', query: 'software engineer' }, careerUrl: 'https://salesforce.wd12.myworkdayjobs.com/External_Career_Site', tags: ['Tech'] },
  { name: 'Adobe', provider: 'custom', category: 'productSaas', careerUrl: 'https://careers.adobe.com/us/en/c/engineering-and-product-jobs', tags: ['Tech'] },
  // Fintech
  { name: 'Stripe', provider: 'greenhouse', slug: 'stripe', category: 'fintech', tags: ['Tech'] },
  { name: 'Coinbase', provider: 'greenhouse', slug: 'coinbase', category: 'fintech', tags: ['Crypto'] },
  { name: 'Robinhood', provider: 'greenhouse', slug: 'robinhood', category: 'fintech', tags: ['Tech'] },
  { name: 'Ramp', provider: 'ashby', slug: 'ramp', category: 'fintech', tags: ['Tech'] },
  // Unicorns (India)
  { name: 'CRED', provider: 'lever', slug: 'cred', category: 'unicorn', tags: ['India'] },
  { name: 'PhonePe', provider: 'greenhouse', slug: 'phonepe', category: 'unicorn', tags: ['India', 'Fintech'] },
  { name: 'Flipkart', provider: 'custom', category: 'unicorn', careerUrl: 'https://www.flipkartcareers.com/#!/joblist', tags: ['India'] },
  { name: 'Swiggy', provider: 'custom', category: 'unicorn', careerUrl: 'https://careers.swiggy.com/#/careers', tags: ['India'] },
  { name: 'Zomato', provider: 'custom', category: 'unicorn', careerUrl: 'https://www.zomato.com/careers', tags: ['India'] },
  { name: 'Razorpay', provider: 'custom', category: 'unicorn', careerUrl: 'https://razorpay.com/jobs/', tags: ['India', 'Fintech'] },
  // Semiconductor & Hardware
  { name: 'NVIDIA', provider: 'workday', category: 'semiconductorHardware', config: { tenant: 'nvidia', dc: 'wd5', site: 'NVIDIAExternalCareerSite', query: 'engineer' }, careerUrl: 'https://nvidia.wd5.myworkdayjobs.com/NVIDIAExternalCareerSite', tags: ['Hardware'] },
  // Indian IT
  { name: 'Zoho', provider: 'custom', category: 'indianIt', careerUrl: 'https://careers.zohocorp.com/jobs/Careers', tags: ['India'] },
  { name: 'Freshworks', provider: 'custom', category: 'indianIt', careerUrl: 'https://www.freshworks.com/company/careers/', tags: ['India'] },
  { name: 'TCS', provider: 'custom', category: 'indianIt', careerUrl: 'https://www.tcs.com/careers', tags: ['India'] },
  { name: 'Infosys', provider: 'custom', category: 'indianIt', careerUrl: 'https://www.infosys.com/careers/', tags: ['India'] },
];
