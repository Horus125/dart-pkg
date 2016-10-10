// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file

// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.util.dart_type_utilities;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/ast/ast.dart';

typedef bool AstNodePredicate(AstNode node);

class DartTypeUtilities {
  static bool unrelatedTypes(DartType leftType, DartType rightType) {
    if (leftType == null ||
        leftType.isBottom ||
        leftType.isDynamic ||
        rightType == null ||
        rightType.isBottom ||
        rightType.isDynamic) {
      return false;
    }
    if (leftType == rightType ||
        leftType.isMoreSpecificThan(rightType) ||
        rightType.isMoreSpecificThan(leftType)) {
      return false;
    }
    Element leftElement = leftType.element;
    Element rightElement = rightType.element;
    if (leftElement is ClassElement && rightElement is ClassElement) {
      return leftElement.supertype.isObject ||
          leftElement.supertype != rightElement.supertype;
    }
    return false;
  }

  static bool implementsInterface(
      DartType type, String interface, String library) {
    bool predicate(InterfaceType i) =>
        i.name == interface && i.element.library.name == library;
    ClassElement element = type.element;
    return predicate(type) ||
        !element.isSynthetic &&
            type is InterfaceType &&
            element.allSupertypes.any(predicate);
  }

  static bool implementsAnyInterface(
      DartType type, Iterable<InterfaceTypeDefinition> definitions) {
    bool predicate(InterfaceType i) => definitions
        .any((d) => i.name == d.name && i.element.library.name == d.library);
    ClassElement element = type.element;
    return predicate(type) ||
        !element.isSynthetic &&
            type is InterfaceType &&
            element.allSupertypes.any(predicate);
  }

  static bool extendsClass(DartType type, String className, String library) =>
      type != null &&
          type.name == className &&
          type.element.library.name == library ||
      (type is InterfaceType &&
          extendsClass(type.superclass, className, library));

  /// Builds the list resulting from traversing the node in DFS and does not
  /// include the node itself.
  static List<AstNode> traverseNodesInDFS(AstNode node) {
    List<AstNode> nodes = [];
    node.childEntities.where((c) => c is AstNode).forEach((c) {
      nodes.add(c);
      nodes.addAll(traverseNodesInDFS(c));
    });
    return nodes;
  }
}

class InterfaceTypeDefinition {
  final String name;
  final String library;

  InterfaceTypeDefinition(this.name, this.library);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is InterfaceTypeDefinition &&
        this.name == other.name &&
        this.library == other.library;
  }

  @override
  int get hashCode {
    return name.hashCode ^ library.hashCode;
  }
}
