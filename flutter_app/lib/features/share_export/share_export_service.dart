import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/quote_model.dart';

/// Service for sharing and exporting quotes.
///
/// All methods are static — no instantiation needed.
class ShareExportService {
  ShareExportService._();

  // ─── Share ──────────────────────────────────────────────────────────────────

  /// Shares a quote as text via the platform share sheet.
  static Future<void> shareQuote(
    QuoteModel quote, {
    String lang = 'en',
  }) async {
    final text = '"${quote.text}" \u2014 ${quote.author}'
        '\n\nDownload MindScroll';
    await Share.share(text, subject: 'Quote from MindScroll');
  }

  // ─── Export ─────────────────────────────────────────────────────────────────

  /// Renders [quote] to a 1080×1080 PNG and saves it to the gallery.
  ///
  /// [repaintKey] must be the [GlobalKey] attached to the off-screen
  /// [ExportCardWidget] wrapped in a [RepaintBoundary].
  static Future<void> exportQuoteAsImage(
    BuildContext context,
    QuoteModel quote,
  ) async {
    // We create a temporary overlay entry to render the export card off-screen,
    // capture it, remove the overlay, then save.
    final repaintKey = GlobalKey();
    final overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: -2000,
        top: -2000,
        width: 1080,
        height: 1080,
        child: RepaintBoundary(
          key: repaintKey,
          child: Material(
            color: Colors.transparent,
            child: ExportCardWidget(quote: quote),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Wait for the frame to render
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Could not find render boundary');

      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to convert image');

      final bytes = byteData.buffer.asUint8List();
      final fileName = 'mindscroll_${DateTime.now().millisecondsSinceEpoch}.png';
      final xFile = XFile.fromData(bytes, name: fileName, mimeType: 'image/png');

      await Share.shareXFiles([xFile], text: '"${quote.text}" \u2014 ${quote.author}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Image ready to share'),
            backgroundColor: const Color(0xFF14B8A6).withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          ),
        );
      }
    } finally {
      overlayEntry.remove();
    }
  }
}

// ─── Export card widget ──────────────────────────────────────────────────────

/// Off-screen 1080×1080 widget rendered when exporting a quote as an image.
class ExportCardWidget extends StatelessWidget {
  const ExportCardWidget({super.key, required this.quote});

  final QuoteModel quote;

  @override
  Widget build(BuildContext context) {
    final accentColor = _categoryColor(quote.category);

    return Container(
      width: 1080,
      height: 1080,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
        ),
      ),
      child: Stack(
        children: [
          // Left accent bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 8,
            child: Container(color: accentColor),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 120, 80, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: accentColor.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    quote.category.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: accentColor,
                      fontSize: 28,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // Quote text
                Text(
                  '\u201C${quote.text}\u201D',
                  style: const TextStyle(
                    fontFamily: 'Playfair',
                    color: Color(0xFFF5F0E8),
                    fontSize: 64,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                // Author
                Text(
                  '\u2014 ${quote.author}',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0x80F5F0E8),
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(flex: 2),
                // Watermark
                Text(
                  'MindScroll',
                  style: TextStyle(
                    fontFamily: 'Playfair',
                    color: accentColor.withOpacity(0.5),
                    fontSize: 32,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'stoicism':
        return const Color(0xFF14B8A6);
      case 'philosophy':
        return const Color(0xFFF59E0B);
      case 'discipline':
        return const Color(0xFFF97316);
      case 'reflection':
        return const Color(0xFFA78BFA);
      default:
        return const Color(0xFF14B8A6);
    }
  }
}
