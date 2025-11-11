/// Base class untuk semua failure/error
abstract class Failure {
  final String message;
  
  const Failure(this.message);
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

