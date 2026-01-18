import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/table_model.dart';

/// QR Code Dialog - Displays the QR code for a table
/// Matches reference design with title, QR code, description, and download button
class QrCodeDialog extends StatelessWidget {
  final TableModel table;

  const QrCodeDialog({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QR Code - T-${table.tableNumber}',
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Icon(
                    Icons.close,
                    size: 22,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // QR Code Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: table.qrUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: table.qrUrl,
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => Container(
                        width: 180,
                        height: 180,
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.qr_code_2,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      placeholder: (_, __) => Container(
                        width: 180,
                        height: 180,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  : Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.qr_code_2,
                        size: 100,
                        color: Colors.grey.shade800,
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Description text
            Text(
              'Scan to view menu and place orders for T-${table.tableNumber}',
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement Download/Print
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading QR Code...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.download_rounded, size: 20),
                label: Text(
                  'Download QR Code',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
