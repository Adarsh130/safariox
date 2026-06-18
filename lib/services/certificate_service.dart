import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/certificate.dart';
import '../models/registration.dart';
import '../models/trip.dart';
import '../config/app_config.dart';

class CertificateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Certificate?> getCertificate(String registrationId) async {
    final snap = await _db
        .collection(AppConfig.colCertificates)
        .where('registrationId', isEqualTo: registrationId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Certificate.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Future<Certificate> generateCertificate({
    required Registration registration,
    required Trip trip,
  }) async {
    // Check if already generated
    final existing = await getCertificate(registration.id);
    if (existing != null) return existing;

    final cert = Certificate(
      id: '',
      tripId: registration.tripId,
      userId: registration.userId,
      registrationId: registration.id,
      studentName: registration.fullName,
      tripName: trip.tripName,
      instituteName: trip.instituteName,
      destination: trip.destination,
      passId: registration.passId,
      tripDate: trip.tripDate,
    );

    final docRef = await _db
        .collection(AppConfig.colCertificates)
        .add(cert.toMap());

    return Certificate.fromMap(cert.toMap(), docRef.id);
  }

  Future<pw.Document> buildCertificatePdf(Certificate cert) async {
    final pdf = pw.Document();

    // Load font
    final fontData =
        await rootBundle.load('assets/fonts/Poppins-Regular.ttf');
    final boldFontData =
        await rootBundle.load('assets/fonts/Poppins-Bold.ttf');
    final ttf = pw.Font.ttf(fontData);
    final boldTtf = pw.Font.ttf(boldFontData);

    final dateStr = cert.tripDate != null
        ? DateFormat('dd MMMM, yyyy').format(cert.tripDate!)
        : '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColor.fromHex('1B8C4E'),
                width: 4,
              ),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'SAFARIOX INDIA',
                  style: pw.TextStyle(
                    font: boldTtf,
                    fontSize: 28,
                    color: PdfColor.fromHex('1B8C4E'),
                    letterSpacing: 4,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Smart Student Trip Management Platform',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 12,
                    color: PdfColor.fromHex('6B7280'),
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Divider(color: PdfColor.fromHex('1B8C4E')),
                pw.SizedBox(height: 24),
                pw.Text(
                  'CERTIFICATE OF PARTICIPATION',
                  style: pw.TextStyle(
                    font: boldTtf,
                    fontSize: 22,
                    color: PdfColor.fromHex('1A1A2E'),
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'This is to certify that',
                  style: pw.TextStyle(font: ttf, fontSize: 14, color: PdfColor.fromHex('6B7280')),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  cert.studentName,
                  style: pw.TextStyle(
                    font: boldTtf,
                    fontSize: 30,
                    color: PdfColor.fromHex('1B8C4E'),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'from ${cert.instituteName}',
                  style: pw.TextStyle(font: ttf, fontSize: 14, color: PdfColor.fromHex('6B7280')),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'has successfully participated in the educational tour',
                  style: pw.TextStyle(font: ttf, fontSize: 14, color: PdfColor.fromHex('1A1A2E')),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '"${cert.tripName}"',
                  style: pw.TextStyle(
                    font: boldTtf,
                    fontSize: 20,
                    color: PdfColor.fromHex('1B8C4E'),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'to ${cert.destination}  •  ${dateStr.isNotEmpty ? dateStr : ""}',
                  style: pw.TextStyle(font: ttf, fontSize: 14, color: PdfColor.fromHex('6B7280')),
                ),
                pw.SizedBox(height: 24),
                pw.Divider(color: PdfColor.fromHex('E5E7EB')),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Pass ID: ${cert.passId}',
                      style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColor.fromHex('9CA3AF')),
                    ),
                    pw.Text(
                      'Issued on: ${DateFormat('dd MMM yyyy').format(cert.issuedAt ?? DateTime.now())}',
                      style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColor.fromHex('9CA3AF')),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> printOrShare(Certificate cert) async {
    final pdf = await buildCertificatePdf(cert);
    final bytes = await pdf.save();
    await Printing.sharePdf(
        bytes: bytes,
        filename: 'SafariOX_Certificate_${cert.studentName}.pdf');
  }

  Stream<List<Certificate>> getTripCertificates(String tripId) {
    return _db
        .collection(AppConfig.colCertificates)
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Certificate.fromMap(d.data(), d.id)).toList());
  }
}
