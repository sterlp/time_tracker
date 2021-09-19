
E? firstWhere<E>(List<E> list, bool Function(E element) test) {
  for (final element in list) {
    if (test(element)) return element;
  }
  return null;
}