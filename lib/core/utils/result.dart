sealed class Result<S, E> {
  const Result();
}

final class Success<S, E> extends Result<S, E> {
  final S data;
  const Success(this.data);
}

final class Failure<S, E> extends Result<S, E> {
  final E error;
  const Failure(this.error);
}