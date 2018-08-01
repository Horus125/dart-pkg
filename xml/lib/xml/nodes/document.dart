library xml.nodes.document;

import 'package:xml/xml/nodes/doctype.dart';
import 'package:xml/xml/nodes/element.dart';
import 'package:xml/xml/nodes/node.dart';
import 'package:xml/xml/nodes/parent.dart';
import 'package:xml/xml/utils/node_type.dart';
import 'package:xml/xml/visitors/visitor.dart';

/// XML document node.
class XmlDocument extends XmlParent {
  /// Create a document node with `children`.
  XmlDocument([Iterable<XmlNode> children = const []])
      : super(childrenNodeTypes, children);

  /// Return the [XmlDoctype] element, or `null` if not defined.
  ///
  /// For example, the following code prints `<!DOCTYPE html>`:
  ///
  ///    var xml = '<!DOCTYPE html>'
  ///              '<html><body></body></html>';
  ///    print(parse(xml).doctypeElement);
  ///
  XmlDoctype get doctypeElement =>
      children.firstWhere((node) => node is XmlDoctype, orElse: () => null);

  /// Return the root [XmlElement] of the document, or throw a [StateError] if
  /// the document has no such element.
  ///
  /// For example, the following code prints `<books />`:
  ///
  ///     var xml = '<?xml version="1.0"?>'
  ///               '<books />';
  ///     print(parse(xml).rootElement);
  ///
  XmlElement get rootElement =>
      children.firstWhere((node) => node is XmlElement,
          orElse: () => throw new StateError('Empty XML document'));

  @override
  XmlDocument get document => this;

  @override
  String get text => null;

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitDocument(this);
}

/// Supported child node types.
final childrenNodeTypes = new Set<XmlNodeType>.from(const [
  XmlNodeType.CDATA,
  XmlNodeType.COMMENT,
  XmlNodeType.DOCUMENT_TYPE,
  XmlNodeType.ELEMENT,
  XmlNodeType.PROCESSING,
  XmlNodeType.TEXT,
]);
