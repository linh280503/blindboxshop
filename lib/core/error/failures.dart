abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

/// Cache failure
class CacheFailure extends Failure {
  CacheFailure(super.message);
}

/// Network failure
class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

/// Validation failure
class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

/// Authentication failure
class AuthFailure extends Failure {
  AuthFailure(super.message);
}

/// Permission failure
class PermissionFailure extends Failure {
  PermissionFailure(super.message);
}

/// Not found failure
class NotFoundFailure extends Failure {
  NotFoundFailure(super.message);
}
