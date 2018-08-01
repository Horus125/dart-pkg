library xml.grammar;

import 'package:petitparser/petitparser.dart';
import 'package:xml/xml/production.dart';
import 'package:xml/xml/utils/attribute_type.dart';
import 'package:xml/xml/utils/token.dart';

/// XML grammar definition with [TNode] and [TName].
abstract class XmlGrammarDefinition<TNode, TName>
    extends XmlProductionDefinition {
  // Callbacks used to build the XML AST.
  TNode createAttribute(TName name, String text, XmlAttributeType type);
  TNode createComment(String text);
  TNode createCDATA(String text);
  TNode createDoctype(String text);
  TNode createDocument(Iterable<TNode> children);
  TNode createElement(
      TName name, Iterable<TNode> attributes, Iterable<TNode> children);
  TNode createProcessing(String target, String text);
  TName createQualified(String name);
  TNode createText(String text);

  // Connects the productions and the XML AST callbacks.

  @override
  Parser attribute() => super
      .attribute()
      .map((each) => createAttribute(each[0] as TName, each[4][0], each[4][1]));

  @override
  Parser attributeValueDouble() => super
      .attributeValueDouble()
      .map((each) => [each[1], XmlAttributeType.DOUBLE_QUOTE]);

  @override
  Parser attributeValueSingle() => super
      .attributeValueSingle()
      .map((each) => [each[1], XmlAttributeType.SINGLE_QUOTE]);

  @override
  Parser comment() => super.comment().map((each) => createComment(each[1]));

  @override
  Parser cdata() => super.cdata().map((each) => createCDATA(each[1]));

  @override
  Parser doctype() => super.doctype().map((each) => createDoctype(each[2]));

  @override
  Parser document() => super.document().map((each) {
        var nodes = [];
        nodes.addAll(each[0]);
        if (each[1] != null) {
          nodes.add(each[1]);
        }
        nodes.addAll(each[2]);
        nodes.add(each[3]);
        nodes.addAll(each[4]);
        return createDocument(new List<TNode>.from(nodes));
      });

  @override
  Parser element() => super.element().map((list) {
        if (list[4] == XmlToken.closeEndElement) {
          return createElement(
              list[1] as TName, new List<TNode>.from(list[2]), []);
        } else {
          if (list[1] == list[4][3]) {
            return createElement(
                list[1] as TName,
                new List<TNode>.from(list[2]),
                new List<TNode>.from(list[4][1]));
          } else {
            throw new ArgumentError(
                'Expected </${list[1]}>, but found </${list[4][3]}>');
          }
        }
      });

  @override
  Parser processing() =>
      super.processing().map((each) => createProcessing(each[1], each[2]));

  @override
  Parser qualified() => super.qualified().map(createQualified);

  @override
  Parser characterData() => super.characterData().map(createText);

  @override
  Parser spaceText() => super.spaceText().map(createText);
}
