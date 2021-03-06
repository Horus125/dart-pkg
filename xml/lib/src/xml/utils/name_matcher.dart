library xml.utils.name_matcher;

import 'package:xml/src/xml/utils/named.dart';

/// Internal function type to match named elements.
typedef XmlNameMatcher = bool Function(XmlNamed named);

/// Internal factory to create element matchers.
XmlNameMatcher createNameMatcher(String name, String namespace) {
  if (name == null) {
    throw ArgumentError('Illegal name matcher.');
  } else if (name == '*') {
    if (namespace == null || namespace == '*') {
      return (named) => true;
    } else {
      return (named) => named.name.namespaceUri == namespace;
    }
  } else {
    if (namespace == null) {
      return (named) => named.name.qualified == name;
    } else if (namespace == '*') {
      return (named) => named.name.local == name;
    } else {
      return (named) =>
          named.name.local == name && named.name.namespaceUri == namespace;
    }
  }
}
