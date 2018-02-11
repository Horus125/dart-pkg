// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:matcher/matcher.dart';
import 'package:meta/meta.dart';

import '../backend/closed_exception.dart';
import '../backend/invoker.dart';
import '../utils.dart';
import 'async_matcher.dart';

/// A future that emits `null`.
///
/// We cache and re-use this value to avoid adding a new microtask hit for each
/// call to `expect()`.
final _emptyFuture = new Future.value();

/// An exception thrown when a test assertion fails.
class TestFailure {
  final String message;

  TestFailure(this.message);

  String toString() => message;
}

/// The type used for functions that can be used to build up error reports
/// upon failures in [expect].
@Deprecated("Will be removed in 0.13.0.")
typedef String ErrorFormatter(
    actual, Matcher matcher, String reason, Map matchState, bool verbose);

/// Assert that [actual] matches [matcher].
///
/// This is the main assertion function. [reason] is optional and is typically
/// not supplied, as a reason is generated from [matcher]; if [reason]
/// is included it is appended to the reason generated by the matcher.
///
/// [matcher] can be a value in which case it will be wrapped in an
/// [equals] matcher.
///
/// If the assertion fails a [TestFailure] is thrown.
///
/// If [skip] is a String or `true`, the assertion is skipped. The arguments are
/// still evaluated, but [actual] is not verified to match [matcher]. If
/// [actual] is a [Future], the test won't complete until the future emits a
/// value.
///
/// If [skip] is a string, it should explain why the assertion is skipped; this
/// reason will be printed when running the test.
///
/// In some cases extra diagnostic info can be produced on failure (for
/// example, stack traces on mismatched exceptions). To enable these,
/// [verbose] should be specified as `true`.
///
/// Certain matchers, like [completion] and [throwsA], either match or fail
/// asynchronously. When you use [expect] with these matchers, it ensures that
/// the test doesn't complete until the matcher has either matched or failed. If
/// you want to wait for the matcher to complete before continuing the test, you
/// can call [expectLater] instead and `await` the result.
void expect(actual, matcher,
    {String reason,
    skip,
    @Deprecated("Will be removed in 0.13.0.") bool verbose: false,
    @Deprecated("Will be removed in 0.13.0.") ErrorFormatter formatter}) {
  _expect(actual, matcher,
      reason: reason, skip: skip, verbose: verbose, formatter: formatter);
}

/// Just like [expect], but returns a [Future] that completes when the matcher
/// has finished matching.
///
/// For the [completes] and [completion] matchers, as well as [throwsA] and
/// related matchers when they're matched against a [Future], the returned
/// future completes when the matched future completes. For the [prints]
/// matcher, it completes when the future returned by the callback completes.
/// Otherwise, it completes immediately.
///
/// If the matcher fails asynchronously, that failure is piped to the returned
/// future where it can be handled by user code.
Future expectLater(actual, matcher, {String reason, skip}) =>
    _expect(actual, matcher, reason: reason, skip: skip);

/// The implementation of [expect] and [expectLater].
Future _expect(actual, matcher,
    {String reason, skip, bool verbose: false, ErrorFormatter formatter}) {
  formatter ??= (actual, matcher, reason, matchState, verbose) {
    var mismatchDescription = new StringDescription();
    matcher.describeMismatch(actual, mismatchDescription, matchState, verbose);

    return formatFailure(matcher, actual, mismatchDescription.toString(),
        reason: reason);
  };

  if (Invoker.current == null) {
    throw new StateError("expect() may only be called within a test.");
  }

  if (Invoker.current.closed) throw new ClosedException();

  if (skip != null && skip is! bool && skip is! String) {
    throw new ArgumentError.value(skip, "skip", "must be a bool or a String");
  }

  matcher = wrapMatcher(matcher);
  if (skip != null && skip != false) {
    String message;
    if (skip is String) {
      message = "Skip expect: $skip";
    } else if (reason != null) {
      message = "Skip expect ($reason).";
    } else {
      var description = new StringDescription().addDescriptionOf(matcher);
      message = "Skip expect ($description).";
    }

    Invoker.current.skip(message);
    return _emptyFuture;
  }

  if (matcher is AsyncMatcher) {
    // Avoid async/await so that expect() throws synchronously when possible.
    var result = matcher.matchAsync(actual);
    expect(
        result,
        anyOf([
          equals(null),
          new isInstanceOf<Future>(),
          new isInstanceOf<String>()
        ]),
        reason: "matchAsync() may only return a String, a Future, or null.");

    if (result is String) {
      fail(formatFailure(matcher, actual, result, reason: reason));
    } else if (result is Future) {
      Invoker.current.addOutstandingCallback();
      return result.then((realResult) {
        if (realResult == null) return;
        fail(formatFailure(matcher, actual, realResult, reason: reason));
      }).whenComplete(() {
        // Always remove this, in case the failure is caught and handled
        // gracefully.
        Invoker.current.removeOutstandingCallback();
      });
    }

    return _emptyFuture;
  }

  var matchState = {};
  try {
    if (matcher.matches(actual, matchState)) return _emptyFuture;
  } catch (e, trace) {
    reason ??= '$e at $trace';
  }
  fail(formatter(actual, matcher, reason, matchState, verbose));
}

/// Convenience method for throwing a new [TestFailure] with the provided
/// [message].
@alwaysThrows
Null fail(String message) => throw new TestFailure(message);

// The default error formatter.
@Deprecated("Will be removed in 0.13.0.")
String formatFailure(Matcher expected, actual, String which, {String reason}) {
  var buffer = new StringBuffer();
  buffer.writeln(indent(prettyPrint(expected), first: 'Expected: '));
  buffer.writeln(indent(prettyPrint(actual), first: '  Actual: '));
  if (which.isNotEmpty) buffer.writeln(indent(which, first: '   Which: '));
  if (reason != null) buffer.writeln(reason);
  return buffer.toString();
}
