// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

// Test that inlining in the compiler works with privacy.

library private4_test;

import "package:expect/expect.dart";
import 'other_library.dart';

main() {
  Expect.equals(42, foo(new A()));
  Expect.throwsNoSuchMethodError(() => foo(new B()));
}

class B {
  _bar() => 42;
}
