# Changelog

## 2.2.2
- adjust the Flutter usage client to Flutter API changes

## 2.2.1
- improve the user agent string for the CLI client

## 2.2.0+1
- bug fix to prevent frequently changing the settings file

## 2.2.0
- added `Analytics.firstRun`
- added `Analytics.enabled`
- removed `Analytics.optIn`

## 2.1.0
- added `Analytics.getSessionValue()`
- added `Analytics.onSend`
- added `AnalyticsImpl.sendRaw()`

## 2.0.0
- added a `usage` implementation for Flutter (uses conditional directives)
- removed `lib/usage_html.dart`; use the new Analytics.create() static method
- removed `lib/usage_io.dart`; use the new Analytics.create() static method
- bumped to `2.0.0` for API changes and library refactorings

## 1.2.0
- added an optional `analyticsUrl` parameter to the usage constructors

## 1.1.0
- fix two strong mode analysis issues (overriding a field declaration with a
  setter/getter pair)

## 1.0.1
- make strong mode compliant
- update some dev package dependencies

## 1.0.0
- Rev'd to 1.0.0!
- No other changes from the `0.0.6` release

## 0.0.6
- Added a web example
- Added a utility method to time async events (`Analytics.startTimer()`)
- Updated the readme to add information about when we send analytics info

## 0.0.5

- Catch errors during pings to Google Analytics, for example in case of a
  missing internet connection
- Track additional browser data, such as screen size and language
- Added tests for `usage` running in a dart:html context
- Changed to a custom implementation of UUID; saved ~376k in compiled JS size

## 0.0.4

- Moved `sanitizeStacktrace` into the main library

## 0.0.3

- Replaced optional positional arguments with named arguments
- Added code coverage! Thanks to https://github.com/Adracus/dart-coveralls and
  coveralls.io.

## 0.0.2

- Fixed a bug in `analytics.sendTiming()`

## 0.0.1

- Initial version, created by Stagehand
