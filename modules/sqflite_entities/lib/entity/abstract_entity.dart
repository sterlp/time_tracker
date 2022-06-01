abstract class AbstractEntity {
  int? id;

  @override
  bool operator == (Object other) {
    if (other is AbstractEntity && id != null && other.id != null) {
      return id == other.id && this.runtimeType == other.runtimeType;
    } else {
      return super == other;
    }
  }

  @override
  int get hashCode {
    if (id == null) {
      return super.hashCode;
    } else {
      return id.hashCode;
    }
  }
}
