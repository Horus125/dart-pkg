part of lists;

/**
 * List which are points to the other list at the specified index.
 *     var plist = new ListPointer(base, 20);
 *     print(plist[-1]); // base[19]
 *     print(plist[0]);  // base[20]
 */
class ListPointer<T> extends Object with ListMixin {
  final List<T> base;

  int _offset = 0;

  /**
   * Creates the list pointer.
   *
   * Parameters:
   *   [List] base
   *   Base list to be pointed.
   *
   *   [int] offset
   *   Offset in the base list.
   */
  ListPointer(this.base, [int offset = 0]) {
    if (base == null) {
      throw new ArgumentError.notNull("base");
    }

    if (offset == null) {
      throw new ArgumentError.notNull("offset");
    }

    _offset = offset;
  }

  int get length => base.length - _offset;

  void set length(int length) {
    throw new UnsupportedError("set length");
  }

  /**
   * Gets the offset.
   */
  int get offset => _offset;

  /**
   * Sets the offset.
   */
  void set offset(int offset) {
    if (offset == null) {
      throw new ArgumentError.notNull("offset");
    }

    _offset = offset;
  }

  ListPointer<T> operator +(other) {
    if (other is int) {
      return new ListPointer<T>(base, offset + (other as int));
    }

    throw new ArgumentError.value(other, "other");
  }

  ListPointer<T> increment(int n) {
    return new ListPointer<T>(base, offset + n);
  }

  ListPointer<T> operator -(other) {
    if (other is int) {
      return new ListPointer<T>(base, offset - other);
    }

    throw new ArgumentError.value(other, "other");
  }

  bool operator <(other) {
    if (other is ListPointer) {
      if (identical(base, other.base)) {
        return offset < other.offset;
      }
    } else if (other is List) {
      if (identical(base, other)) {
        return offset < 0;
      }
    }

    return false;
  }

  bool operator <=(other) {
    if (other is ListPointer) {
      if (identical(base, other.base)) {
        return offset <= other.offset;
      }
    } else if (other is List) {
      if (identical(base, other)) {
        return offset <= 0;
      }
    }

    return false;
  }

  bool operator ==(other) {
    if (other is ListPointer) {
      if (identical(base, other.base)) {
        if (offset == other.offset) {
          return true;
        }
      }
    } else if (other is List) {
      if (identical(base, other)) {
        if (offset == 0) {
          return true;
        }
      }
    }

    return false;
  }

  bool operator >(other) {
    if (other is ListPointer) {
      if (identical(base, other.base)) {
        return offset > other.offset;
      }
    } else if (other is List) {
      if (identical(base, other)) {
        return offset > 0;
      }
    }

    return false;
  }

  bool operator >=(other) {
    if (other is ListPointer) {
      if (identical(base, other.base)) {
        return offset >= other.offset;
      }
    } else if (other is List) {
      if (identical(base, other)) {
        return offset >= 0;
      }
    }

    return false;
  }

  T operator [](int index) {
    if (index == null) {
      throw new ArgumentError.notNull("index");
    }

    return base[_offset + index];
  }

  void operator []=(int index, value) {
    base[_offset + index] = value as T;
  }
}
