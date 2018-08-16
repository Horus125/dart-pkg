// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'lib/suites/json.dart' show jsonSuite;
import 'lib/vm.dart' show runSuiteInVM;

main() => runSuiteInVM(jsonSuite);
