import 'package:flutter_test/flutter_test.dart';
import 'package:applitrack/core/constants/enums.dart';
import 'package:applitrack/services/job_board_service.dart';

void main() {
  group('JobBoardService.detectFromUrl', () {
    test('detects Greenhouse board token', () {
      final d = JobBoardService.detectFromUrl('https://boards.greenhouse.io/stripe');
      expect(d?.provider, AtsProvider.greenhouse);
      expect(d?.slug, 'stripe');
    });

    test('detects Lever company', () {
      final d = JobBoardService.detectFromUrl('https://jobs.lever.co/netflix');
      expect(d?.provider, AtsProvider.lever);
      expect(d?.slug, 'netflix');
    });

    test('detects Ashby org', () {
      final d = JobBoardService.detectFromUrl('https://jobs.ashbyhq.com/openai');
      expect(d?.provider, AtsProvider.ashby);
      expect(d?.slug, 'openai');
    });

    test('detects Workable subdomain', () {
      final d = JobBoardService.detectFromUrl('https://acme.workable.com/jobs');
      expect(d?.provider, AtsProvider.workable);
      expect(d?.slug, 'acme');
    });

    test('detects Amazon with location params', () {
      final d = JobBoardService.detectFromUrl(
          'https://www.amazon.jobs/en/search?loc_query=India&country=IND');
      expect(d?.provider, AtsProvider.amazon);
      expect(d?.config['loc_query'], 'India');
      expect(d?.config['country'], 'IND');
    });

    test('detects Workday tenant/dc/site', () {
      final d = JobBoardService.detectFromUrl(
          'https://nvidia.wd5.myworkdayjobs.com/en-US/NVIDIAExternalCareerSite');
      expect(d?.provider, AtsProvider.workday);
      expect(d?.config['tenant'], 'nvidia');
      expect(d?.config['dc'], 'wd5');
      expect(d?.config['site'], 'NVIDIAExternalCareerSite');
    });

    test('returns null for an unrecognised careers page', () {
      final d = JobBoardService.detectFromUrl('https://careers.adobe.com/us/en');
      expect(d, isNull);
    });

    test('tolerates a URL without scheme', () {
      final d = JobBoardService.detectFromUrl('boards.greenhouse.io/databricks');
      expect(d?.provider, AtsProvider.greenhouse);
      expect(d?.slug, 'databricks');
    });
  });
}
