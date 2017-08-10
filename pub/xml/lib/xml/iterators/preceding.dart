library xml.iterators.preceding;

import 'dart:collection' show IterableBase;

import 'package:xml/xml/nodes/node.dart' show XmlNode;

/// Iterable to walk over the precedents of a node.
class XmlPrecedingIterable extends IterableBase<XmlNode> {
  final XmlNode start;

  XmlPrecedingIterable(this.start);

  @override
  Iterator<XmlNode> get iterator => new XmlPrecedingIterator(start);
}

/// Iterator to walk over the precedents of a node.
class XmlPrecedingIterator extends Iterator<XmlNode> {
  final XmlNode start;
  final List<XmlNode> todo = [];

  XmlPrecedingIterator(this.start) {
    todo.add(start.root);
  }

  @override
  XmlNode current;

  @override
  bool moveNext() {
    if (todo.isEmpty) {
      current = null;
      return false;
    } else {
      current = todo.removeLast();
      if (identical(current, start)) {
        current = null;
        todo.clear();
        return false;
      }
      todo.addAll(current.children.reversed);
      todo.addAll(current.attributes.reversed);
      return true;
    }
  }
}
