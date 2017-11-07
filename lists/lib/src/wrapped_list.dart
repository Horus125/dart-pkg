part of lists;

class WrappedList<E> extends Object with ListMixin<E> {
  List<E> _source;

  WrappedList(List<E> source) {
    if (source == null) {
      throw new ArgumentError("source: $source");
    }

    _source = source;
  }

  E operator [](int index) => _source[index];

  void operator []=(int index, E value) {
    throw new UnsupportedError("operator []=");
  }

  /**
   * Returns the length of list.
   */
  int get length => _source.length;

  /**
   * Sets the length of list.
   */
  void set length(int length) {
    throw new UnsupportedError("length=");
  }

  /**
   * Returns the string representation of range.
   */
  String toString() => _source.toString();
}
