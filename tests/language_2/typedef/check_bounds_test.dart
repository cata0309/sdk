// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

// Check that typedef type parameters are verified to satisfy their bounds.

typedef T F<T extends num>(T x);

void g(/*@compile-error=unspecified*/ F<String> f) {}

main() {
  g(null);
}
