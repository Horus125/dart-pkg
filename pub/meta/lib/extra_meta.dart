library extras;

/*
@interface & @noImplicitInterfaces (on library directive)
 */

/// Used to annotate a class `C`. Indicates that `C` and all subtypes of `C`
/// must be immutable.
///
/// A class is immutable if all of the instance fields of the class, whether
/// defined directly or inherited, are `final`.
///
/// Tools, such as the analyzer, can provide feedback if
/// * the annotation is associated with anything other than a class, or
/// * a class that has this annotation or extends, implements or mixes in a
///   class that has this annotation is not immutable.
const _Immutable immutable = const _Immutable();

class _Immutable {
  const _Immutable();
}

/// Used to annotate a class `C`. Indicates that instances of `C` and of all
/// subtypes of `C` must be value objects.
///
/// An object is a value object if it implements equality strictly in terms of
/// the values of its fields.
///
/// Tools, such as the analyzer, can provide feedback if
/// * the annotation is associated with anything other than a class, or
/// * a class that has this annotation or extends, implements or mixes in a
///   class that has this annotation does not define a value object.
const _Value value = const _Value();

class _Value {
  const _Value();
}

/// Used to annotate an instance method `m` in a class `C`. Indicates that `m`
/// cannot be overridden in subclasses of `C`. Note that it is still valid to
/// implement `m` in classes that implement `C`.
///
/// Tools, such as the analyzer, can provide feedback if
/// * the annotation is associated with anything other than an instance method,
///   or
/// * a method overrides a method that has this annotation.
const Sealed sealed = const Sealed();

class Sealed {
  /// A human-readable explanation of the alternative available to subclasses.
  /// For example, if a method `m1` cannot be overridden, but subclasses can
  /// achieve a similar effect by overriding a method `m2`, then the annotation
  /// might look like:
  ///
  ///     @Sealed("Subclasses should override 'm2' instead.")
  final String alternative;

  /// Initialize a newly created instance to have the given [alternative].
  const Sealed([this.alternative]);
}
