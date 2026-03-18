import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/core_providers.dart';
import '../../core/utils/haptics_service.dart';
import '../../shared/extensions/context_extensions.dart';
import 'premium_controller.dart';

/// Screen for redeeming MindScrolling Inside activation codes.
///
/// Code format: MIND-XXXX-XXXX
/// Validates via POST /premium/redeem on the backend.
class RedeemCodeScreen extends ConsumerStatefulWidget {
  const RedeemCodeScreen({super.key});

  @override
  ConsumerState<RedeemCodeScreen> createState() => _RedeemCodeScreenState();
}

class _RedeemCodeScreenState extends ConsumerState<RedeemCodeScreen> {
  final _controller = TextEditingController();
  bool _isRedeeming = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redeemCode() async {
    final code = _controller.text.trim().toUpperCase();
    // MIND-XXXX-XXXX format = 14 characters
    if (!RegExp(r'^MIND-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(code)) {
      setState(() => _error = context.tr.invalidCodeFormat);
      return;
    }

    setState(() {
      _isRedeeming = true;
      _error = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final response = await api.post('/premium/redeem', body: {'code': code});

      if (response['success'] == true) {
        HapticsService.heavyImpact();
        setState(() {
          _success = true;
          _isRedeeming = false;
        });
        // Refresh premium state
        ref.read(premiumControllerProvider.notifier).checkStatus();
      } else {
        setState(() {
          _error = response['error'] ?? context.tr.redeemFailed;
          _isRedeeming = false;
        });
      }
    } catch (e) {
      final msg = e.toString();
      String errorMsg;
      if (msg.contains('404') || msg.contains('CODE_NOT_FOUND')) {
        errorMsg = context.tr.codeNotFound;
      } else if (msg.contains('409') || msg.contains('ALREADY_REDEEMED')) {
        errorMsg = context.tr.codeAlreadyUsed;
      } else if (msg.contains('410')) {
        errorMsg = context.tr.codeExpired;
      } else {
        errorMsg = context.tr.redeemFailed;
      }
      HapticsService.warningFeedback();
      setState(() {
        _error = errorMsg;
        _isRedeeming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/feed'),
        ),
        title: Text(context.tr.redeemCode, style: AppTypography.displaySmall),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _success ? _SuccessView() : _RedeemForm(),
        ),
      ),
    );
  }

  Widget _SuccessView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.stoicism.withOpacity(0.12),
              border: Border.all(
                color: AppColors.stoicism.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: AppColors.stoicism,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'MindScrolling Inside',
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.stoicism,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr.redeemSuccess,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.go('/feed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.stoicism,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(context.tr.startScrolling, style: AppTypography.buttonLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _RedeemForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),

        // Icon
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.stoicism.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.vpn_key_rounded,
              size: 28,
              color: AppColors.stoicism,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Center(
          child: Text(
            context.tr.redeemCodeTitle,
            style: AppTypography.displaySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            context.tr.redeemCodeSubtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 32),

        // Code input
        TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: AppTypography.displaySmall.copyWith(
            letterSpacing: 3,
            fontSize: 20,
          ),
          decoration: InputDecoration(
            hintText: 'MIND-XXXX-XXXX',
            hintStyle: AppTypography.displaySmall.copyWith(
              color: AppColors.textMuted.withOpacity(0.3),
              letterSpacing: 3,
              fontSize: 20,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.stoicism, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
            LengthLimitingTextInputFormatter(14), // MIND-XXXX-XXXX
          ],
        ),

        // Error message
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFF6B6B).withOpacity(0.3),
              ),
            ),
            child: Text(
              _error!,
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFFFF6B6B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Redeem button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isRedeeming ? null : _redeemCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.stoicism,
              foregroundColor: AppColors.background,
              disabledBackgroundColor: AppColors.stoicism.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isRedeeming
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.background,
                    ),
                  )
                : Text(context.tr.activateCode, style: AppTypography.buttonLabel),
          ),
        ),
      ],
    );
  }
}
