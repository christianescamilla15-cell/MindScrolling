/// Sealed result type for all repository calls.
///
/// Avoids throwing exceptions across the repository boundary into UI code.
/// Use [when] to exhaustively handle both cases, or [dataOrNull] / [errorOrNull]
/// for quick access.
///
/// Example:
/// ```dart
/// final result = await repo.fetchFeed();
/// result.when(
///   success: (quotes) => state = AsyncData(quotes),
///   failure: (msg, _) => state = AsyncError(msg, StackTrace.current),
/// );
/// ```
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isError => this is ApiError<T>;

  T? get dataOrNull => switch (this) {
        ApiSuccess<T> s => s.data,
        ApiError<T> _ => null,
      };

  String? get errorOrNull => switch (this) {
        ApiSuccess<T> _ => null,
        ApiError<T> e => e.message,
      };

  int? get codeOrNull => switch (this) {
        ApiSuccess<T> _ => null,
        ApiError<T> e => e.code,
      };

  /// Exhaustive pattern match helper.
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? code) failure,
  }) =>
      switch (this) {
        ApiSuccess<T> s => success(s.data),
        ApiError<T> e => failure(e.message, e.code),
      };

  /// Maps the success value, leaving errors unchanged.
  ApiResult<R> map<R>(R Function(T data) transform) => switch (this) {
        ApiSuccess<T> s => ApiSuccess(transform(s.data)),
        ApiError<T> e => ApiError(e.message, code: e.code),
      };
}

/// Successful result carrying [data].
final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

/// Error result carrying a human-readable [message] and optional HTTP [code].
final class ApiError<T> extends ApiResult<T> {
  const ApiError(this.message, {this.code});

  final String message;
  final int? code;
}
