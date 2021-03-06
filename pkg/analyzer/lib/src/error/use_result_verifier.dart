// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/error/hint_codes.dart';
import 'package:collection/collection.dart';

class UseResultVerifier {
  final ErrorReporter _errorReporter;

  UseResultVerifier(this._errorReporter);

  void checkMethodInvocation(MethodInvocation node) {
    var element = node.methodName.staticElement;
    if (element == null) {
      return;
    }

    _check(node, element);
  }

  void checkPropertyAccess(PropertyAccess node) {
    var element = node.propertyName.staticElement;
    if (element == null) {
      return null;
    }

    _check(node, element);
  }

  void checkSimpleIdentifier(SimpleIdentifier node) {
    if (node.inDeclarationContext()) {
      return;
    }

    var parent = node.parent;
    // Covered by checkPropertyAccess and checkMethodInvocation respectively.
    if (parent is PropertyAccess || parent is MethodInvocation) {
      return;
    }

    var element = node.staticElement;
    if (element == null) {
      return null;
    }

    _check(node, element);
  }

  void _check(AstNode node, Element element) {
    var annotation = _getUseResultMetadata(element);
    if (annotation == null) {
      return;
    }

    if (_isUsed(node)) {
      return;
    }

    var displayName = element.displayName;

    var message = _getUseResultMessage(annotation);
    if (message == null || message.isEmpty) {
      _errorReporter
          .reportErrorForNode(HintCode.UNUSED_RESULT, node, [displayName]);
    } else {
      _errorReporter.reportErrorForNode(
          HintCode.UNUSED_RESULT_WITH_MESSAGE, node, [displayName, message]);
    }
  }

  static String? _getUseResultMessage(ElementAnnotation annotation) {
    if (annotation.element is PropertyAccessorElement) {
      return null;
    }
    var constantValue = annotation.computeConstantValue();
    return constantValue?.getField('message')?.toStringValue();
  }

  static ElementAnnotation? _getUseResultMetadata(Element element) {
    // Implicit getters/setters.
    if (element.isSynthetic && element is PropertyAccessorElement) {
      element = element.variable;
    }
    return element.metadata.firstWhereOrNull((e) => e.isUseResult);
  }

  static bool _isUsed(AstNode node) {
    var parent = node.parent;
    if (parent == null) {
      return false;
    }

    if (parent is ParenthesizedExpression || parent is ConditionalExpression) {
      return _isUsed(parent);
    }

    return parent is ArgumentList ||
        parent is VariableDeclaration ||
        parent is MethodInvocation ||
        parent is PropertyAccess ||
        parent is ExpressionFunctionBody ||
        parent is ReturnStatement ||
        parent is FunctionExpressionInvocation ||
        parent is ListLiteral ||
        parent is SetOrMapLiteral ||
        parent is MapLiteralEntry;
  }
}
