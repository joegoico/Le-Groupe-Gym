sealed class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class DuplicateFailure extends AppFailure {
  const DuplicateFailure(super.message);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

final class PermissionFailure extends AppFailure {
  const PermissionFailure(super.message);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message);
}

final class RelationFailure extends AppFailure {
  const RelationFailure(super.message);
}

final class SessionFailure extends AppFailure {
  const SessionFailure(super.message);
}
