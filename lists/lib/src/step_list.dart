part of lists;

class StepList extends Object with ListMixin<int> {
  final int end;

  final int start;

  int _length;

  int _step;

  StepList(this.start, this.end, [int step]) {
    if (start == null) {
      throw new ArgumentError("start: $start");
    }

    if (end == null) {
      throw new ArgumentError("end: $end");
    }

    if (step == 0) {
      throw new ArgumentError("step: $step");
    }

    var count = end - start;
    if (step == null) {
      if (count > 0) {
        _step = 1;
      } else {
        _step = -1;
      }
    } else {
      _step = step;
    }

    _length = count ~/ _step;
    if (_length < 1) {
      _length = 1;
    } else {
      _length += 1;
    }
  }

  /// Returns the length of list.
  int get length => _length;

  /// Sets the length of list.
  void set length(int length) {
    throw new UnsupportedError("length=");
  }

  /// Returns the step.
  int get step => _step;

  int operator [](int index) {
    if (index == null) {
      throw new ArgumentError("index: $index");
    }

    if (index < 0 || index >= _length) {
      throw new RangeError(index);
    }

    return start + step * index;
  }

  void operator []=(int index, int value) {
    throw new UnsupportedError("operator []=");
  }

  /// Returns true if list contains the [value]; otherwise false.
  // ignore: strong_mode_invalid_method_override
  bool contains(int value) {
    if (value == null) {
      return false;
    }

    if (_length == 1) {
      return value == start;
    }

    var position = value - start;
    var index = position ~/ step;
    if (index >= 0 && index < _length) {
      if (position % index == 0) {
        return true;
      }
    }

    return false;
  }

  /// Returns the string representation of range.
  String toString() {
    if (step > 0) {
      return "[$start..$end; +$step]";
    } else {
      return "[$start..$end; $step]";
    }

  }
}
