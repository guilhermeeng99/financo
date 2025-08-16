class Either<L, R> {
  factory Either.right(R right) => Either._right(right);

  factory Either.left(L left) => Either._left(left);
  const Either._right(this._right) : _left = null;

  const Either._left(this._left) : _right = null;
  final L? _left;
  final R? _right;

  bool get isLeft => _left != null;
  bool get isRight => _right != null;

  L get left => _left!;
  R get right => _right!;

  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight) {
    if (isLeft) return ifLeft(_left as L);
    return ifRight(_right as R);
  }
}
