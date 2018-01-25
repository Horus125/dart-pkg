library petitparser.example.lisp.name;

/// An unique symbolic name.
class Name {
  /// The interned symbols.
  static final Map<String, Name> _interned = {};

  /// Factory for new symbol cells.
  factory Name(String name) {
    return _interned.putIfAbsent(name, () => new Name._internal(name));
  }

  /// The name of the symbol.
  final String _name;

  /// Internal constructor for symbol.
  Name._internal(this._name);

  /// Returns the string representation of the symbolic name.
  @override
  String toString() => _name;
}
