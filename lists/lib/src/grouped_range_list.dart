part of lists;

/**
 * The [RangeList] with key.
 */
class GroupedRangeList<TKey> extends RangeList {
  final TKey key;

  GroupedRangeList(int start, int end, this.key) : super(start, end);

  /**
   * Returns the intersection of this grouped range list and the [other] grouped
   * range list; otherwise null.
   */
  GroupedRangeList<TKey> intersection(RangeList other) {
    if (other == null) {
      throw new ArgumentError("other: $other");
    }

    if (!intersect(other)) {
      return null;
    }

    if (this == other) {
      return new GroupedRangeList<TKey>(this.start, this.end, key);
    }

    var start = this.start;
    if (other.start > start) {
      start = other.start;
    }

    var end = this.end;
    if (other.end < end) {
      end = other.end;
    }

    return new GroupedRangeList<TKey>(start, end, key);
  }

  /**
   * Subtracts from this grouped range list the [other] grouped range list and
   * returns the the resulting grouped ranges.
   */
  List<GroupedRangeList<TKey>> subtract(RangeList other) {
    if (other == null) {
      throw new ArgumentError("other: $other");
    }

    var result = <GroupedRangeList<TKey>>[];
    if (!intersect(other)) {
      return result;
    }

    if (start < other.start) {
      result.add(new GroupedRangeList<TKey>(start, other.start - 1, key));
    }

    if (other.end < end) {
      result.add(new GroupedRangeList<TKey>(other.end + 1, end, key));
    }

    return result;
  }

  /**
   * Returns the string representation of grouped range list.
   */
  String toString() {
    return "[$start..$end]($key)";
  }
}
