// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:_fe_analyzer_shared/src/parser/parser.dart';
import 'package:_fe_analyzer_shared/src/parser/formal_parameter_kind.dart';
import 'package:_fe_analyzer_shared/src/parser/listener.dart';
import 'package:_fe_analyzer_shared/src/parser/member_kind.dart';
import 'package:_fe_analyzer_shared/src/scanner/utf8_bytes_scanner.dart';
import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:dart_style/dart_style.dart' show DartFormatter;

StringSink out;

main(List<String> args) {
  if (args.contains("--stdout")) {
    out = stdout;
  } else {
    out = new StringBuffer();
  }

  File f = new File.fromUri(Platform.script
      .resolve("../../../_fe_analyzer_shared/lib/src/parser/listener.dart"));
  List<int> rawBytes = f.readAsBytesSync();

  Uint8List bytes = new Uint8List(rawBytes.length + 1);
  bytes.setRange(0, rawBytes.length, rawBytes);

  Utf8BytesScanner scanner = new Utf8BytesScanner(bytes, includeComments: true);
  Token firstToken = scanner.tokenize();

  out.write(r"""
// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:_fe_analyzer_shared/src/parser/assert.dart';
import 'package:_fe_analyzer_shared/src/parser/block_kind.dart';
import 'package:_fe_analyzer_shared/src/parser/declaration_kind.dart';
import 'package:_fe_analyzer_shared/src/parser/formal_parameter_kind.dart';
import 'package:_fe_analyzer_shared/src/parser/identifier_context.dart';
import 'package:_fe_analyzer_shared/src/parser/listener.dart';
import 'package:_fe_analyzer_shared/src/parser/member_kind.dart';
import 'package:_fe_analyzer_shared/src/scanner/error_token.dart';
import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:front_end/src/fasta/messages.dart';

// THIS FILE IS AUTO GENERATED BY
// 'tool/_fasta/direct_parser_ast_helper_creator.dart'
// Run e.g.
/*
   out/ReleaseX64/dart \
     pkg/front_end/tool/_fasta/direct_parser_ast_helper_creator.dart \
      > pkg/front_end/lib/src/fasta/util/direct_parser_ast_helper.dart
*/

class DirectParserASTContent {
  final String what;
  final DirectParserASTType type;
  final Map<String, Object> arguments;
  List<DirectParserASTContent> content;

  DirectParserASTContent(this.what, this.type, this.arguments);

  // TODO(jensj): Compare two ASTs.
}

enum DirectParserASTType { BEGIN, END, HANDLE, DONE }

abstract class AbstractDirectParserASTListener implements Listener {
  List<DirectParserASTContent> data = [];

  void seen(String what, DirectParserASTType type, Map<String, Object> arguments);

""");

  ParserCreatorListener listener = new ParserCreatorListener();
  ClassMemberParser parser = new ClassMemberParser(listener);
  parser.parseUnit(firstToken);

  out.writeln("}");

  if (out is StringBuffer) {
    String text = new DartFormatter().format("$out");
    if (args.isNotEmpty) {
      new File(args.first).writeAsStringSync(text);
    } else {
      stdout.write(text);
    }
  }
}

class ParserCreatorListener extends Listener {
  bool insideListenerClass = false;
  String currentMethodName;
  String latestSeenParameterTypeToken;
  List<String> parameters = <String>[];
  List<String> parameterTypes = <String>[];

  void beginClassDeclaration(Token begin, Token abstractToken, Token name) {
    if (name.lexeme == "Listener") insideListenerClass = true;
  }

  void endClassDeclaration(Token beginToken, Token endToken) {
    insideListenerClass = false;
  }

  void beginMethod(Token externalToken, Token staticToken, Token covariantToken,
      Token varFinalOrConst, Token getOrSet, Token name) {
    currentMethodName = name.lexeme;
  }

  void endClassMethod(Token getOrSet, Token beginToken, Token beginParam,
      Token beginInitializers, Token endToken) {
    void end() {
      parameters.clear();
      parameterTypes.clear();
      currentMethodName = null;
    }

    if (insideListenerClass &&
        (currentMethodName.startsWith("begin") ||
            currentMethodName.startsWith("end") ||
            currentMethodName.startsWith("handle"))) {
      StringBuffer sb = new StringBuffer();
      sb.write("  ");
      Token token = beginToken;
      Token latestToken;
      while (true) {
        if (latestToken != null && latestToken.charEnd < token.charOffset) {
          sb.write(" ");
        }
        sb.write(token.lexeme);
        if ((token is BeginToken &&
                token.type == TokenType.OPEN_CURLY_BRACKET) ||
            token is SimpleToken && token.type == TokenType.FUNCTION) {
          break;
        }
        if (token == endToken) {
          throw token.runtimeType;
        }
        latestToken = token;
        token = token.next;
      }

      if (token is SimpleToken && token.type == TokenType.FUNCTION) {
        return end();
      } else {
        sb.write("\n    ");
        sb.write('seen("');
        String typeString;
        String name;
        if (currentMethodName.startsWith("begin")) {
          typeString = "BEGIN";
          name = currentMethodName.substring("begin".length);
        } else if (currentMethodName.startsWith("end")) {
          typeString = "END";
          name = currentMethodName.substring("end".length);
        } else if (currentMethodName.startsWith("handle")) {
          typeString = "HANDLE";
          name = currentMethodName.substring("handle".length);
        } else {
          throw "Unexpected.";
        }
        sb.write(name);
        sb.write('", DirectParserASTType.');
        sb.write(typeString);
        sb.write(", {");
        String separator = "";
        for (int i = 0; i < parameters.length; i++) {
          sb.write(separator);
          sb.write('"');
          sb.write(parameters[i]);
          sb.write('": ');
          sb.write(parameters[i]);
          separator = ", ";
        }

        sb.write("});\n  ");

        sb.write("}");
      }
      sb.write("\n\n");

      out.write(sb.toString());
    }
    end();
  }

  @override
  void handleNoType(Token lastConsumed) {
    latestSeenParameterTypeToken = null;
  }

  void handleType(Token beginToken, Token questionMark) {
    latestSeenParameterTypeToken = beginToken.lexeme;
  }

  void endFormalParameter(
      Token thisKeyword,
      Token periodAfterThis,
      Token nameToken,
      Token initializerStart,
      Token initializerEnd,
      FormalParameterKind kind,
      MemberKind memberKind) {
    parameters.add(nameToken.lexeme);
    parameterTypes.add(latestSeenParameterTypeToken);
  }
}