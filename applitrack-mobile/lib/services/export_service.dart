import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/job_application.dart';
import '../core/constants/enums.dart';

class ExportService {
  static String _fmt(DateTime? dt) {
    if (dt == null) return '';
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  // ──────────── CSV ────────────

  static Future<void> exportCsv(List<JobApplication> apps) async {
    final rows = <List<String>>[
      ['Company', 'Role', 'Status', 'Source', 'Work Type',
       'Location', 'Applied Date', 'Priority', 'Salary Min',
       'Salary Max', 'Currency', 'Tags', 'Notes', 'Added'],
    ];

    for (final a in apps) {
      rows.add([
        _csvCell(a.company),
        _csvCell(a.role),
        _csvCell(a.status.label),
        _csvCell(a.source.label),
        _csvCell(a.workType.label),
        _csvCell(a.location ?? ''),
        _csvCell(_fmt(a.appliedDate)),
        a.priority.toString(),
        a.salaryMin?.toStringAsFixed(0) ?? '',
        a.salaryMax?.toStringAsFixed(0) ?? '',
        _csvCell(a.salaryCurrency),
        _csvCell(a.tags.join('; ')),
        _csvCell(a.notes ?? ''),
        _csvCell(_fmt(a.createdAt)),
      ]);
    }

    final csv = rows.map((r) => r.join(',')).join('\n');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/applitrack_export.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'AppliTrack — Application Export',
    );
  }

  static String _csvCell(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  // ──────────── PDF ────────────

  static Future<void> exportPdf(List<JobApplication> apps) async {
    final doc = pw.Document();

    // Count by status
    final statusCounts = <ApplicationStatus, int>{};
    for (final s in ApplicationStatus.values) {
      statusCounts[s] = apps.where((a) => a.status == s).length;
    }
    final applied = apps.where((a) => a.status != ApplicationStatus.wishlist).length;
    final responses = apps.where((a) =>
        a.status.pipelineOrder >= ApplicationStatus.phoneScreen.pipelineOrder).length;
    final offers = (statusCounts[ApplicationStatus.offerReceived] ?? 0) +
        (statusCounts[ApplicationStatus.accepted] ?? 0);
    final responseRate = applied == 0 ? 0.0 : responses / applied;
    final offerRate = applied == 0 ? 0.0 : offers / applied;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Row(children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('AppliTrack — Job Application Report',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Generated ${_fmt(DateTime.now())}',
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.grey600)),
                ],
              ),
            ),
          ]),
          pw.SizedBox(height: 20),

          // Summary stats
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _statBox('Total', apps.length.toString()),
              _statBox('Active',
                  apps.where((a) => a.status.isActive).length.toString()),
              _statBox('Offers', offers.toString()),
              _statBox('Response Rate',
                  '${(responseRate * 100).toStringAsFixed(1)}%'),
              _statBox('Offer Rate',
                  '${(offerRate * 100).toStringAsFixed(1)}%'),
            ],
          ),
          pw.SizedBox(height: 24),

          // Status breakdown
          pw.Text('Pipeline Summary',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              _tableHeader(['Status', 'Count']),
              ...ApplicationStatus.values
                  .where((s) => (statusCounts[s] ?? 0) > 0)
                  .map((s) => _tableRow([s.label, '${statusCounts[s]}'])),
            ],
          ),
          pw.SizedBox(height: 24),

          // Applications table
          pw.Text('All Applications',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1),
            },
            children: [
              _tableHeader(
                  ['Company', 'Role', 'Status', 'Source', 'Applied']),
              ...apps.map((a) => _tableRow([
                    a.company,
                    a.role,
                    a.status.label,
                    a.source.label,
                    _fmt(a.appliedDate),
                  ])),
            ],
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/applitrack_report.pdf');
    await file.writeAsBytes(await doc.save());

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'AppliTrack — Application Report',
    );
  }

  static pw.Widget _statBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        children: [
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static pw.TableRow _tableHeader(List<String> cols) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: cols
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(c,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
              ))
          .toList(),
    );
  }

  static pw.TableRow _tableRow(List<String> cells) {
    return pw.TableRow(
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(c,
                    style: const pw.TextStyle(fontSize: 9)),
              ))
          .toList(),
    );
  }
}
