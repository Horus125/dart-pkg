part of lists;

/**
 * Sparse list based on the grouped range lists.
 */
// TODO: sublist
// TODO: toList
class SparseList<E> extends Object with ListMixin<E> {
  final E defaultValue;

  bool _fixedLength = false;

  bool _frozen = false;

  List<GroupedRangeList<E>> _groups = <GroupedRangeList<E>>[];

  int _length;

  SparseList({this.defaultValue, int length}) {
    if (length == null) {
      length = 0;
    } else {
      if (length < 0) {
        throw new ArgumentError("length: $length");
      }

      _fixedLength = true;
    }

    _length = length;
  }

  /**
   * Returns the 'end' value from the last group (if available); otherwise null.
   */
  int get end {
    var length = _groups.length;
    if (_groups.length == 0) {
      return null;
    }

    return _groups[length - 1].end;
  }

  /**
   * Returns true if the list is frozen; otherwise false.
   */
  bool get frozen {
    return _frozen;
  }

  /**
   * Returns a read-only list of the groups.
   */
  List<GroupedRangeList<E>> get groups => new UnmodifiableListView<GroupedRangeList<E>>(_groups);

  /**
   * Returns the number of groups.
   */
  int get groupCount => _groups.length;

  /**
   * Returns the length of list.
   */
  int get length => _length;

  /**
   * Sets the length of list.
   */
  void set length(int length) {
    if (length == null) {
      throw new ArgumentError("length: $length");
    }

    if (_fixedLength) {
      throw new StateError("Unable to set the length of a fixed list.");
    }

    if (frozen) {
      _errorModificationNotAllowed();
    }

    if (length < 0) {
      throw new RangeError(length);
    }

    if (_length == length) {
      return;
    }

    if (_length < length) {
      _length = length;
      return;
    }

    if (length == 0) {
      _groups.length = 0;
      _length = 0;
      return;
    }

    _resetValues(new RangeList(length, _length - 1));
    _length = length;
  }

  /**
   * Returns the 'start' value from the first group (if available); otherwise
   * null.
   */
  int get start {
    if (_groups.length == 0) {
      return null;
    }

    return _groups[0].start;
  }

  E operator [](int index) {
    if (index == null) {
      throw new ArgumentError("index: $index");
    }

    if (index < 0 || index >= _length) {
      throw new RangeError(index);
    }

    var right = _groups.length;
    if (right == 0) {
      return defaultValue;
    }

    if (right == 1) {
      var group = _groups[0];
      if (index <= group.end && index >= group.start) {
        return group.key;
      } else {
        return defaultValue;
      }
    }

    var left = 0;
    var key = index;
    int middle;
    var value = defaultValue;
    while (left < right) {
      middle = (left + right) >> 1;
      var group = _groups[middle];
      if (group.end < key) {
        left = middle + 1;
      } else {
        if (key >= group.start) {
          return group.key;
        }

        right = middle;
      }
    }

    return value;
  }

  void operator []=(int index, E value) {
    if (index == null) {
      throw new ArgumentError("index: $index");
    }

    if (frozen) {
      _errorModificationNotAllowed();
    }

    if (index < 0 || index >= _length) {
      throw new RangeError(index);
    }

    if (value == defaultValue) {
      _resetValues(new RangeList(index, index));
    } else {
      setGroup(new GroupedRangeList(index, index, value));
    }
  }

  /**
   * Sets the values ​​in accordance with the specified [group] and increases
   * (if required) the length up to (range.end + 1).
   */
  void addGroup(GroupedRangeList<E> group) {
    if (group == null) {
      throw new ArgumentError("group: $group");
    }

    if (_fixedLength) {
      throw new StateError("Unable to add the group into fixed list.");
    }

    if (frozen) {
      _errorModificationNotAllowed();
    }

    if (group.start < 0) {
      throw new RangeError(group.start);
    }

    _setGroup(group);
    if (_length < group.end + 1) {
      _length = group.end + 1;
    }
  }

  /**
   * Returns all groups that intersects with the specified [range] which being
   * expanded (with default value) or shrunk to specified [range].
   */
  List<GroupedRangeList<E>> getAlignedGroups(RangeList range) {
    if (range == null) {
      throw new ArgumentError("range: $range");
    }

    var groups = getGroups(range).toList();
    var length = groups.length;
    if (length == 0) {
      return [new GroupedRangeList<E>(range.start, range.end, defaultValue)];
    }

    var first = groups.first;
    if (range.start > first.start) {
      groups[0] = first.intersection(range);
    } else if (range.start < first.start) {
      var insertion = new GroupedRangeList<E>(range.start, first.start - 1, defaultValue);
      groups.insert(0, insertion);
    }

    var last = groups.last;
    if (range.end > last.end) {
      var addition = new GroupedRangeList<E>(last.end + 1, range.end, defaultValue);
      groups.add(addition);
    } else if (range.end < last.end) {
      groups[groups.length - 1] = last.intersection(range);
    }

    return groups;
  }

  /**
   * Returns all space as groups (including synthetic groups with default
   * values from not filled space) that intersects with the specified [range]
   * which being expanded (with default value) or shrunk to specified [range].
   */
  List<GroupedRangeList<E>> getAllSpace(RangeList range) {
    if (range == null) {
      throw new ArgumentError("range: $range");
    }

    var groups = <GroupedRangeList<E>>[];
    GroupedRangeList<E> previous;
    for (var group in getAlignedGroups(range)) {
      if (previous != null) {
        var start = previous.end + 1;
        var delta = group.start - start;
        if (delta > 0) {
          // Adds the synthetic group
          groups.add(new GroupedRangeList<E>(start, group.start - 1, defaultValue));
        }
      }

      groups.add(group);
      previous = group;
    }

    return groups;
  }

  /**
   * Returns all groups that intersects with the specified [range].
   */
  Iterable<GroupedRangeList<E>> getGroups([RangeList range]) {
    if (range == null) {
      return _groups.getRange(0, _groups.length);
    }

    var length = _groups.length;
    var left = _findNearestIndex(0, length, range.start);
    var firstIndex = -1;
    var lastIndex = -1;
    for (var i = left; i < length; i++) {
      if (_groups[i].intersect(range)) {
        if (firstIndex == -1) {
          firstIndex = i;
          lastIndex = i;
        } else {
          lastIndex = i;
        }
      } else if (firstIndex != -1) {
        break;
      }
    }

    if (firstIndex == -1) {
      return <GroupedRangeList<E>>[];
    }

    return _groups.getRange(firstIndex, lastIndex + 1);
  }

  /**
   * Makes the list unmodifiable.
   */
  void freeze() {
    _frozen = true;
  }

  /**
   * Returns the indexes of the elements with a value.
   */
  Iterable<int> getIndexes() {
    return new _SparseListIndexesIterator(this);
  }

  /**
   * Removes the values in the specified range and decreases (if possible) the
   * length down to (range.start).
   */
  void removeValues(RangeList range) {
    if (range == null) {
      throw new ArgumentError("range: $range");
    }

    if (_fixedLength) {
      throw new StateError("Unable to remove the values from a fixed list.");
    }

    if (frozen) {
      _errorModificationNotAllowed();
    }

    if (range.start < 0) {
      throw new RangeError(range.start);
    }

    _resetValues(range);
    if (_groups.length == 0) {
      if (_length > range.start) {
        _length = range.start;
      }

    } else {
      var length = _groups.last.end + 1;
      if (length > range.start && length < range.end) {
        length = range.start;
      }

      _length = length;
    }
  }

  /**
   * Resets the values in the specified [range] to the default values.
   */
  void resetValues(RangeList range) {
    if (range == null) {
      throw new ArgumentError("range: $range");
    }

    if (frozen) {
      _errorModificationNotAllowed();
    }

    if (range.start < 0 || range.start >= _length) {
      throw new RangeError(range.start);
    }

    if (range.end >= _length) {
      throw new RangeError(range.end);
    }

    _resetValues(range);
  }

  /**
   * Sets the values ​​in accordance with the specified [group].
   */
  void setGroup(GroupedRangeList<E> group) {
    if (group == null) {
      throw new ArgumentError("group: $group");
    }

    if (frozen) {
      _errorModificationNotAllowed();
    }

    if (group.start < 0 || group.start >= _length) {
      throw new RangeError(group.start);
    }

    if (group.end >= _length) {
      throw new RangeError(group.end);
    }

    _setGroup(group);
  }

  /**
   * Sets the length of list equal to the last not empty index + 1; otherwise
   * sets the length to 0.
   */
  void trim() {
    if (_fixedLength) {
      throw new StateError("Unable to trim a fixed list.");
    }

    if (frozen) {
      _errorModificationNotAllowed();
    }

    var groupCount = _groups.length;
    if (groupCount == 0) {
      _length = 0;
    } else {
      _length = _groups[groupCount - 1].end + 1;
    }
  }

  void _errorModificationNotAllowed() {
    throw new StateError("Unable to modify the frozen list.");
  }

  int _findNearestIndex(int left, int right, int key) {
    if (right == 0) {
      return 0;
    }

    int middle;
    while (left < right) {
      middle = (left + right) >> 1;
      if (_groups[middle].end < key) {
        left = middle + 1;
      } else {
        right = middle;
      }
    }

    if (left > 0) {
      left--;
    }

    return left;
  }

  void _resetValues(RangeList range) {
    var rangeEnd = range.end;
    var rangeStart = range.start;
    var length = _groups.length;
    var left = _findNearestIndex(0, length, range.start);
    var affected = <int>[];
    var insertAt = -1;
    for (var i = left; i < length; i++) {
      var current = _groups[i];
      if (range.intersect(current)) {
        if (range.includes(current)) {
          affected.add(i);
        } else {
          var parts = current.subtract(range);
          if (parts.length == 2) {
            _groups.insert(i, parts[0]);
            _groups[i + 1] = parts[1];
            return;
          } else {
            if (rangeStart <= current.start) {
              _groups[i] = parts.first;
              break;
            } else {
              _groups[i] = parts.first;
            }
          }
        }
      }
    }

    if (affected.length != 0) {
      var firstIndex = affected.first;
      var lastIndex = affected.last;
      var first = _groups[firstIndex];
      var last = _groups[lastIndex];
      var start = first.start < rangeStart ? first.start : rangeStart;
      var end = last.end > rangeEnd ? last.end : rangeEnd;
      if (firstIndex == lastIndex) {
        _groups.removeAt(firstIndex);
      } else {
        _groups.removeRange(firstIndex, lastIndex + 1);
      }
    }
  }

  void _setGroup(GroupedRangeList<E> group) {
    var groupKey = group.key;
    if (groupKey == defaultValue) {
      _resetValues(group);
      return;
    }

    var length = _groups.length;
    if (length == 0) {
      _groups.add(group);
      return;
    }

    var groupStart = group.start;
    var lastEnd = _groups[length - 1].end;
    int left;
    if (groupStart == lastEnd + 1) {
      left = length - 1;
    } else if (groupStart > lastEnd) {
      _groups.add(group);
      return;
    } else {
      left = _findNearestIndex(0, length, group.start);
    }

    var groupEnd = group.end;
    var affected = <int>[];
    var insertAt = -1;
    for (var i = left; i < length; i++) {
      var current = _groups[i];
      var currentEnd = current.end;
      var currentKey = current.key;
      var currentStart = current.start;
      if (group.intersect(current)) {
        if (group.includes(current)) {
          affected.add(i);
        } else if (currentKey == groupKey) {
          affected.add(i);
        } else {
          var parts = current.subtract(group);
          if (parts.length == 2) {
            _groups.insertAll(i, [parts[0], group]);
            _groups[i + 2] = parts[1];
            return;
          } else {
            if (groupStart <= currentStart) {
              _groups.insert(i, new GroupedRangeList(currentStart, groupEnd, groupKey));
              _groups[i + 1] = parts.first;
              affected.add(i);
              break;
            } else {
              _groups.insert(i, parts.first);
              _groups[i + 1] = new GroupedRangeList(groupStart, currentEnd, groupKey);
              length++;
            }
          }
        }

      } else if (groupEnd + 1 == currentStart && currentKey == groupKey) {
        affected.add(i);
        break;
      } else if (currentEnd + 1 == groupStart && currentKey == groupKey) {
        affected.add(i);
      } else if (insertAt == -1 && groupEnd < currentStart) {
        insertAt = i;
        break;
      }
    }

    if (affected.length == 0) {
      if (insertAt != -1) {
        _groups.insert(insertAt, group);
      } else {
        _groups.add(group);
      }

      return;
    }

    if (affected.length != 0) {
      var firstIndex = affected.first;
      var lastIndex = affected.last;
      var first = _groups[firstIndex];
      var last = _groups[lastIndex];
      var start = first.start < groupStart ? first.start : groupStart;
      var end = last.end > groupEnd ? last.end : groupEnd;
      var newGroup = new GroupedRangeList(start, end, groupKey);
      if (firstIndex == lastIndex) {
        _groups[firstIndex] = newGroup;
      } else {
        _groups.removeRange(firstIndex, lastIndex + 1);
        _groups.insert(firstIndex, newGroup);
      }
    }
  }
}

class _SparseListIndexesIterator extends Object with IterableMixin<int> implements Iterator<int> {
  int _count;

  int _current;

  int _end;

  List<GroupedRangeList> _groups;

  int _index;

  int _start;

  int _state = 0;

  _SparseListIndexesIterator(SparseList list) {
    _groups = list.groups;
  }

  int get current => _current;

  Iterator<int> get iterator => this;

  bool moveNext() {
    while (true) {
      switch (_state) {
        case 0:
          _count = _groups.length;
          if (_count != 0) {
            var group = _groups[0];
            _index = 0;
            _end = group.end;
            _start = group.start;
            _state = 1;
            break;
          } else {
            _state = 2;
          }

          break;
        case 1:
          if (_start <= _end) {
            _current = _start++;
            return true;
          }

          if (++_index == _count) {
            _state = 2;
            return false;
          }

          var group = _groups[_index];
          _end = group.end;
          _start = group.start;
          break;
        case 2:
          return false;
      }
    }
  }
}
