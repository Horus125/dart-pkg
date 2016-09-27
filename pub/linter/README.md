# Linter for Dart

A Dart style linter.

[![Build Status](https://travis-ci.org/dart-lang/linter.svg)](https://travis-ci.org/dart-lang/linter)
[![Build status](https://ci.appveyor.com/api/projects/status/3a2437l58uhmvckm/branch/master?svg=true)](https://ci.appveyor.com/project/pq/linter/branch/master)
[![Coverage Status](https://coveralls.io/repos/dart-lang/linter/badge.svg)](https://coveralls.io/r/dart-lang/linter)
[![Pub](https://img.shields.io/pub/v/linter.svg)](https://pub.dartlang.org/packages/linter)

## Installing

The easiest way to install the `linter` is to [globally activate](https://www.dartlang.org/tools/pub/cmd/pub-global.html) it via `pub`:

    $ pub global activate linter

Alternatively, clone the `linter` repo like this:

    $ git clone https://github.com/dart-lang/linter.git

## Usage

Linter for Dart gives you feedback to help you keep your code in line with the published [Dart Style Guide](https://www.dartlang.org/articles/style-guide/). Currently enforced lint rules (or "lints") are catalogued [here](http://dart-lang.github.io/linter/lints/).  When you run the linter all lints are enabled but don't worry, configuration, wherein you can specifically enable/disable lints, is in the [works](https://github.com/dart-lang/linter/issues/7).  While initial focus is on style lints, other lints that catch common programming errors are certainly of interest.  If you have ideas, please file a [feature request][tracker].

Running the linter via `pub` looks like this:

    $ pub global run linter my_project

With example output will looking like this:

    my_project/my_library.dart 13:8 [lint] Name non-constant identifiers using lowerCamelCase.
      IOSink std_err = stderr;
             ^^^^^^^
    12 files analyzed, 1 issue found.

Supported options are

    -h, --help                             Shows usage information.
    -s, --stats                            Show lint statistics.
        --[no-]visit-transitive-closure    Visit the transitive closure of imported/exported libraries.
    -q, --[no-]quiet                       Don't show individual lint errors.
    -c, --config                           Use configuration from this file.
        --dart-sdk                         Custom path to a Dart SDK.
    -p, --package-root                     Custom package root. (Discouraged.)

Note that you should not need to specify an `sdk` or `package-root`. Lint configuration file format is provisional and under [active discussion](https://github.com/dart-lang/linter/issues/41). Other configuration options are on the way.  


## Contributing

Feedback is, of course, greatly appreciated and contributions are welcome! Please read the
[contribution guidelines](CONTRIBUTING.md).

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/dart-lang/linter/issues

