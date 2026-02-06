import 'package:flutter/material.dart';

class RecentExport {
  final String filename;
  final String date;
  final VoidCallback onDownload;

  const RecentExport({
    required this.filename,
    required this.date,
    required this.onDownload,
  });
}
