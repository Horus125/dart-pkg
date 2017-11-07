part of lists;

/// Range list.
class RangeList extends Object with ListMixin<int> {
  final int end;

  final int start;

  int _length;

  RangeList(this.start, this.end) {
    if (start == null) {
      throw new ArgumentError("start: $start");
    }

    if (end == null) {
      throw new ArgumentError("end: $end");
    }

    if (start > end) {
      throw new StateError("Start '$start' greater then end '$end'");
    }

    _length = end - start + 1;
  }

  /// Returns the length of list.
  int get length => _length;

  /// Sets the length of list.
  void set length(int length) {
    throw new UnsupportedError("length=");
  }

  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is RangeList) {
      return start == other.start && end == other.end;
    }

    return false;
  }

  RangeList operator +(RangeList other) {
    if (other == null) {
      throw new ArgumentError("other: $other");
    }

    int start;
    int end;
    if (this.start < other.start) {
      start = this.start;
    } else {
      start = other.start;
    }

    if (this.end > other.end) {
      end = this.end;
    } else {
      end = other.end;
    }

    return new RangeList(start, end);
  }

  int operator [](int index) {
    if (index == null) {
      throw new ArgumentError("index: $index");
    }

    if (index < 0 || index >= _length) {
      throw new RangeError(index);
    }

    return start + index;
  }

  void operator []=(int index, int value) {
    throw new UnsupportedError("operator []=");
  }

  /// Returns true if range list contains the [value]; otherwise false.
  // ignore: strong_mode_invalid_method_override
  bool contains(int value) {
    if (value == null || value > end || value < start) {
      return false;
    }

    return true;
  }

  /// Returns true if this range list includes [other]; otherwise false.
  bool includes(RangeList other) {
    if (other == null) {
      throw new ArgumentError("other: $other");
    }

    return (other.start >= start && other.start <= end) && (other.end >= start && other.end <= end);
  }

  /// Returns true if this range list intersect [other]; otherwise false.
  bool intersect(RangeList other) {
    if (other == null) {
      throw new ArgumentError("other: $other");
    }

    return (start <= other.start && end >= other.start) || (other.start <= start && other.end >= start);
  }

  /// Returns the intersection of this range list and the [other] range list;
  /// otherwise null.
  RangeList intersection(RangeList other) {
    if (other == null) {
      throw new ArgumentError("other: $other");
    }

    if (!intersect(other)) {
      return null;
    }

    if (this == other) {
      return new RangeList(this.start, this.end);
    }

    var start = this.start;
    if (other.start > start) {
      start = other.start;
    }

    var end = this.end;
    if (other.end < end) {
      end = other.end;
    }

    return new RangeList(start, end);
  }

  /// Subtracts from this range the [other] range and returns the the resulting
  /// ranges.
  List<RangeList> subtract(RangeList other) {
    if (other == null) {
      throw new ArgumentError("other: $other");
    }

    var result = <RangeList>[];
    if (!intersect(other)) {
      return result;
    }

    if (start < other.start) {
      result.add(new RangeList(start, other.start - 1));
    }

    if (other.end < end) {
      result.add(new RangeList(other.end + 1, end));
    }

    return result;
  }

  /// Returns the list of elements with specified step.
  StepList toStepList(int step) => new StepList(start, end, step);

  /// Returns the string representation of range list.
  String toString() {
    return "[$start..$end]";
  }
}
