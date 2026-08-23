abstract class AbstractEntity<E> {
  E? id;

  AbstractEntity([this.id]);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AbstractEntity &&
            id != null &&
            id == other.id);
  }

  @override
  int get hashCode => id?.hashCode ?? identityHashCode(this);
}
