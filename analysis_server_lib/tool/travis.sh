#!/bin/bash

# Copyright (c) 2017, Devon Carew. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Verify the library re-generates.
dart --enable-asserts tool/generate_analysis.dart

# Verify that the libraries are error free.
dartanalyzer --fatal-warnings .

# Run the tests.
pub run test

# Run a basic smoke test.
dart tool/analysis_tester.dart
