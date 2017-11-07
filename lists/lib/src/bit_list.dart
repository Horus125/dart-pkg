part of lists;

class BitList extends Object with ListMixin<bool> {
  int _length;

  List<int> _list;

  BitList(int length, [bool fill]) {
    if (length == null || length < 0) {
      throw new ArgumentError("length: $length");
    }

    _length = length;
    var slots = (length - 1) ~/ 30 + 1;
    if (fill == true) {
      _list = new List<int>.filled(slots, 0x3fffffff);
    } else {
      _list = new List<int>.filled(slots, 0);
    }
  }

  bool operator [](int index) {
    if (index == null) {
      throw new ArgumentError("index: $index");
    }

    if (index < 0 || index >= _length) {
      throw new RangeError(index);
    }

    var slot = index ~/ 30;
    var position = slot * 30;
    var mask = 1 << (index - position);
    return (_list[slot] & mask) != 0;
  }

  void operator []=(int index, bool value) {
    if (index == null) {
      throw new ArgumentError("index: $index");
    }

    if (index < 0 || index >= _length) {
      throw new RangeError(index);
    }

    if (value == null) {
      throw new ArgumentError("value: $value");
    }

    var slot = index ~/ 30;
    var position = slot * 30;
    var mask = 1 << (index - position);
    if (value) {
      _list[slot] |= mask;
    } else {
      _list[slot] &= 0x3fffffff ^ mask;
    }
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

  /**
   * Returns the state at specified [index].
   */
  bool get(int index) => this[index];

  /**
   * Sets the state to true at specified [index].
   */
  void set(int index) {
    this[index] = true;
  }

  /**
   * Resets the state to false at specified [index].
   */
  void reset(int index) {
    this[index] = false;
  }
}
