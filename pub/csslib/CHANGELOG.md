## 0.13.2

* Relax type of TreeNode.visit, to allow returning values from visitors.

## 0.13.1

* Fix two checked mode bugs introduced in 0.13.0.

## 0.13.0

 * **BREAKING** Fix all [strong mode][] errors and warnings.
   This involved adding more precise on some public APIs, which
   is why it may break users.
 
[strong mode]: https://github.com/dart-lang/dev_compiler/blob/master/STRONG_MODE.md

## 0.12.2

 * Fix to handle calc functions however, the expressions are treated as a
   LiteralTerm and not fully parsed into the AST.

## 0.12.1

 * Fix to handling of escapes in strings.

## 0.12.0+1

* Allow the lastest version of `logging` package.

## 0.12.0

* Top-level methods in `parser.dart` now take `PreprocessorOptions` instead of
  `List<String>`.

* `PreprocessorOptions.inputFile` is now final.

## 0.11.0+4

* Cleanup some ambiguous and some incorrect type signatures.

## 0.11.0+3

* Improve the speed and memory efficiency of parsing.

## 0.11.0+2

* Fix another test that was failing on IE10.

## 0.11.0+1

* Fix a test that was failing on IE10.

## 0.11.0

* Switch from `source_maps`' `Span` class to `source_span`'s `SourceSpan` class.