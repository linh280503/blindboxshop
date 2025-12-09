/// Base class for use cases
/// T: Return type
/// P: Parameters type
abstract class UseCase<T, P> {
  Future<T> call(P params);
}

/// Use case without parameters
abstract class UseCaseNoParams<T> {
  Future<T> call();
}

/// Use case with stream return type
abstract class StreamUseCase<T, P> {
  Stream<T> call(P params);
}

/// Use case with stream return type, no parameters
abstract class StreamUseCaseNoParams<T> {
  Stream<T> call();
}
