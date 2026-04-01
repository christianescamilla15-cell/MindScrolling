import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/quote_model.dart';
import '../../shared/extensions/context_extensions.dart';

/// Bottom sheet for sharing a quote with a MindScrolling friend.
class ShareWithFriendSheet extends StatefulWidget {
  final QuoteModel quote;
  final String currentDeviceId;

  const ShareWithFriendSheet({
    super.key,
    required this.quote,
    required this.currentDeviceId,
  });

  static Future<void> show(BuildContext context, QuoteModel quote, String deviceId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShareWithFriendSheet(quote: quote, currentDeviceId: deviceId),
    );
  }

  @override
  State<ShareWithFriendSheet> createState() => _ShareWithFriendSheetState();
}

class _ShareWithFriendSheetState extends State<ShareWithFriendSheet> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _sent = false;
  String? _error;

  Future<void> _search(String query) async {
    if (query.length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);

    try {
      final uri = Uri.parse('${AppConstants.apiUrl}/api/shares/search-user?q=$query&exclude_device_id=${widget.currentDeviceId}');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _results = List<Map<String, dynamic>>.from(data['users'] ?? []);
          _loading = false;
        });
      }
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _shareWith(String toDeviceId) async {
    setState(() => _loading = true);
    try {
      final resp = await http.post(
        Uri.parse('${AppConstants.apiUrl}/api/shares'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from_device_id': widget.currentDeviceId,
          'to_device_id': toDeviceId,
          'quote_id': widget.quote.id,
        }),
      );
      if (resp.statusCode == 200) {
        setState(() { _sent = true; _loading = false; });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        final data = jsonDecode(resp.body);
        setState(() { _error = data['error'] ?? 'Error'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(tr.shareWithFriend, style: AppTypography.headlineSmall),
          const SizedBox(height: 4),

          // Quote preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${widget.quote.text.length > 80 ? '${widget.quote.text.substring(0, 80)}...' : widget.quote.text}"',
              style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 16),

          // Search
          if (!_sent)
            TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: tr.searchFriend,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

          if (_sent)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                const Icon(Icons.check_circle, size: 48, color: AppColors.stoicism),
                const SizedBox(height: 8),
                Text(tr.quoteSent, style: AppTypography.bodyLarge.copyWith(color: AppColors.stoicism)),
              ]),
            ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: AppTypography.bodySmall.copyWith(color: Colors.red)),
            ),

          // Results
          if (!_sent && _results.isNotEmpty)
            ...List.generate(_results.length, (i) {
              final user = _results[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.stoicism.withOpacity(0.1),
                  child: Text(
                    (user['display_name'] ?? '?')[0].toUpperCase(),
                    style: TextStyle(color: AppColors.stoicism),
                  ),
                ),
                title: Text(user['display_name'] ?? 'Unknown'),
                trailing: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.send, color: AppColors.stoicism),
                        onPressed: () => _shareWith(user['device_id']),
                      ),
              );
            }),

          if (!_sent && _results.isEmpty && _searchController.text.length >= 2 && !_loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(tr.friendNeedsMindScrolling,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
