sealed class Either<L, R> {
  const Either();

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L? get leftOrNull => isLeft ? (this as Left<L, R>).value : null;
  R? get rightOrNull => isRight ? (this as Right<L, R>).value : null;
}

class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onLeft(value);
  }
}

class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onRight(value);
  }
}
