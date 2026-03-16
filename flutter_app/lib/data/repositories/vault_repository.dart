import '../datasources/remote/vault_remote_ds.dart';
import '../models/quote_model.dart';
import '../../core/network/api_result.dart';

/// Repository for the user's saved quote vault.
/// Maintains an in-memory list alongside remote persistence so the UI
/// never has to wait for a network round-trip after the initial load.
class VaultRepository {
  final VaultRemoteDataSource _remote;

  final List<QuoteModel> _localVault = [];

  VaultRepository({required VaultRemoteDataSource remote}) : _remote = remote;

  // ── Queries ──────────────────────────────────────────────────────────────

  /// Returns true if [quoteId] is currently in the local vault cache.
  bool isInVault(String quoteId) =>
      _localVault.any((q) => q.id == quoteId);

  // ── Remote + local ────────────────────────────────────────────────────────

  /// Loads the vault from the server and populates the in-memory cache.
  Future<ApiResult<List<QuoteModel>>> getVault() async {
    try {
      final quotes = await _remote.getVault();
      _localVault
        ..clear()
        ..addAll(quotes);
      return ApiSuccess(List.unmodifiable(_localVault));
    } catch (e) {
      // Return whatever is already in memory rather than an error,
      // unless memory is empty.
      if (_localVault.isNotEmpty) {
        return ApiSuccess(List.unmodifiable(_localVault));
      }
      return ApiError('Failed to load vault: $e');
    }
  }

  /// Adds [quote] to the remote vault and the local cache.
  Future<ApiResult<void>> addToVault(QuoteModel quote) async {
    try {
      await _remote.saveToVault(quote.id);
      if (!isInVault(quote.id)) {
        _localVault.add(quote);
      }
      return const ApiSuccess(null);
    } catch (e) {
      return ApiError('Failed to add to vault: $e');
    }
  }

  /// Removes [quoteId] from the remote vault and the local cache.
  Future<ApiResult<void>> removeFromVault(String quoteId) async {
    try {
      await _remote.removeFromVault(quoteId);
      _localVault.removeWhere((q) => q.id == quoteId);
      return const ApiSuccess(null);
    } catch (e) {
      return ApiError('Failed to remove from vault: $e');
    }
  }
}
