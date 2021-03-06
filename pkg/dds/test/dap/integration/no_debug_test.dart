// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'test_support.dart';

main() {
  setUpAll(startServerAndClient);
  tearDownAll(stopServerAndClient);

  group('noDebug', () {
    test('runs a simple script', () async {
      final testFile = createTestFile(r'''
void main(List<String> args) async {
  print('Hello!');
  print('World!');
  print('args: $args');
}
    ''');

      final outputEvents = await dapClient.collectOutput(
        launch: () => dapClient.launch(
          testFile.path,
          noDebug: true,
          args: ['one', 'two'],
        ),
      );

      final output = outputEvents.map((e) => e.output).join();
      expectLines(output, [
        'Hello!',
        'World!',
        'args: [one, two]',
        '',
        'Exited.',
      ]);
    });
  });
}
