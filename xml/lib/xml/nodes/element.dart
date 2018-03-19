library xml.nodes.element;

import 'package:xml/xml/nodes/attribute.dart' show XmlAttribute;
import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/nodes/parent.dart' show XmlParent;
import 'package:xml/xml/utils/name.dart' show XmlName;
import 'package:xml/xml/utils/name_matcher.dart' show createNameMatcher;
import 'package:xml/xml/utils/named.dart' show XmlNamed;
import 'package:xml/xml/utils/node_list.dart' show XmlNodeList;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// XML element node.
class XmlElement extends XmlParent implements XmlNamed {
  final XmlName _name;

  final _attributes = new XmlNodeList<XmlAttribute>(attributeNodeTypes);

  /// Create an element node with the provided `name`, `attributes`, and `children`.
  XmlElement(this._name,
      [Iterable<XmlAttribute> attributes = const [],
      Iterable<XmlNode> children = const []])
      : super(childrenNodeTypes, children) {
    _name.attachParent(this);
    _attributes.attachParent(this);
    _attributes.addAll(attributes);
  }

  /// Return the name of the node.
  @override
  XmlName get name => _name;

  /// Return the attribute nodes of this node.
  @override
  List<XmlAttribute> get attributes => _attributes;

  /// Return the attribute value with the given `name`.
  String getAttribute(String name, {String namespace}) {
    var attribute = getAttributeNode(name, namespace: namespace);
    return attribute != null ? attribute.value : null;
  }

  /// Return the attribute node with the given `name`.
  XmlAttribute getAttributeNode(String name, {String namespace}) {
    return _attributes.firstWhere(createNameMatcher(name, namespace),
        orElse: () => null);
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitElement(this);
}

/// Supported child node types.
final childrenNodeTypes = new Set<XmlNodeType>.from(const [
  XmlNodeType.CDATA,
  XmlNodeType.COMMENT,
  XmlNodeType.ELEMENT,
  XmlNodeType.PROCESSING,
  XmlNodeType.TEXT,
]);

/// Supported attribute node types.
final attributeNodeTypes = new Set<XmlNodeType>.from(const [
  XmlNodeType.ATTRIBUTE,
]);
