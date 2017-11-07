part of lists;

class FilledList<E> extends Object with ListMixin<E> {
  E _fill;

  int _length;

  FilledList(int length, E fill) {
    if (length == null || length < 0) {
      throw new ArgumentError("length: $length");
    }

    _fill = fill;
    _length = length;
  }

  E operator [](int index) {
    if (index == null) {
      throw new ArgumentError("index: $index");
    }

    if (index < 0 || index >= _length) {
      throw new RangeError(index);
    }

    return _fill;
  }

  void operator []=(int index, E value) {
    throw new UnsupportedError("operator []=");
  }

  /**
   * Returns the length of list.
   */
  int get length => _length;

  /**
   * Sets the length of list.
   */
  void set length(int length) {
    throw new UnsupportedError("length=");
  }
}
