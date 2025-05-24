import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class InvoicePage extends StatelessWidget {
  final String studentName;
  final String rollNumber;
  final String route;
  final String busNumber;
  final String invoiceNumber;

  InvoicePage({
    super.key,
    required this.studentName,
    required this.rollNumber,
    required this.route,
    required this.busNumber,
  }) : invoiceNumber = Uuid().v4().substring(0, 8).toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _generateAndSavePdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInvoiceSection('Bank Copy'),
            const SizedBox(height: 30),
            _buildInvoiceSection('University Copy'),
            const SizedBox(height: 30),
            _buildInvoiceSection('Student Copy'),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSection(String title) {
    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 22));
    final latePayment1 = dueDate.add(const Duration(days: 1));
    final latePayment2 = dueDate.add(const Duration(days: 8));
    final latePayment3 = dueDate.add(const Duration(days: 35));

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Hazara University Mansehra',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(thickness: 2),
            _buildInvoiceRow('Invoice #', invoiceNumber),
            _buildInvoiceRow('Invoice Date', DateFormat('MM/dd/yyyy').format(now)),
            _buildInvoiceRow('Due Date', DateFormat('MM/dd/yyyy').format(dueDate)),
            _buildInvoiceRow('Valid Till', DateFormat('MM/dd/yyyy').format(dueDate.add(const Duration(days: 365)))),
            _buildInvoiceRow('Student ID', rollNumber),
            _buildInvoiceRow('Student Name', studentName),
            _buildInvoiceRow('Academic Program', 'Bachelor of Studies in Software Engineering'),
            _buildInvoiceRow('Discipline', 'Faculty of Natural and Computational Sciences'),
            _buildInvoiceRow('Term', 'Fall Semester ${now.year}'),
            _buildInvoiceRow('Semester', 'Eight Semester'),
            const Divider(thickness: 2),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildInvoiceRow('Semester Fee', '30157.0'),
            _buildInvoiceRow('Other Fee', '9758.0'),
            _buildInvoiceRow('Payable within Due Date', '39915.0'),
            const SizedBox(height: 10),
            const Text('In Words', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Thirty-Nine Thousand, Nine Hundred And Fifteen.'),
            const SizedBox(height: 10),
            const Text('Payable After Due Date', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildInvoiceRow(
              'Between ${DateFormat('dd-MMM-yy').format(latePayment1)} to ${DateFormat('dd-MMM-yy').format(latePayment1.add(const Duration(days: 6)))}',
              '40165.0',
            ),
            _buildInvoiceRow(
              'From ${DateFormat('dd-MMM-yy').format(latePayment2)} to Onward',
              '40415.0',
            ),
            _buildInvoiceRow(
              'Between ${DateFormat('dd-MMM-yy').format(latePayment3)} to ${DateFormat('dd-MMM-yy').format(latePayment3.add(const Duration(days: 23)))}',
              '40915.0',
            ),
            const SizedBox(height: 10),
            const Text('Payment Information', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildInvoiceRow('Bank Account 1', 'PK09ABPA0010027677030010'),
            _buildInvoiceRow('Bank Account 2', 'PK59KHYB0117000033361003'),
            _buildInvoiceRow('Bank Account 3', 'PK58NBPA1487003098138436'),
            const SizedBox(height: 10),
            const Center(
              child: Text('Hazara Campus Management Solution'),
            ),
            const Center(
              child: Text('For Queries: ssc@hu.edu.pk | 0310-5345345'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _generateAndSavePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Row(
            children: [
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: _buildPdfInvoiceSection('Bank Copy'),
                ),
              ),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: _buildPdfInvoiceSection('University Copy'),
                ),
              ),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: _buildPdfInvoiceSection('Student Copy'),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfInvoiceSection(String title) {
    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 22));

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: pw.Text(
              'Hazara University Mansehra',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Divider(thickness: 1),
          _buildPdfInvoiceRow('Invoice #', invoiceNumber),
          _buildPdfInvoiceRow('Invoice Date', DateFormat('MM/dd/yyyy').format(now)),
          _buildPdfInvoiceRow('Due Date', DateFormat('MM/dd/yyyy').format(dueDate)),
          _buildPdfInvoiceRow('Student ID', rollNumber),
          _buildPdfInvoiceRow('Student Name', studentName),
          _buildPdfInvoiceRow('Academic Program', 'Bachelor of Studies in Software Engineering'),
          _buildPdfInvoiceRow('Semester Fee', '30157.0'),
          _buildPdfInvoiceRow('Other Fee', '9758.0'),
          _buildPdfInvoiceRow('Payable within Due Date', '39915.0'),
          pw.SizedBox(height: 5),
          pw.Text('Payment Information', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          _buildPdfInvoiceRow('Bank Account 1', 'PK09ABPA0010027677030010'),
          _buildPdfInvoiceRow('Bank Account 2', 'PK59KHYB0117000033361003'),
          _buildPdfInvoiceRow('Bank Account 3', 'PK58NBPA1487003098138436'),
        ],
      ),
    );
  }

  pw.Widget _buildPdfInvoiceRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:intl/intl.dart';
//
// class InvoicePage extends StatelessWidget {
//   final String studentName;
//   final String rollNumber;
//   final String route;
//   final String busNumber;
//
//   const InvoicePage({
//     super.key,
//     required this.studentName,
//     required this.rollNumber,
//     required this.route,
//     required this.busNumber,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Fee Invoice'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: () => _generateAndSavePdf(context),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             _buildInvoiceSection('Bank Copy'),
//             const SizedBox(height: 30),
//             _buildInvoiceSection('University Copy'),
//             const SizedBox(height: 30),
//             _buildInvoiceSection('Student Copy'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInvoiceSection(String title) {
//     final now = DateTime.now();
//     final dueDate = now.add(const Duration(days: 22));
//     final latePayment1 = dueDate.add(const Duration(days: 1));
//     final latePayment2 = dueDate.add(const Duration(days: 8));
//     final latePayment3 = dueDate.add(const Duration(days: 35));
//
//     return Card(
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//             Center(
//             child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             )),
//       ),
//       const SizedBox(height: 10),
//       const Center(
//         child: Text(
//           'Hazara University Mansehra',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       const Divider(thickness: 2),
//       _buildInvoiceRow('Invoice #', '411702'),
//       _buildInvoiceRow('Invoice Date', DateFormat('MM/dd/yyyy').format(now)),
//       _buildInvoiceRow('Due Date', DateFormat('MM/dd/yyyy').format(dueDate)),
//       _buildInvoiceRow('Valid Till', DateFormat('MM/dd/yyyy').format(dueDate.add(const Duration(days: 365)))),
//       _buildInvoiceRow('Student ID', rollNumber),
//       _buildInvoiceRow('Student Name', studentName),
//       _buildInvoiceRow('Academic Program', 'Bachelor of Studies in Software Engineering'),
//       _buildInvoiceRow('Discipline', 'Faculty of Natural and Computational Sciences'),
//       _buildInvoiceRow('Term', 'Fall Semester ${now.year}'),
//       _buildInvoiceRow('Semester', 'Eight Semester'),
//       const Divider(thickness: 2),
//       const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
//       _buildInvoiceRow('Semester Fee', '30157.0'),
//       _buildInvoiceRow('Other Fee', '9758.0'),
//       _buildInvoiceRow('Payable within Due Date', '39915.0'),
//       const SizedBox(height: 10),
//       const Text('In Words', style: TextStyle(fontWeight: FontWeight.bold)),
//       const Text('Thirty-Nine Thousand, Nine Hundred And Fifteen.'),
//       const SizedBox(height: 10),
//       const Text('Payable After Due Date', style: TextStyle(fontWeight: FontWeight.bold)),
//       _buildInvoiceRow(
//         'Between ${DateFormat('dd-MMM-yy').format(latePayment1)} to ${DateFormat('dd-MMM-yy').format(latePayment1.add(const Duration(days: 6)))}',
//           '40165.0',
//         ),
//         _buildInvoiceRow(
//           'From ${DateFormat('dd-MMM-yy').format(latePayment2)} to Onward',
//           '40415.0',
//         ),
//         _buildInvoiceRow(
//           'Between ${DateFormat('dd-MMM-yy').format(latePayment3)} to ${DateFormat('dd-MMM-yy').format(latePayment3.add(const Duration(days: 23)))}',
//             '40915.0',
//           ),
//           const SizedBox(height: 10),
//           const Text('Payment Information', style: TextStyle(fontWeight: FontWeight.bold)),
//           _buildInvoiceRow('Bank Account 1', 'PK09ABPA0010027677030010'),
//           _buildInvoiceRow('Bank Account 2', 'PK59KHYB0117000033361003'),
//           _buildInvoiceRow('Bank Account 3', 'PK58NBPA1487003098138436'),
//           const SizedBox(height: 10),
//           const Center(
//             child: Text('Hazara Campus Management Solution'),
//           ),
//           const Center(
//             child: Text('For Queries: ssc@hu.edu.pk | 0310-5345345'),
//           ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInvoiceRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label),
//           Text(value),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _generateAndSavePdf(BuildContext context) async {
//     final pdf = pw.Document();
//
//     // Add a page to the PDF
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) => [
//           _buildPdfInvoiceSection('Bank Copy'),
//           pw.SizedBox(height: 20),
//           _buildPdfInvoiceSection('University Copy'),
//           pw.SizedBox(height: 20),
//           _buildPdfInvoiceSection('Student Copy'),
//         ],
//       ),
//     );
//
//     // Save and share the PDF
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }
//
//   pw.Widget _buildPdfInvoiceSection(String title) {
//     final now = DateTime.now();
//     final dueDate = now.add(const Duration(days: 22));
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Center(
//           child: pw.Text(
//             title,
//             style: pw.TextStyle(
//               fontSize: 18,
//               fontWeight: pw.FontWeight.bold,
//             ),
//           ),
//         ),
//         pw.SizedBox(height: 10),
//         pw.Center(
//           child: pw.Text(
//             'Hazara University Mansehra',
//             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//           ),
//         ),
//         pw.Divider(thickness: 2),
//         _buildPdfInvoiceRow('Invoice #', '411702'),
//         _buildPdfInvoiceRow('Invoice Date', DateFormat('MM/dd/yyyy').format(now)),
//         _buildPdfInvoiceRow('Due Date', DateFormat('MM/dd/yyyy').format(dueDate)),
//         _buildPdfInvoiceRow('Student ID', rollNumber),
//         _buildPdfInvoiceRow('Student Name', studentName),
//         _buildPdfInvoiceRow('Academic Program', 'Bachelor of Studies in Software Engineering'),
//         _buildPdfInvoiceRow('Semester Fee', '30157.0'),
//         _buildPdfInvoiceRow('Other Fee', '9758.0'),
//         _buildPdfInvoiceRow('Payable within Due Date', '39915.0'),
//         pw.SizedBox(height: 10),
//         pw.Text('Payment Information', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//         _buildPdfInvoiceRow('Bank Account 1', 'PK09ABPA0010027677030010'),
//         _buildPdfInvoiceRow('Bank Account 2', 'PK59KHYB0117000033361003'),
//         _buildPdfInvoiceRow('Bank Account 3', 'PK58NBPA1487003098138436'),
//       ],
//     );
//   }
//
//   pw.Widget _buildPdfInvoiceRow(String label, String value) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 4),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(label),
//           pw.Text(value),
//         ],
//       ),
//     );
//   }
// }