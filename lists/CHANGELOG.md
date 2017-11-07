## 0.0.22

- Added `strong_mode` option

## 0.0.21

- Added `ListPointer` which can be used effectively when porting the programs written in the C language

## 0.0.20

- Added method `getAllSpace(RangeList range) => List<GroupedRangeList<E>>` to `SparseList<E>`

## 0.0.19

- Added method `getAlignedGroups(RangeList range) => List<GroupedRangeList<E>>` to `SparseList<E>`

## 0.0.18

- Fixed bug in `SparseList.getGroups()`

## 0.0.17

- Added field `frozen => bool` to `SparseList<E>`
- Added method `freeze() => void` to `SparseList<E>`
- `SparseList<E>` now can be frozen

## 0.0.16

- Fixed bug (change length of fixed list) in `SparseList.addGroup()`

## 0.0.15

- Fixed bug (change length of fixed list) in `SparseList.removeValues()`
- Fixed bug (change length of fixed list) in `SparseList.trim()`

## 0.0.14

- Added method `trim() => void` to `SparseList<E>`
- Fixed bug (decrease length) in `SparseList.removeValues()`
- Improved performance of modifications `SparseList<E>`

## 0.0.12

- Fixed bug (decrease length) in `SparseList.removeValues()`

## 0.0.11

- Fixed bug in `SparseList.removeValues()`

## 0.0.10

- Improved performance of modifications `SparseList<E>`
- Removed limitations on the bounds of the range in `SparseList.removeValues()`

## 0.0.9

- Added method `getIndexes() => Iterable<int> ` to `SparseList<E>`

## 0.0.8

- Added field `groups => List<GroupedRangeList<E>>` to `SparseList<E>`

## 0.0.7

- Added field `end => int` to `SparseList<E>` 
- Added field `start => int` to `SparseList<E>`

## 0.0.6

- Added class `SparseBoolList`
- Modified method in `SparseList<E>` from `getGroups(RangeList range)` to `getGroups([RangeList range])`

## 0.0.5

- Improved (up to 15%) the performance of the `SparseList.addGroup()` when the group added to the end

## 0.0.4

- Added class `GroupedRangeList<E>`
- Added class `SparseList<E>`
- Added method `includes(RangeList other) => bool` to `RangeList`
- Added method `intersection(RangeList other) => RangeList` to `RangeList`
- Added method `subtract(RangeList other) => List<RangeList>` to `RangeList`
- Added operator `+(RangeList other) => RangeList` to `RangeList`

