class LegalDocuments {
  static const String privacyPolicy = """
  [PRIVACY POLICY
Last Updated: 23rd July 2025
Effective Date: 23rd July 2025

1. Introduction
Haraka Afya AI ("we," "us," or "our") operates a mobile health application that provides AI-powered health insights. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our services in compliance with Kenya's Data Protection Act (2019) and other applicable laws.

2. Information We Collect
A. Personal Information
Full name

Email address

Phone number

Age and gender

Location data (with consent)

Payment details (for premium services)

B. Health Data
Medical history

Symptoms and diagnoses

Medication records

Vital signs (blood pressure, glucose levels, etc.)

Fitness/activity data

C. Technical Data
Device information (model, OS version)

IP address and browser type

Usage patterns and analytics

Cookies and tracking technologies

3. How We Use Your Information
Purpose	Legal Basis
Provide personalized health insights	Performance of contract
Improve app functionality	Legitimate interest
Medical research (anonymized)	Consent
Prevent fraud/abuse	Legal obligation
Marketing communications	Consent (opt-in required)
4. Data Sharing & Disclosure
We may share data with:
✅ Healthcare providers (with explicit consent)
✅ Cloud service providers (AWS Africa with encryption)
✅ Legal authorities (when required by Kenyan law)
❌ Never sold to third parties

5. International Data Transfers
Data may be transferred to:

AWS servers in South Africa (under Standard Contractual Clauses)

Analytics providers in the EU/US (GDPR-compliant)

6. Data Security Measures
End-to-end encryption for health data

Biometric authentication

Regular penetration testing

Staff training on data protection

7. Your Rights Under Kenyan Law
You have the right to:

Access your personal data (Section 26, DPA 2019)

Request correction of inaccurate data

Delete your account/data ("Right to be Forgotten")

Restrict processing of sensitive health data

Lodge complaints with Kenya's Data Protection Commissioner

8. Data Retention
Health records: 7 years (per medical retention standards)

Account data: Until deletion request

Anonymized research data: Indefinitely

9. Children's Privacy
We do not knowingly collect data from children under 16 without parental consent (Section 31, DPA).

10. Changes to This Policy
We will notify users of material changes via:

In-app notifications

Email alerts (for registered users)

11. Contact Us
For data requests or complaints:
Email: dpo@harakaafya.co.ke
Physical Address: [P.O. Box 1234, Nairobi, Kenya]
Data Protection Officer: [Immaculate Kassait, MBS]

Supplemental Policies:

Terms of Service

Cookie Policy

Data Processing Addendum

This policy was drafted with reference to:
✔ Kenya Data Protection Act (2019)
✔ GDPR (Articles 9, 30, 35)
✔ HIPAA Security Rule (for health data best practices)

]
  """;

  static const String termsOfService = """
  [TERMS OF SERVICE
Last Updated: 23rd July 2025
Effective Date: 23rd July 2025

1. Acceptance of Terms
By accessing Haraka Afya AI ("the App"), you agree to be bound by these Terms and confirm that you:

Are at least 18 years old or have guardian consent (Section 31, Kenya Data Protection Act)

Accept jurisdiction of Kenyan courts for disputes

Acknowledge this constitutes a legally binding agreement

2. Medical Disclaimer
Critical Notice:
The App provides AI-generated health insights for informational purposes only and does NOT:

Constitute medical diagnosis/treatment

Replace professional healthcare advice

Guarantee accuracy of predictions

3. Account Requirements
3.1 User Obligations:

Provide accurate health information

Maintain credential confidentiality

Immediately report unauthorized access

3.2 Prohibited Conduct:

Inputting false medical data

Reverse-engineering AI models

Commercial resale of App outputs

4. Intellectual Property
4.1 Ownership:

All algorithms, UI designs, and content are proprietary

Limited license granted for personal use only

4.2 User-Generated Content:

You retain ownership of inputted health data

Grant us irrevocable license to process for service delivery

5. Payments & Subscriptions
5.1 Premium Features:

Recurring billing cycles (monthly/annually)

14-day refund policy for technical failures

5.2 Tax Compliance:
All fees inclusive of 16% Kenyan VAT (where applicable)

6. Termination
6.1 By Us:
May suspend accounts for:

Suspicion of fraudulent activity

Violations of these Terms

6.2 By You:
May delete account via Settings > Privacy Dashboard

7. Limitation of Liability
Exclusions:

Decisions made based on App recommendations

Service interruptions beyond our control

Third-party integrations (Google Fit, Apple HealthKit)

Maximum Liability: 6 months of subscription fees

8. Dispute Resolution
8.1 Mandatory Mediation:

60-day negotiation period required

Mediator appointed by Nairobi Centre for Arbitration

8.2 Governing Law:
Laws of Kenya, with exclusive jurisdiction in Nairobi courts

9. Force Majeure
Not liable for delays caused by:

National internet shutdowns

Public health emergencies

Regulatory changes by Kenya's Ministry of Health

10. Amendments
Material changes require:

30 days' advance notice

Re-acceptance by existing users

]
  """;

  static const String dataProtectionNotice = """
  [DATA PROTECTION NOTICE
Last Updated: 23rd July 2025

1. Lawful Bases for Processing
Under Article 31 of Kenya's DPA, we rely on:

Explicit Consent (for health data)

Contractual Necessity (service delivery)

Legal Obligation (medical record retention)

2. Special Category Data
Sensitive health data receives:

Additional encryption layer (AES-256)

Strict access controls (role-based permissions)

Automated anonymization for research

3. International Transfers
3.1 Safeguards Implemented:

Standard Contractual Clauses (EU GDPR)

Data localization for critical health records

3.2 Third-Party Processors:

AWS Africa (Cape Town) - ISO 27001 certified

Google Cloud - HIPAA-compliant configurations

4. Data Subject Rights
Exercisable via In-App Dashboard:

Right to data portability (JSON/PDF exports)

Right to restrict AI model training

Right to human review of automated decisions

5. Breach Notification
Will notify Kenya's Data Commissioner within:

72 hours of discovering a breach

24 hours if health data is compromised

]
  """;

  static const String cookiePolicy = """
  [COOKIE POLICY
Last Updated: 23rd July 2025

1. Essential Cookies
Cookie Name	Purpose	Duration
session_id	Authentication	24 hours
csrf_token	Security	Session
2. Analytics Cookies
Google Analytics 4: Anonymized tracking (IP masking enabled)

Hotjar: Behavior analysis (opt-out available)

3. Advertising Cookies
Facebook Pixel: Disabled by default for health users

Google Ads: Only activated for non-health pages

4. Consent Management
4.1 Granular Controls:

Separate toggles for:

Performance cookies

Marketing cookies

Third-party embeds

4.2 Children's Protection:

No non-essential cookies for users under 16

5. Do Not Track (DNT)
We honor DNT browser signals and disable analytics if detected

Implementation Checklist:

In-App Integration:

Embed policies in App Settings > Legal Center

Require scroll-through consent for first-time users

Regulatory Compliance:

Register with Kenya's Office of the Data Protection Commissioner

Maintain Records of Processing Activities (Article 31, DPA)

User Education:

Create video explainers in Swahili/English

FAQ section addressing common concerns]
  """;
}