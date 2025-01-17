// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/error/syntactic_errors.dart';

import 'analyzer_error_code.dart';

export 'package:analyzer/src/analysis_options/error/option_codes.dart';
export 'package:analyzer/src/dart/error/hint_codes.dart';
export 'package:analyzer/src/dart/error/lint_codes.dart';
export 'package:analyzer/src/dart/error/todo_codes.dart';

/**
 * The error codes used for compile time errors caused by constant evaluation
 * that would throw an exception when run in checked mode. The client of the
 * analysis engine is responsible for determining how these errors should be
 * presented to the user (for example, a command-line compiler might elect to
 * treat these errors differently depending whether it is compiling it "checked"
 * mode).
 */
class CheckedModeCompileTimeErrorCode extends AnalyzerErrorCode {
  // TODO(paulberry): improve the text of these error messages so that it's
  // clear to the user that the error is coming from constant evaluation (and
  // hence the constant needs to be a subtype of the annotated type) as opposed
  // to static type analysis (which only requires that the two types be
  // assignable).  Also consider populating the "correction" field for these
  // errors.

  /**
   * 16.12.2 Const: It is a compile-time error if evaluation of a constant
   * object results in an uncaught exception being thrown.
   */
  static const CheckedModeCompileTimeErrorCode
      CONST_CONSTRUCTOR_FIELD_TYPE_MISMATCH = CheckedModeCompileTimeErrorCode(
          'CONST_CONSTRUCTOR_FIELD_TYPE_MISMATCH',
          "A value of type '{0}' can't be assigned to the field '{1}', which "
              "has type '{2}'.");

  /**
   * 16.12.2 Const: It is a compile-time error if evaluation of a constant
   * object results in an uncaught exception being thrown.
   */
  static const CheckedModeCompileTimeErrorCode
      CONST_CONSTRUCTOR_PARAM_TYPE_MISMATCH = CheckedModeCompileTimeErrorCode(
          'CONST_CONSTRUCTOR_PARAM_TYPE_MISMATCH',
          "A value of type '{0}' can't be assigned to a parameter of type "
              "'{1}'.");

  /**
   * 7.6.1 Generative Constructors: In checked mode, it is a dynamic type error
   * if o is not <b>null</b> and the interface of the class of <i>o</i> is not a
   * subtype of the static type of the field <i>v</i>.
   *
   * 16.12.2 Const: It is a compile-time error if evaluation of a constant
   * object results in an uncaught exception being thrown.
   *
   * Parameters:
   * 0: the name of the type of the initializer expression
   * 1: the name of the type of the field
   */
  static const CheckedModeCompileTimeErrorCode
      CONST_FIELD_INITIALIZER_NOT_ASSIGNABLE = CheckedModeCompileTimeErrorCode(
          'CONST_FIELD_INITIALIZER_NOT_ASSIGNABLE',
          "The initializer type '{0}' can't be assigned to the field type "
              "'{1}'.");

  /**
   * Parameters:
   * 0: the type of the object being assigned.
   * 1: the type of the variable being assigned to
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the evaluation of a constant
  // expression would result in a `CastException`.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the value of `x` is an
  // `int`, which can't be assigned to `y` because an `int` isn't a `String`:
  //
  // ```dart
  // const Object x = 0;
  // const String y = [!x!];
  // ```
  //
  // #### Common fixes
  //
  // If the declaration of the constant is correct, then change the value being
  // assigned to be of the correct type:
  //
  // ```dart
  // const Object x = 0;
  // const String y = '$x';
  // ```
  //
  // If the assigned value is correct, then change the declaration to have the
  // correct type:
  //
  // ```dart
  // const Object x = 0;
  // const int y = x;
  // ```
  static const CheckedModeCompileTimeErrorCode VARIABLE_TYPE_MISMATCH =
      CheckedModeCompileTimeErrorCode(
          'VARIABLE_TYPE_MISMATCH',
          "A value of type '{0}' can't be assigned to a variable of type "
              "'{1}'.");

  /**
   * Initialize a newly created error code to have the given [name]. The message
   * associated with the error will be created from the given [message]
   * template. The correction associated with the error will be created from the
   * given [correction] template.
   */
  const CheckedModeCompileTimeErrorCode(String name, String message,
      {String correction, bool hasPublishedDocs})
      : super.temporary(name, message,
            correction: correction, hasPublishedDocs: hasPublishedDocs);

  @override
  ErrorSeverity get errorSeverity =>
      ErrorType.CHECKED_MODE_COMPILE_TIME_ERROR.severity;

  @override
  ErrorType get type => ErrorType.CHECKED_MODE_COMPILE_TIME_ERROR;
}

/**
 * The error codes used for compile time errors. The convention for this class
 * is for the name of the error code to indicate the problem that caused the
 * error to be generated and for the error message to explain what is wrong and,
 * when appropriate, how the problem can be corrected.
 */
class CompileTimeErrorCode extends AnalyzerErrorCode {
  /**
   * Parameters:
   * 0: the display name for the kind of the found abstract member
   * 1: the name of the member
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an inherited member is
  // referenced using `super`, but there is no concrete implementation of the
  // member in the superclass chain. Abstract members can't be invoked.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `B` doesn't inherit a
  // concrete implementation of `a`:
  //
  // ```dart
  // abstract class A {
  //   int get a;
  // }
  // class B extends A {
  //   int get a => super.[!a!];
  // }
  // ```
  //
  // #### Common fixes
  //
  // Remove the invocation of the abstract member, possibly replacing it with an
  // invocation of a concrete member.
  // TODO(brianwilkerson) This either needs to be generalized (use 'member'
  //  rather than '{0}') or split into multiple codes.
  static const CompileTimeErrorCode ABSTRACT_SUPER_MEMBER_REFERENCE =
      CompileTimeErrorCode('ABSTRACT_SUPER_MEMBER_REFERENCE',
          "The {0} '{1}' is always abstract in the supertype.",
          hasPublishedDocs: true);

  /**
   * Enum proposal: It is also a compile-time error to explicitly instantiate an
   * enum via 'new' or 'const' or to access its private fields.
   */
  static const CompileTimeErrorCode ACCESS_PRIVATE_ENUM_FIELD =
      CompileTimeErrorCode(
          'ACCESS_PRIVATE_ENUM_FIELD',
          "The private fields of an enum can't be accessed, even within the "
              "same library.");

  /**
   * 14.2 Exports: It is a compile-time error if a name <i>N</i> is re-exported
   * by a library <i>L</i> and <i>N</i> is introduced into the export namespace
   * of <i>L</i> by more than one export, unless each all exports refer to same
   * declaration for the name N.
   *
   * Parameters:
   * 0: the name of the ambiguous element
   * 1: the name of the first library in which the type is found
   * 2: the name of the second library in which the type is found
   */
  static const CompileTimeErrorCode AMBIGUOUS_EXPORT = CompileTimeErrorCode(
      'AMBIGUOUS_EXPORT',
      "The name '{0}' is defined in the libraries '{1}' and '{2}'.",
      correction: "Try removing the export of one of the libraries, or "
          "explicitly hiding the name in one of the export directives.");

  /**
   * Parameters:
   * 0: the name of the member
   * 1: the name of the first declaring extension
   * 2: the name of the second declaring extension
   */
  // #### Description
  //
  // When code refers to a member of an object (for example, `o.m()` or `o.m` or
  // `o[i]`) where the static type of `o` doesn't declare the member (`m` or
  // `[]`, for example), then the analyzer tries to find the member in an
  // extension. For example, if the member is `m`, then the analyzer looks for
  // extensions that declare a member named `m` and have an extended type that
  // the static type of `o` can be assigned to. When there's more than one such
  // extension in scope, the extension whose extended type is most specific is
  // selected.
  //
  // The analyzer produces this diagnostic when none of the extensions has an
  // extended type that's more specific than the extended types of all of the
  // other extensions, making the reference to the member ambiguous.
  //
  // #### Example
  //
  // The following code produces this diagnostic because there's no way to
  // choose between the member in `E1` and the member in `E2`:
  //
  // ```dart
  // extension E1 on String {
  //   int get charCount => 1;
  // }
  //
  // extension E2 on String {
  //   int get charCount => 2;
  // }
  //
  // void f(String s) {
  //   print(s.[!charCount!]);
  // }
  // ```
  //
  // #### Common fixes
  //
  // If you don't need both extensions, then you can delete or hide one of them.
  //
  // If you need both, then explicitly select the one you want to use by using
  // an extension override:
  //
  // ```dart
  // extension E1 on String {
  //   int get charCount => length;
  // }
  //
  // extension E2 on String {
  //   int get charCount => length;
  // }
  //
  // void f(String s) {
  //   print(E2(s).charCount);
  // }
  // ```
  /*
   * TODO(brianwilkerson) This message doesn't handle the possible case where
   *  there are more than 2 extensions, nor does it handle well the case where
   *  one or more of the extensions is unnamed.
   */
  static const CompileTimeErrorCode AMBIGUOUS_EXTENSION_MEMBER_ACCESS =
      CompileTimeErrorCode(
          'AMBIGUOUS_EXTENSION_MEMBER_ACCESS',
          "A member named '{0}' is defined in extensions '{1}' and '{2}' and "
              "neither is more specific.",
          correction:
              "Try using an extension override to specify the extension "
              "you want to to be chosen.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // Because map and set literals use the same delimiters (`{` and `}`), the
  // analyzer looks at the type arguments and the elements to determine which
  // kind of literal you meant. When there are no type arguments and all of the
  // elements are spread elements (which are allowed in both kinds of literals),
  // then the analyzer uses the types of the expressions that are being spread.
  // If all of the expressions have the type `Iterable`, then it's a set
  // literal; if they all have the type `Map`, then it's a map literal.
  //
  // The analyzer produces this diagnostic when some of the expressions being
  // spread have the type `Iterable` and others have the type `Map`, making it
  // impossible for the analyzer to determine whether you are writing a map
  // literal or a set literal.
  //
  // #### Example
  //
  // The following code produces this diagnostic:
  //
  // ```dart
  // union(Map<String, String> a, List<String> b, Map<String, String> c) =>
  //     [!{...a, ...b, ...c}!];
  // ```
  //
  // The list `b` can only be spread into a set, and the maps `a` and `c` can
  // only be spread into a map, and the literal can't be both.
  //
  // #### Common fixes
  //
  // There are two common ways to fix this problem. The first is to remove all
  // of the spread elements of one kind or another, so that the elements are
  // consistent. In this case, that likely means removing the list and deciding
  // what to do about the now unused parameter:
  //
  // ```dart
  // union(Map<String, String> a, List<String> b, Map<String, String> c) =>
  //     {...a, ...c};
  // ```
  //
  // The second fix is to change the elements of one kind into elements that are
  // consistent with the other elements. For example, you can add the elements
  // of the list as keys that map to themselves:
  //
  // ```dart
  // union(Map<String, String> a, List<String> b, Map<String, String> c) =>
  //     {...a, for (String s in b) s: s, ...c};
  // ```
  static const CompileTimeErrorCode AMBIGUOUS_SET_OR_MAP_LITERAL_BOTH =
      CompileTimeErrorCode(
          'AMBIGUOUS_SET_OR_MAP_LITERAL_BOTH',
          "This literal contains both 'Map' and 'Iterable' spreads, "
              "which makes it impossible to determine whether the literal is "
              "a map or a set.",
          correction:
              "Try removing or changing some of the elements so that all of "
              "the elements are consistent.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // Because map and set literals use the same delimiters (`{` and `}`), the
  // analyzer looks at the type arguments and the elements to determine which
  // kind of literal you meant. When there are no type arguments and all of the
  // elements are spread elements (which are allowed in both kinds of literals)
  // then the analyzer uses the types of the expressions that are being spread.
  // If all of the expressions have the type `Iterable`, then it's a set
  // literal; if they all have the type `Map`, then it's a map literal.
  //
  // This diagnostic is produced when none of the expressions being spread have
  // a type that allows the analyzer to decide whether you were writing a map
  // literal or a set literal.
  //
  // #### Example
  //
  // The following code produces this diagnostic:
  //
  // ```dart
  // union(a, b) => [!{...a, ...b}!];
  // ```
  //
  // The problem occurs because there are no type arguments, and there is no
  // information about the type of either `a` or `b`.
  //
  // #### Common fixes
  //
  // There are three common ways to fix this problem. The first is to add type
  // arguments to the literal. For example, if the literal is intended to be a
  // map literal, you might write something like this:
  //
  // ```dart
  // union(a, b) => <String, String>{...a, ...b};
  // ```
  //
  // The second fix is to add type information so that the expressions have
  // either the type `Iterable` or the type `Map`. You can add an explicit cast
  // or, in this case, add types to the declarations of the two parameters:
  //
  // ```dart
  // union(List<int> a, List<int> b) => {...a, ...b};
  // ```
  //
  // The third fix is to add context information. In this case, that means
  // adding a return type to the function:
  //
  // ```dart
  // Set<String> union(a, b) => {...a, ...b};
  // ```
  //
  // In other cases, you might add a type somewhere else. For example, say the
  // original code looks like this:
  //
  // ```dart
  // union(a, b) {
  //   var x = [!{...a, ...b}!];
  //   return x;
  // }
  // ```
  //
  // You might add a type annotation on `x`, like this:
  //
  // ```dart
  // union(a, b) {
  //   Map<String, String> x = {...a, ...b};
  //   return x;
  // }
  // ```
  static const CompileTimeErrorCode AMBIGUOUS_SET_OR_MAP_LITERAL_EITHER =
      CompileTimeErrorCode(
          'AMBIGUOUS_SET_OR_MAP_LITERAL_EITHER',
          "This literal must be either a map or a set, but the elements don't "
              "have enough information for type inference to work.",
          correction:
              "Try adding type arguments to the literal (one for sets, two "
              "for maps).",
          hasPublishedDocs: true);

  /**
   * 15 Metadata: The constant expression given in an annotation is type checked
   * and evaluated in the scope surrounding the declaration being annotated.
   *
   * 16.12.2 Const: It is a compile-time error if <i>T</i> is not a class
   * accessible in the current scope, optionally followed by type arguments.
   *
   * 16.12.2 Const: If <i>e</i> is of the form <i>const T.id(a<sub>1</sub>,
   * &hellip;, a<sub>n</sub>, x<sub>n+1</sub>: a<sub>n+1</sub>, &hellip;
   * x<sub>n+k</sub>: a<sub>n+k</sub>)</i> it is a compile-time error if
   * <i>T</i> is not a class accessible in the current scope, optionally
   * followed by type arguments.
   *
   * Parameters:
   * 0: the name of the non-type element
   */
  static const CompileTimeErrorCode ANNOTATION_WITH_NON_CLASS =
      CompileTimeErrorCode(
          'ANNOTATION_WITH_NON_CLASS', "The name '{0}' isn't a class.",
          correction: "Try importing the library that declares the class, "
              "correcting the name to match a defined class, or "
              "defining a class with the given name.");

  @Deprecated('Use ParserErrorCode.ANNOTATION_WITH_TYPE_ARGUMENTS')
  static const ParserErrorCode ANNOTATION_WITH_TYPE_ARGUMENTS =
      ParserErrorCode.ANNOTATION_WITH_TYPE_ARGUMENTS;

  static const CompileTimeErrorCode ASSERT_IN_REDIRECTING_CONSTRUCTOR =
      CompileTimeErrorCode('ASSERT_IN_REDIRECTING_CONSTRUCTOR',
          "A redirecting constructor can't have an 'assert' initializer.");

  /**
   * 17.6.3 Asynchronous For-in: It is a compile-time error if an asynchronous
   * for-in statement appears inside a synchronous function.
   */
  static const CompileTimeErrorCode ASYNC_FOR_IN_WRONG_CONTEXT =
      CompileTimeErrorCode('ASYNC_FOR_IN_WRONG_CONTEXT',
          "The async for-in can only be used in an async function.",
          correction:
              "Try marking the function body with either 'async' or 'async*', "
              "or removing the 'await' before the for loop.");

  /**
   * nnbd/feature-specification.md
   *
   * It is an error for the initializer expression of a `late` local variable
   * to use a prefix `await` expression.
   */
  static const CompileTimeErrorCode AWAIT_IN_LATE_LOCAL_VARIABLE_INITIALIZER =
      CompileTimeErrorCode('AWAIT_IN_LATE_LOCAL_VARIABLE_INITIALIZER',
          "The await expression can't be used in a 'late' local variable.",
          correction:
              "Try removing the 'late' modifier, or rewriting the initializer "
              "without using the 'await' expression.");

  /**
   * 16.30 Await Expressions: It is a compile-time error if the function
   * immediately enclosing _a_ is not declared asynchronous. (Where _a_ is the
   * await expression.)
   */
  static const CompileTimeErrorCode AWAIT_IN_WRONG_CONTEXT =
      CompileTimeErrorCode('AWAIT_IN_WRONG_CONTEXT',
          "The await expression can only be used in an async function.",
          correction:
              "Try marking the function body with either 'async' or 'async*'.");

  /**
   * Parameters:
   * 0: the built-in identifier that is being used
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the name of an extension is a
  // built-in identifier. Built-in identifiers can’t be used as extension names.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `mixin` is a built-in
  // identifier:
  //
  // ```dart
  // extension [!mixin!] on int {}
  // ```
  //
  // #### Common fixes
  //
  // Choose a different name for the extension.
  static const CompileTimeErrorCode BUILT_IN_IDENTIFIER_AS_EXTENSION_NAME =
      CompileTimeErrorCode('BUILT_IN_IDENTIFIER_AS_EXTENSION_NAME',
          "The built-in identifier '{0}' can't be used as an extension name.",
          correction: "Try choosing a different name for the extension.",
          hasPublishedDocs: true);

  /**
   * 16.33 Identifier Reference: It is a compile-time error if a built-in
   * identifier is used as the declared name of a prefix, class, type parameter
   * or type alias.
   *
   * Parameters:
   * 0: the built-in identifier that is being used
   */
  static const CompileTimeErrorCode BUILT_IN_IDENTIFIER_AS_PREFIX_NAME =
      CompileTimeErrorCode('BUILT_IN_IDENTIFIER_AS_PREFIX_NAME',
          "The built-in identifier '{0}' can't be used as a prefix name.",
          correction: "Try choosing a different name for the prefix.");

  /**
   * 12.30 Identifier Reference: It is a compile-time error to use a built-in
   * identifier other than dynamic as a type annotation.
   *
   * Parameters:
   * 0: the built-in identifier that is being used
   */
  static const CompileTimeErrorCode BUILT_IN_IDENTIFIER_AS_TYPE =
      CompileTimeErrorCode('BUILT_IN_IDENTIFIER_AS_TYPE',
          "The built-in identifier '{0}' can't be used as a type.",
          correction: "Try correcting the name to match an existing type.");

  /**
   * 16.33 Identifier Reference: It is a compile-time error if a built-in
   * identifier is used as the declared name of a prefix, class, type parameter
   * or type alias.
   *
   * Parameters:
   * 0: the built-in identifier that is being used
   */
  static const CompileTimeErrorCode BUILT_IN_IDENTIFIER_AS_TYPE_NAME =
      CompileTimeErrorCode('BUILT_IN_IDENTIFIER_AS_TYPE_NAME',
          "The built-in identifier '{0}' can't be used as a type name.",
          correction: "Try choosing a different name for the type.");

  /**
   * 16.33 Identifier Reference: It is a compile-time error if a built-in
   * identifier is used as the declared name of a prefix, class, type parameter
   * or type alias.
   *
   * Parameters:
   * 0: the built-in identifier that is being used
   */
  static const CompileTimeErrorCode BUILT_IN_IDENTIFIER_AS_TYPEDEF_NAME =
      CompileTimeErrorCode('BUILT_IN_IDENTIFIER_AS_TYPEDEF_NAME',
          "The built-in identifier '{0}' can't be used as a typedef name.",
          correction: "Try choosing a different name for the typedef.");

  /**
   * 16.33 Identifier Reference: It is a compile-time error if a built-in
   * identifier is used as the declared name of a prefix, class, type parameter
   * or type alias.
   *
   * Parameters:
   * 0: the built-in identifier that is being used
   */
  static const CompileTimeErrorCode BUILT_IN_IDENTIFIER_AS_TYPE_PARAMETER_NAME =
      CompileTimeErrorCode(
          'BUILT_IN_IDENTIFIER_AS_TYPE_PARAMETER_NAME',
          "The built-in identifier '{0}' can't be used as a type parameter "
              "name.",
          correction: "Try choosing a different name for the type parameter.");

  /**
   * 13.9 Switch: It is a compile-time error if the class <i>C</i> implements
   * the operator <i>==</i>.
   *
   * Parameters:
   * 0: the this of the switch case expression
   */
  static const CompileTimeErrorCode CASE_EXPRESSION_TYPE_IMPLEMENTS_EQUALS =
      CompileTimeErrorCode(
          'CASE_EXPRESSION_TYPE_IMPLEMENTS_EQUALS',
          "The switch case expression type '{0}' can't override the == "
              "operator.");

  /**
   * 10.11 Class Member Conflicts: Let `C` be a class. It is a compile-time
   * error if `C` declares a constructor named `C.n`, and a static member with
   * basename `n`.
   *
   * Parameters:
   * 0: the name of the constructor
   */
  static const CompileTimeErrorCode CONFLICTING_CONSTRUCTOR_AND_STATIC_FIELD =
      CompileTimeErrorCode(
          'CONFLICTING_CONSTRUCTOR_AND_STATIC_FIELD',
          "'{0}' can't be used to name both a constructor and a static field "
              "in this class.",
          correction: "Try renaming either the constructor or the field.");

  /**
   * 10.11 Class Member Conflicts: Let `C` be a class. It is a compile-time
   * error if `C` declares a constructor named `C.n`, and a static member with
   * basename `n`.
   *
   * Parameters:
   * 0: the name of the constructor
   */
  static const CompileTimeErrorCode CONFLICTING_CONSTRUCTOR_AND_STATIC_METHOD =
      CompileTimeErrorCode(
          'CONFLICTING_CONSTRUCTOR_AND_STATIC_METHOD',
          "'{0}' can't be used to name both a constructor and a static method "
              "in this class.",
          correction: "Try renaming either the constructor or the method.");

  /**
   * 10.11 Class Member Conflicts: Let `C` be a class. It is a compile-time
   * error if `C` declares a getter or a setter with basename `n`, and has a
   * method named `n`.
   *
   * Parameters:
   * 0: the name of the class defining the conflicting field
   * 1: the name of the conflicting field
   * 2: the name of the class defining the method with which the field conflicts
   */
  static const CompileTimeErrorCode CONFLICTING_FIELD_AND_METHOD =
      CompileTimeErrorCode(
          'CONFLICTING_FIELD_AND_METHOD',
          "Class '{0}' can't define field '{1}' and have method '{2}.{1}' "
              "with the same name.",
          correction: "Try converting the getter to a method, or "
              "renaming the field to a name that doesn't conflict.");

  /**
   * 10.10 Superinterfaces: It is a compile-time error if a class `C` has two
   * superinterfaces that are different instantiations of the same generic
   * class. For example, a class may not have both `List<int>` and `List<num>`
   * as superinterfaces.
   *
   * Parameters:
   * 0: the name of the class implementing the conflicting interface
   * 1: the first conflicting type
   * 1: the second conflicting type
   */
  static const CompileTimeErrorCode CONFLICTING_GENERIC_INTERFACES =
      CompileTimeErrorCode(
          'CONFLICTING_GENERIC_INTERFACES',
          "The class '{0}' cannot implement both '{1}' and '{2}' because the "
              "type arguments are different.");

  /**
   * 10.11 Class Member Conflicts: Let `C` be a class. It is a compile-time
   * error if `C` declares a method named `n`, and has a getter or a setter
   * with basename `n`.
   *
   * Parameters:
   * 0: the name of the class defining the conflicting method
   * 1: the name of the conflicting method
   * 2: the name of the class defining the field with which the method conflicts
   */
  static const CompileTimeErrorCode CONFLICTING_METHOD_AND_FIELD =
      CompileTimeErrorCode(
          'CONFLICTING_METHOD_AND_FIELD',
          "Class '{0}' can't define method '{1}' and have field '{2}.{1}' "
              "with the same name.",
          correction: "Try converting the method to a getter, or "
              "renaming the method to a name that doesn't conflict.");

  /**
   * 10.11 Class Member Conflicts: Let `C` be a class. It is a compile-time
   * error if `C` declares a static member with basename `n`, and has an
   * instance member with basename `n`.
   *
   * Parameters:
   * 0: the name of the class defining the conflicting member
   * 1: the name of the conflicting static member
   * 2: the name of the class defining the field with which the method conflicts
   */
  static const CompileTimeErrorCode CONFLICTING_STATIC_AND_INSTANCE =
      CompileTimeErrorCode(
          'CONFLICTING_STATIC_AND_INSTANCE',
          "Class '{0}' can't define static member '{1}' and have instance "
              "member '{2}.{1}' with the same name.",
          correction:
              "Try renaming the member to a name that doesn't conflict.");

  /**
   * 7. Classes: It is a compile time error if a generic class declares a type
   * variable with the same name as the class or any of its members or
   * constructors.
   *
   * Parameters:
   * 0: the name of the type variable
   */
  static const CompileTimeErrorCode CONFLICTING_TYPE_VARIABLE_AND_CLASS =
      CompileTimeErrorCode(
          'CONFLICTING_TYPE_VARIABLE_AND_CLASS',
          "'{0}' can't be used to name both a type variable and the class in "
              "which the type variable is defined.",
          correction: "Try renaming either the type variable or the class.");

  /**
   * 7. Classes: It is a compile time error if a generic class declares a type
   * variable with the same name as the class or any of its members or
   * constructors.
   *
   * Parameters:
   * 0: the name of the type variable
   */
  static const CompileTimeErrorCode CONFLICTING_TYPE_VARIABLE_AND_MEMBER =
      CompileTimeErrorCode(
          'CONFLICTING_TYPE_VARIABLE_AND_MEMBER',
          "'{0}' can't be used to name both a type variable and a member in "
              "this class.",
          correction: "Try renaming either the type variable or the member.");

  /**
   * 16.12.2 Const: It is a compile-time error if evaluation of a constant
   * object results in an uncaught exception being thrown.
   */
  static const CompileTimeErrorCode CONST_CONSTRUCTOR_THROWS_EXCEPTION =
      CompileTimeErrorCode('CONST_CONSTRUCTOR_THROWS_EXCEPTION',
          "Const constructors can't throw exceptions.",
          correction: "Try removing the throw statement, or "
              "removing the keyword 'const'.");

  /**
   * 10.6.3 Constant Constructors: It is a compile-time error if a constant
   * constructor is declared by a class C if any instance variable declared in C
   * is initialized with an expression that is not a constant expression.
   *
   * Parameters:
   * 0: the name of the field
   */
  static const CompileTimeErrorCode
      CONST_CONSTRUCTOR_WITH_FIELD_INITIALIZED_BY_NON_CONST =
      CompileTimeErrorCode(
          'CONST_CONSTRUCTOR_WITH_FIELD_INITIALIZED_BY_NON_CONST',
          "Can't define the const constructor because the field '{0}' "
              "is initialized with a non-constant value.",
          correction: "Try initializing the field to a constant value, or "
              "removing the keyword 'const' from the constructor.");

  /**
   * 7.6.3 Constant Constructors: The superinitializer that appears, explicitly
   * or implicitly, in the initializer list of a constant constructor must
   * specify a constant constructor of the superclass of the immediately
   * enclosing class or a compile-time error occurs.
   *
   * 12.1 Mixin Application: For each generative constructor named ... an
   * implicitly declared constructor named ... is declared. If Sq is a
   * generative const constructor, and M does not declare any fields, Cq is
   * also a const constructor.
   */
  static const CompileTimeErrorCode CONST_CONSTRUCTOR_WITH_MIXIN_WITH_FIELD =
      CompileTimeErrorCode(
          'CONST_CONSTRUCTOR_WITH_MIXIN_WITH_FIELD',
          "Const constructor can't be declared for a class with a mixin "
              "that declares an instance field.",
          correction: "Try removing the 'const' keyword or "
              "removing the 'with' clause from the class declaration, "
              "or removing fields from the mixin class.");

  /**
   * 7.6.3 Constant Constructors: The superinitializer that appears, explicitly
   * or implicitly, in the initializer list of a constant constructor must
   * specify a constant constructor of the superclass of the immediately
   * enclosing class or a compile-time error occurs.
   *
   * Parameters:
   * 0: the name of the superclass
   */
  static const CompileTimeErrorCode CONST_CONSTRUCTOR_WITH_NON_CONST_SUPER =
      CompileTimeErrorCode(
          'CONST_CONSTRUCTOR_WITH_NON_CONST_SUPER',
          "Constant constructor can't call non-constant super constructor of "
              "'{0}'.",
          correction: "Try calling a const constructor in the superclass, or "
              "removing the keyword 'const' from the constructor.");

  /**
   * 7.6.3 Constant Constructors: It is a compile-time error if a constant
   * constructor is declared by a class that has a non-final instance variable.
   *
   * The above refers to both locally declared and inherited instance variables.
   */
  static const CompileTimeErrorCode CONST_CONSTRUCTOR_WITH_NON_FINAL_FIELD =
      CompileTimeErrorCode('CONST_CONSTRUCTOR_WITH_NON_FINAL_FIELD',
          "Can't define a const constructor for a class with non-final fields.",
          correction: "Try making all of the fields final, or "
              "removing the keyword 'const' from the constructor.");

  /**
   * 12.12.2 Const: It is a compile-time error if <i>T</i> is a deferred type.
   */
  static const CompileTimeErrorCode CONST_DEFERRED_CLASS = CompileTimeErrorCode(
      'CONST_DEFERRED_CLASS', "Deferred classes can't be created with 'const'.",
      correction: "Try using 'new' to create the instance, or "
          "changing the import to not be deferred.");

  /**
   * 16.12.2 Const: An expression of one of the forms !e, e1 && e2 or e1 || e2,
   * where e, e1 and e2 are constant expressions that evaluate to a boolean
   * value.
   */
  static const CompileTimeErrorCode CONST_EVAL_TYPE_BOOL = CompileTimeErrorCode(
      'CONST_EVAL_TYPE_BOOL',
      "In constant expressions, operands of this operator must be of type "
          "'bool'.");

  /**
   * 16.12.2 Const: An expression of one of the forms !e, e1 && e2 or e1 || e2,
   * where e, e1 and e2 are constant expressions that evaluate to a boolean
   * value.
   */
  static const CompileTimeErrorCode CONST_EVAL_TYPE_BOOL_INT =
      CompileTimeErrorCode(
          'CONST_EVAL_TYPE_BOOL_INT',
          "In constant expressions, operands of this operator must be of type "
              "'bool' or 'int'.");

  /**
   * 16.12.2 Const: An expression of one of the forms e1 == e2 or e1 != e2 where
   * e1 and e2 are constant expressions that evaluate to a numeric, string or
   * boolean value or to null.
   */
  static const CompileTimeErrorCode CONST_EVAL_TYPE_BOOL_NUM_STRING =
      CompileTimeErrorCode(
          'CONST_EVAL_TYPE_BOOL_NUM_STRING',
          "In constant expressions, operands of this operator must be of type "
              "'bool', 'num', 'String' or 'null'.");

  /**
   * 16.12.2 Const: An expression of one of the forms ~e, e1 ^ e2, e1 & e2,
   * e1 | e2, e1 >> e2 or e1 << e2, where e, e1 and e2 are constant expressions
   * that evaluate to an integer value or to null.
   */
  static const CompileTimeErrorCode CONST_EVAL_TYPE_INT = CompileTimeErrorCode(
      'CONST_EVAL_TYPE_INT',
      "In constant expressions, operands of this operator must be of type "
          "'int'.");

  /**
   * 16.12.2 Const: An expression of one of the forms e, e1 + e2, e1 - e2, e1 *
   * e2, e1 / e2, e1 ~/ e2, e1 > e2, e1 < e2, e1 >= e2, e1 <= e2 or e1 % e2,
   * where e, e1 and e2 are constant expressions that evaluate to a numeric
   * value or to null.
   */
  static const CompileTimeErrorCode CONST_EVAL_TYPE_NUM = CompileTimeErrorCode(
      'CONST_EVAL_TYPE_NUM',
      "In constant expressions, operands of this operator must be of type "
          "'num'.");

  static const CompileTimeErrorCode CONST_EVAL_TYPE_TYPE = CompileTimeErrorCode(
      'CONST_EVAL_TYPE_TYPE',
      "In constant expressions, operands of this operator must be of type "
          "'Type'.");

  /**
   * 16.12.2 Const: It is a compile-time error if evaluation of a constant
   * object results in an uncaught exception being thrown.
   */
  static const CompileTimeErrorCode CONST_EVAL_THROWS_EXCEPTION =
      CompileTimeErrorCode('CONST_EVAL_THROWS_EXCEPTION',
          "Evaluation of this constant expression throws an exception.");

  /**
   * 16.12.2 Const: It is a compile-time error if evaluation of a constant
   * object results in an uncaught exception being thrown.
   */
  static const CompileTimeErrorCode CONST_EVAL_THROWS_IDBZE =
      CompileTimeErrorCode(
          'CONST_EVAL_THROWS_IDBZE',
          "Evaluation of this constant expression throws an "
              "IntegerDivisionByZeroException.");

  /**
   * 6.2 Formal Parameters: It is a compile-time error if a formal parameter is
   * declared as a constant variable.
   */
  static const CompileTimeErrorCode CONST_FORMAL_PARAMETER =
      CompileTimeErrorCode(
          'CONST_FORMAL_PARAMETER', "Parameters can't be const.",
          correction: "Try removing the 'const' keyword.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a value that isn't statically
  // known to be a constant is assigned to a variable that's declared to be a
  // 'const' variable.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` isn't declared to
  // be `const`:
  //
  // ```dart
  // var x = 0;
  // const y = [!x!];
  // ```
  //
  // #### Common fixes
  //
  // If the value being assigned can be declared to be `const`, then change the
  // declaration:
  //
  // ```dart
  // const x = 0;
  // const y = x;
  // ```
  //
  // If the value can't be declared to be `const`, then remove the `const`
  // modifier from the variable, possibly using `final` in its place:
  //
  // ```dart
  // var x = 0;
  // final y = x;
  // ```
  static const CompileTimeErrorCode CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE =
      CompileTimeErrorCode('CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE',
          "Const variables must be initialized with a constant value.",
          correction:
              "Try changing the initializer to be a constant expression.",
          hasPublishedDocs: true);

  /**
   * 5 Variables: A constant variable must be initialized to a compile-time
   * constant or a compile-time error occurs.
   *
   * 12.1 Constants: A qualified reference to a static constant variable that is
   * not qualified by a deferred prefix.
   */
  static const CompileTimeErrorCode
      CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE_FROM_DEFERRED_LIBRARY =
      CompileTimeErrorCode(
          'CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE_FROM_DEFERRED_LIBRARY',
          "Constant values from a deferred library can't be used to "
              "initialized a const variable.",
          correction:
              "Try initializing the variable without referencing members of "
              "the deferred library, or changing the import to not be "
              "deferred.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an instance field is marked as
  // being const.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `f` is an instance
  // field:
  //
  // ```dart
  // class C {
  //   [!const!] int f = 3;
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the field needs to be an instance field, then remove the keyword
  // `const`, or replace it with `final`:
  //
  // ```dart
  // class C {
  //   final int f = 3;
  // }
  // ```
  //
  // If the field really should be a const field, then make it a static field:
  //
  // ```dart
  // class C {
  //   static const int f = 3;
  // }
  // ```
  static const CompileTimeErrorCode CONST_INSTANCE_FIELD = CompileTimeErrorCode(
      'CONST_INSTANCE_FIELD', "Only static fields can be declared as const.",
      correction: "Try declaring the field as final, or adding the keyword "
          "'static'.");

  /**
   * 12.8 Maps: It is a compile-time error if the key of an entry in a constant
   * map literal is an instance of a class that implements the operator
   * <i>==</i> unless the key is a string or integer.
   *
   * Parameters:
   * 0: the type of the entry's key
   */
  static const CompileTimeErrorCode
      CONST_MAP_KEY_EXPRESSION_TYPE_IMPLEMENTS_EQUALS = CompileTimeErrorCode(
          'CONST_MAP_KEY_EXPRESSION_TYPE_IMPLEMENTS_EQUALS',
          "The constant map entry key expression type '{0}' can't override "
              "the == operator.",
          correction: "Try using a different value for the key, or "
              "removing the keyword 'const' from the map.");

  /**
   * Parameters:
   * 0: the name of the uninitialized final variable
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a variable that is declared to
  // be a constant doesn't have an initializer.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `c` isn't initialized:
  //
  // ```dart
  // const [!c!];
  // ```
  //
  // #### Common fixes
  //
  // Add an initializer:
  //
  // ```dart
  // const c = 'c';
  // ```
  static const CompileTimeErrorCode CONST_NOT_INITIALIZED =
      CompileTimeErrorCode(
          'CONST_NOT_INITIALIZED', "The constant '{0}' must be initialized.",
          correction: "Try adding an initialization to the declaration.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the type of the element
   */
  static const CompileTimeErrorCode CONST_SET_ELEMENT_TYPE_IMPLEMENTS_EQUALS =
      CompileTimeErrorCode(
          'CONST_SET_ELEMENT_TYPE_IMPLEMENTS_EQUALS',
          "The constant set element type '{0}' can't override "
              "the == operator.",
          correction: "Try using a different value for the element, or "
              "removing the keyword 'const' from the set.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the expression of a spread
  // operator in a constant list or set evaluates to something other than a list
  // or a set.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the value of `list1` is
  // `null`, which is neither a list nor a set:
  //
  // ```dart
  // const List<int> list1 = null;
  // const List<int> list2 = [...[!list1!]];
  // ```
  //
  // #### Common fixes
  //
  // Change the expression to something that evaluates to either a constant list
  // or a constant set:
  //
  // ```dart
  // const List<int> list1 = [];
  // const List<int> list2 = [...list1];
  // ```
  static const CompileTimeErrorCode CONST_SPREAD_EXPECTED_LIST_OR_SET =
      CompileTimeErrorCode('CONST_SPREAD_EXPECTED_LIST_OR_SET',
          "A list or a set is expected in this spread.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the expression of a spread
  // operator in a constant map evaluates to something other than a map.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the value of `map1` is
  // `null`, which isn't a map:
  //
  // ```dart
  // const Map<String, int> map1 = null;
  // const Map<String, int> map2 = {...[!map1!]};
  // ```
  //
  // #### Common fixes
  //
  // Change the expression to something that evaluates to a constant map:
  //
  // ```dart
  // const Map<String, int> map1 = {};
  // const Map<String, int> map2 = {...map1};
  // ```
  static const CompileTimeErrorCode CONST_SPREAD_EXPECTED_MAP =
      CompileTimeErrorCode(
          'CONST_SPREAD_EXPECTED_MAP', "A map is expected in this spread.",
          hasPublishedDocs: true);

  /**
   * 16.12.2 Const: If <i>T</i> is a parameterized type <i>S&lt;U<sub>1</sub>,
   * &hellip;, U<sub>m</sub>&gt;</i>, let <i>R = S</i>; It is a compile time
   * error if <i>S</i> is not a generic type with <i>m</i> type parameters.
   *
   * Parameters:
   * 0: the name of the type being referenced (<i>S</i>)
   * 1: the number of type parameters that were declared
   * 2: the number of type arguments provided
   *
   * See [StaticWarningCode.NEW_WITH_INVALID_TYPE_PARAMETERS], and
   * [StaticTypeWarningCode.WRONG_NUMBER_OF_TYPE_ARGUMENTS].
   */
  static const CompileTimeErrorCode CONST_WITH_INVALID_TYPE_PARAMETERS =
      CompileTimeErrorCode(
          'CONST_WITH_INVALID_TYPE_PARAMETERS',
          "The type '{0}' is declared with {1} type parameters, but {2} type "
              "arguments were given.",
          correction:
              "Try adjusting the number of type arguments to match the number "
              "of type parameters.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the keyword `const` is used to
  // invoke a constructor that isn't marked with `const`.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the constructor in `A`
  // isn't a const constructor:
  //
  // ```dart
  // class A {
  //   A();
  // }
  //
  // A f() => [!const!] A();
  // ```
  //
  // #### Common fixes
  //
  // If it's desirable and possible to make the class a constant class (by
  // making all of the fields of the class, including inherited fields, final),
  // then add the keyword `const` to the constructor:
  //
  // ```dart
  // class A {
  //   const A();
  // }
  //
  // A f() => const A();
  // ```
  //
  // Otherwise, remove the keyword `const`:
  //
  // ```dart
  // class A {
  //   A();
  // }
  //
  // A f() => A();
  // ```
  static const CompileTimeErrorCode CONST_WITH_NON_CONST = CompileTimeErrorCode(
      'CONST_WITH_NON_CONST',
      "The constructor being called isn't a const constructor.",
      correction: "Try removing 'const' from the constructor invocation.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a const constructor is invoked
  // with an argument that isn't a constant expression.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `i` isn't a constant:
  //
  // ```dart
  // class C {
  //   final int i;
  //   const C(this.i);
  // }
  // C f(int i) => const C([!i!]);
  // ```
  //
  // #### Common fixes
  //
  // Either make all of the arguments constant expressions, or remove the
  // `const` keyword to use the non-constant form of the constructor:
  //
  // ```dart
  // class C {
  //   final int i;
  //   const C(this.i);
  // }
  // C f(int i) => C(i);
  // ```
  static const CompileTimeErrorCode CONST_WITH_NON_CONSTANT_ARGUMENT =
      CompileTimeErrorCode('CONST_WITH_NON_CONSTANT_ARGUMENT',
          "Arguments of a constant creation must be constant expressions.",
          correction: "Try making the argument a valid constant, or "
              "use 'new' to call the constructor.",
          hasPublishedDocs: true);

  /**
   * 16.12.2 Const: It is a compile-time error if <i>T</i> is not a class
   * accessible in the current scope, optionally followed by type arguments.
   *
   * 16.12.2 Const: If <i>e</i> is of the form <i>const T.id(a<sub>1</sub>,
   * &hellip;, a<sub>n</sub>, x<sub>n+1</sub>: a<sub>n+1</sub>, &hellip;
   * x<sub>n+k</sub>: a<sub>n+k</sub>)</i> it is a compile-time error if
   * <i>T</i> is not a class accessible in the current scope, optionally
   * followed by type arguments.
   *
   * Parameters:
   * 0: the name of the non-type element
   */
  static const CompileTimeErrorCode CONST_WITH_NON_TYPE = CompileTimeErrorCode(
      'CONST_WITH_NON_TYPE', "The name '{0}' isn't a class.",
      correction: "Try correcting the name to match an existing class.");

  /**
   * 16.12.2 Const: If <i>T</i> is a parameterized type, it is a compile-time
   * error if <i>T</i> includes a type variable among its type arguments.
   */
  static const CompileTimeErrorCode CONST_WITH_TYPE_PARAMETERS =
      CompileTimeErrorCode('CONST_WITH_TYPE_PARAMETERS',
          "A constant creation can't use a type parameter as a type argument.",
          correction:
              "Try replacing the type parameter with a different type.");

  /**
   * 16.12.2 Const: It is a compile-time error if <i>T.id</i> is not the name of
   * a constant constructor declared by the type <i>T</i>.
   *
   * Parameters:
   * 0: the name of the type
   * 1: the name of the requested constant constructor
   */
  static const CompileTimeErrorCode CONST_WITH_UNDEFINED_CONSTRUCTOR =
      CompileTimeErrorCode('CONST_WITH_UNDEFINED_CONSTRUCTOR',
          "The class '{0}' doesn't have a constant constructor '{1}'.",
          correction: "Try calling a different constructor.");

  /**
   * 16.12.2 Const: It is a compile-time error if <i>T.id</i> is not the name of
   * a constant constructor declared by the type <i>T</i>.
   *
   * Parameters:
   * 0: the name of the type
   */
  static const CompileTimeErrorCode CONST_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT =
      CompileTimeErrorCode('CONST_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT',
          "The class '{0}' doesn't have a default constant constructor.",
          correction: "Try calling a different constructor.");

  /**
   * It is an error to call the default List constructor with a length argument
   * and a type argument which is potentially non-nullable.
   */
  static const CompileTimeErrorCode DEFAULT_LIST_CONSTRUCTOR_MISMATCH =
      CompileTimeErrorCode(
          'DEFAULT_LIST_CONSTRUCTOR_MISMATCH',
          "A list whose values can't be 'null' can't be given an initial "
              "length because the initial values would all be 'null'.",
          correction: "Try removing the argument or using 'List.filled'.");

  /**
   * 6.2.1 Required Formals: By means of a function signature that names the
   * parameter and describes its type as a function type. It is a compile-time
   * error if any default values are specified in the signature of such a
   * function type.
   */
  static const CompileTimeErrorCode DEFAULT_VALUE_IN_FUNCTION_TYPED_PARAMETER =
      CompileTimeErrorCode('DEFAULT_VALUE_IN_FUNCTION_TYPED_PARAMETER',
          "Default values aren't allowed in function typed parameters.",
          correction: "Try removing the default value.");

  /**
   * 7.6.2 Factories: It is a compile-time error if <i>k</i> explicitly
   * specifies a default value for an optional parameter.
   */
  static const CompileTimeErrorCode
      DEFAULT_VALUE_IN_REDIRECTING_FACTORY_CONSTRUCTOR = CompileTimeErrorCode(
          'DEFAULT_VALUE_IN_REDIRECTING_FACTORY_CONSTRUCTOR',
          "Default values aren't allowed in factory constructors that redirect "
              "to another constructor.",
          correction: "Try removing the default value.");

  /**
   * No parameters.
   */
  /* #### Description
  //
  // The analyzer produces this diagnostic when a named parameter has both the
  // `required` modifier and a default value. If the parameter is required, then
  // a value for the parameter is always provided at the call sites, so the
  // default value can never be used.
  //
  // #### Example
  //
  // The following code generates this diagnostic:
  //
  // ```dart
  // void log({required String [!message!] = 'no message'}) {}
  // ```
  //
  // #### Common fixes
  //
  // If the parameter is really required, then remove the default value:
  //
  // ```dart
  // void log({required String message}) {}
  // ```
  //
  // If the parameter isn't always required, then remove the `required`
  // modifier:
  //
  // ```dart
  // void log({String message = 'no message'}) {}
  // ``` */
  static const CompileTimeErrorCode DEFAULT_VALUE_ON_REQUIRED_PARAMETER =
      CompileTimeErrorCode('DEFAULT_VALUE_ON_REQUIRED_PARAMETER',
          "Required named parameters can't have a default value.",
          correction: "Try removing either the default value or the 'required' "
              "modifier.");

  /**
   * No parameters.
   */
  static const CompileTimeErrorCode DEFERRED_IMPORT_OF_EXTENSION =
      CompileTimeErrorCode('DEFERRED_IMPORT_OF_EXTENSION',
          "Imports of deferred libraries must hide all extensions",
          correction:
              "Try adding either a show combinator listing the names you need "
              "to reference or a hide combinator listing all of the "
              "extensions.");

  /**
   * 3.1 Scoping: It is a compile-time error if there is more than one entity
   * with the same name declared in the same scope.
   */
  static const CompileTimeErrorCode DUPLICATE_CONSTRUCTOR_DEFAULT =
      CompileTimeErrorCode('DUPLICATE_CONSTRUCTOR_DEFAULT',
          "The default constructor is already defined.",
          correction: "Try giving one of the constructors a name.");

  /**
   * 3.1 Scoping: It is a compile-time error if there is more than one entity
   * with the same name declared in the same scope.
   *
   * Parameters:
   * 0: the name of the duplicate entity
   */
  static const CompileTimeErrorCode DUPLICATE_CONSTRUCTOR_NAME =
      CompileTimeErrorCode('DUPLICATE_CONSTRUCTOR_NAME',
          "The constructor with name '{0}' is already defined.",
          correction: "Try renaming one of the constructors.");

  /**
   * Parameters:
   * 0: the name of the duplicate entity
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a name is declared, and there is
  // a previous declaration with the same name in the same scope.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the name `x` is
  // declared twice:
  //
  // ```dart
  // int x = 0;
  // int [!x!] = 1;
  // ```
  //
  // #### Common fixes
  //
  // Choose a different name for one of the declarations.
  //
  // ```dart
  // int x = 0;
  // int y = 1;
  // ```
  static const CompileTimeErrorCode DUPLICATE_DEFINITION = CompileTimeErrorCode(
      'DUPLICATE_DEFINITION', "The name '{0}' is already defined.",
      correction: "Try renaming one of the declarations.",
      hasPublishedDocs: true);

  /**
   * 18.3 Parts: It's a compile-time error if the same library contains two part
   * directives with the same URI.
   *
   * Parameters:
   * 0: the URI of the duplicate part
   */
  static const CompileTimeErrorCode DUPLICATE_PART = CompileTimeErrorCode(
      'DUPLICATE_PART',
      "The library already contains a part with the uri '{0}'.",
      correction:
          "Try removing all but one of the duplicated part directives.");

  /**
   * 12.14.2 Binding Actuals to Formals: It is a compile-time error if
   * <i>q<sub>i</sub> = q<sub>j</sub></i> for any <i>i != j</i> [where
   * <i>q<sub>i</sub></i> is the label for a named argument].
   *
   * Parameters:
   * 0: the name of the parameter that was duplicated
   */
  static const CompileTimeErrorCode DUPLICATE_NAMED_ARGUMENT =
      CompileTimeErrorCode('DUPLICATE_NAMED_ARGUMENT',
          "The argument for the named parameter '{0}' was already specified.",
          correction: "Try removing one of the named arguments, or "
              "correcting one of the names to reference a different named "
              "parameter.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when two elements in a constant set
  // literal have the same value. The set can only contain each value once,
  // which means that one of the values is unnecessary.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the string `'a'` is
  // specified twice:
  //
  // ```dart
  // const Set<String> set = {'a', [!'a'!]};
  // ```
  //
  // #### Common fixes
  //
  // Remove one of the duplicate values:
  //
  // ```dart
  // const Set<String> set = {'a'};
  // ```
  //
  // Note that literal sets preserve the order of their elements, so the choice
  // of which element to remove might affect the order in which elements are
  // returned by an iterator.
  static const CompileTimeErrorCode EQUAL_ELEMENTS_IN_CONST_SET =
      CompileTimeErrorCode('EQUAL_ELEMENTS_IN_CONST_SET',
          "Two values in a constant set can't be equal.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a key in a constant map is the
  // same as a previous key in the same map. If two keys are the same, then the
  // second value would overwrite the first value, which makes having both pairs
  // pointless.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the key `1` is used
  // twice:
  //
  // ```dart
  // const map = <int, String>{1: 'a', 2: 'b', [!1!]: 'c', 4: 'd'};
  // ```
  //
  // #### Common fixes
  //
  // If both entries should be included in the map, then change one of the keys
  // to be different:
  //
  // ```dart
  // const map = <int, String>{1: 'a', 2: 'b', 3: 'c', 4: 'd'};
  // ```
  //
  // If only one of the entries is needed, then remove the one that isn't
  // needed:
  //
  // ```dart
  // const map = <int, String>{1: 'a', 2: 'b', 4: 'd'};
  // ```
  //
  // Note that literal maps preserve the order of their entries, so the choice
  // of which entry to remove might affect the order in which keys and values
  // are returned by an iterator.
  static const CompileTimeErrorCode EQUAL_KEYS_IN_CONST_MAP =
      CompileTimeErrorCode('EQUAL_KEYS_IN_CONST_MAP',
          "Two keys in a constant map literal can't be equal.",
          correction: "Change or remove the duplicate key.",
          hasPublishedDocs: true);

  /**
   * SDK implementation libraries can be exported only by other SDK libraries.
   *
   * Parameters:
   * 0: the uri pointing to a library
   */
  static const CompileTimeErrorCode EXPORT_INTERNAL_LIBRARY =
      CompileTimeErrorCode('EXPORT_INTERNAL_LIBRARY',
          "The library '{0}' is internal and can't be exported.");

  /**
   * It is an error for an opted-in library to re-export symbols which are
   * defined in a legacy library.
   *
   * Parameters:
   * 0: the name of a symbol defined in a legacy library
   */
  static const CompileTimeErrorCode EXPORT_LEGACY_SYMBOL = CompileTimeErrorCode(
      'EXPORT_LEGACY_SYMBOL',
      "The symbol '{0}' is defined in a legacy library, and can't be "
          "re-exported from a non-nullable by default library.",
      correction: "Use show / hide combinators to avoid exporting these"
          "symbols, or migrate the legacy library.");

  /**
   * 14.2 Exports: It is a compile-time error if the compilation unit found at
   * the specified URI is not a library declaration.
   *
   * Parameters:
   * 0: the uri pointing to a non-library declaration
   */
  static const CompileTimeErrorCode EXPORT_OF_NON_LIBRARY =
      CompileTimeErrorCode('EXPORT_OF_NON_LIBRARY',
          "The exported library '{0}' can't have a part-of directive.",
          correction: "Try exporting the library that the part is a part of.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the analyzer finds an
  // expression, rather than a map entry, in what appears to be a map literal.
  //
  // #### Example
  //
  // The following code generates this diagnostic:
  //
  // ```dart
  // var map = <String, int>{'a': 0, 'b': 1, [!'c'!]};
  // ```
  //
  // #### Common fixes
  //
  // If the expression is intended to compute either a key or a value in an
  // entry, fix the issue by replacing the expression with the key or the value.
  // For example:
  //
  // ```dart
  // var map = <String, int>{'a': 0, 'b': 1, 'c': 2};
  // ```
  static const CompileTimeErrorCode EXPRESSION_IN_MAP = CompileTimeErrorCode(
      'EXPRESSION_IN_MAP', "Expressions can't be used in a map literal.",
      correction: "Try removing the expression or converting it to be a map "
          "entry.",
      hasPublishedDocs: true);

  /**
   * 12.2 Null: It is a compile-time error for a class to attempt to extend or
   * implement Null.
   *
   * 12.3 Numbers: It is a compile-time error for a class to attempt to extend
   * or implement int.
   *
   * 12.3 Numbers: It is a compile-time error for a class to attempt to extend
   * or implement double.
   *
   * 12.3 Numbers: It is a compile-time error for any type other than the types
   * int and double to
   * attempt to extend or implement num.
   *
   * 12.4 Booleans: It is a compile-time error for a class to attempt to extend
   * or implement bool.
   *
   * 12.5 Strings: It is a compile-time error for a class to attempt to extend
   * or implement String.
   *
   * Parameters:
   * 0: the name of the type that cannot be extended
   *
   * See [IMPLEMENTS_DISALLOWED_CLASS] and [MIXIN_OF_DISALLOWED_CLASS].
   *
   * TODO(scheglov) We might want to restore specific code with FrontEnd.
   * https://github.com/dart-lang/sdk/issues/31821
   */
  static const CompileTimeErrorCode EXTENDS_DISALLOWED_CLASS =
      CompileTimeErrorCode(
          'EXTENDS_DISALLOWED_CLASS', "Classes can't extend '{0}'.",
          correction: "Try specifying a different superclass, or "
              "removing the extends clause.");

  /**
   * 7.9 Superclasses: It is a compile-time error if the extends clause of a
   * class <i>C</i> includes a deferred type expression.
   *
   * Parameters:
   * 0: the name of the type that cannot be extended
   *
   * See [IMPLEMENTS_DEFERRED_CLASS], and [MIXIN_DEFERRED_CLASS].
   */
  static const CompileTimeErrorCode EXTENDS_DEFERRED_CLASS =
      CompileTimeErrorCode(
          'EXTENDS_DEFERRED_CLASS', "Classes can't extend deferred classes.",
          correction: "Try specifying a different superclass, or "
              "removing the extends clause.");

  /**
   * Parameters:
   * 0: the name in the extends clause
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extends clause contains a
  // name that is declared to be something other than a class.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `f` is declared to be a
  // function:
  //
  // ```dart
  // void f() {}
  //
  // class C extends [!f!] {}
  // ```
  //
  // #### Common fixes
  //
  // If you want the class to extend a class other than `Object`, then replace
  // the name in the extends clause with the name of that class:
  //
  // ```dart
  // void f() {}
  //
  // class C extends B {}
  //
  // class B {}
  // ```
  //
  // If you want the class to extend `Object`, then remove the extends clause:
  //
  // ```dart
  // void f() {}
  //
  // class C {}
  // ```
  static const CompileTimeErrorCode EXTENDS_NON_CLASS = CompileTimeErrorCode(
      'EXTENDS_NON_CLASS', "Classes can only extend other classes.",
      correction:
          "Try specifying a different superclass, or removing the extends "
          "clause.",
      hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the extension
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the name of an extension is used
  // in an expression other than in an extension override or to qualify an
  // access to a static member of the extension. Because classes define a type,
  // the name of a class can be used to refer to the instance of `Type`
  // representing the type of the class. Extensions, on the other hand, don't
  // define a type and can't be used as a type literal.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `E` is an extension:
  //
  // ```dart
  // extension E on int {
  //   static String m() => '';
  // }
  //
  // var x = [!E!];
  // ```
  //
  // #### Common fixes
  //
  // Replace the name of the extension with a name that can be referenced, such
  // as a static member defined on the extension:
  //
  // ```dart
  // extension E on int {
  //   static String m() => '';
  // }
  //
  // var x = E.m();
  // ```
  static const CompileTimeErrorCode EXTENSION_AS_EXPRESSION =
      CompileTimeErrorCode('EXTENSION_AS_EXPRESSION',
          "Extension '{0}' can't be used as an expression.",
          correction: "Try replacing it with a valid expression.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the extension defining the conflicting member
   * 1: the name of the conflicting static member
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extension declaration
  // contains both an instance member and a static member that have the same
  // name. The instance member and the static member can't have the same name
  // because it's unclear which member is being referenced by an unqualified use
  // of the name within the body of the extension.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the name `a` is being
  // used for two different members:
  //
  // ```dart
  // extension E on Object {
  //   int get a => 0;
  //   static int [!a!]() => 0;
  // }
  // ```
  //
  // #### Common fixes
  //
  // Rename or remove one of the members:
  //
  // ```dart
  // extension E on Object {
  //   int get a => 0;
  //   static int b() => 0;
  // }
  // ```
  static const CompileTimeErrorCode EXTENSION_CONFLICTING_STATIC_AND_INSTANCE =
      CompileTimeErrorCode(
          'EXTENSION_CONFLICTING_STATIC_AND_INSTANCE',
          "Extension '{0}' can't define static member '{1}' and an instance "
              "member with the same name.",
          correction:
              "Try renaming the member to a name that doesn't conflict.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extension declaration
  // declares a member with the same name as a member declared in the class
  // `Object`. Such a member can never be used because the member in `Object` is
  // always found first.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `toString` is defined
  // by `Object`:
  //
  // ```dart
  // extension E on String {
  //   String [!toString!]() => this;
  // }
  // ```
  //
  // #### Common fixes
  //
  // Remove the member or rename it so that the name doesn't conflict with the
  // member in `Object`:
  //
  // ```dart
  // extension E on String {
  //   String displayString() => this;
  // }
  // ```
  static const CompileTimeErrorCode EXTENSION_DECLARES_MEMBER_OF_OBJECT =
      CompileTimeErrorCode(
          'EXTENSION_DECLARES_MEMBER_OF_OBJECT',
          "Extensions can't declare members with the same name as a member "
              "declared by 'Object'.",
          correction: "Try specifying a different name for the member.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extension override is the
  // target of the invocation of a static member. Similar to static members in
  // classes, the static members of an extension should be accessed using the
  // name of the extension, not an extension override.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `m` is static:
  //
  // ```dart
  // extension E on String {
  //   static void m() {}
  // }
  //
  // void f() {
  //   E('').[!m!]();
  // }
  // ```
  //
  // #### Common fixes
  //
  // Replace the extension override with the name of the extension:
  //
  // ```dart
  // extension E on String {
  //   static void m() {}
  // }
  //
  // void f() {
  //   E.m();
  // }
  // ```
  static const CompileTimeErrorCode EXTENSION_OVERRIDE_ACCESS_TO_STATIC_MEMBER =
      CompileTimeErrorCode(
          'EXTENSION_OVERRIDE_ACCESS_TO_STATIC_MEMBER',
          "An extension override can't be used to access a static member from "
              "an extension.",
          correction: "Try using just the name of the extension.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the type of the argument
   * 1: the extended type
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the argument to an extension
  // override isn't assignable to the type being extended by the extension.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `3` isn't a `String`:
  //
  // ```dart
  // extension E on String {
  //   void method() {}
  // }
  //
  // void f() {
  //   E([!3!]).method();
  // }
  // ```
  //
  // #### Common fixes
  //
  // If you're using the correct extension, then update the argument to have the
  // correct type:
  //
  // ```dart
  // extension E on String {
  //   void method() {}
  // }
  //
  // void f() {
  //   E(3.toString()).method();
  // }
  // ```
  //
  // If there's a different extension that's valid for the type of the argument,
  // then either replace the name of the extension or unwrap the target so that
  // the correct extension is found.
  static const CompileTimeErrorCode EXTENSION_OVERRIDE_ARGUMENT_NOT_ASSIGNABLE =
      CompileTimeErrorCode(
          'EXTENSION_OVERRIDE_ARGUMENT_NOT_ASSIGNABLE',
          "The type of the argument to the extension override '{0}' "
              "isn't assignable to the extended type '{1}'.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extension override is used as
  // the target of a cascade expression. The value of a cascade expression
  // `e..m` is the value of the target `e`, but extension overrides are not
  // expressions and don't have a value.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `E(3)` isn't an
  // expression:
  //
  // ```dart
  // extension E on int {
  //   void m() {}
  // }
  // f() {
  //   E(3)[!..!]m();
  // }
  // ```
  //
  // #### Common fixes
  //
  // Use '.' rather than '..':
  //
  // ```dart
  // extension E on int {
  //   void m() {}
  // }
  // f() {
  //   E(3).m();
  // }
  // ```
  //
  // If there are multiple cascaded accesses, you'll need to duplicate the
  // extension override for each one.
  static const CompileTimeErrorCode EXTENSION_OVERRIDE_WITH_CASCADE =
      CompileTimeErrorCode(
          'EXTENSION_OVERRIDE_WITH_CASCADE',
          "Extension overrides have no value so they can't be used as the "
              "target of a cascade expression.",
          correction: "Try using '.' instead of '..'.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extension override is found
  // that isn't being used to access one of the members of the extension. The
  // extension override syntax doesn't have any runtime semantics; it only
  // controls which member is selected at compile time.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `E(i)` isn't an
  // expression:
  //
  // ```dart
  // extension E on int {
  //   int get a => 0;
  // }
  //
  // void f(int i) {
  //   print([!E(i)!]);
  // }
  // ```
  //
  // #### Common fixes
  //
  // If you want to invoke one of the members of the extension, then add the
  // invocation:
  //
  // ```dart
  // extension E on int {
  //   int get a => 0;
  // }
  //
  // void f(int i) {
  //   print(E(i).a);
  // }
  // ```
  //
  // If you don't want to invoke a member, then unwrap the target:
  //
  // ```dart
  // extension E on int {
  //   int get a => 0;
  // }
  //
  // void f(int i) {
  //   print(i);
  // }
  // ```
  static const CompileTimeErrorCode EXTENSION_OVERRIDE_WITHOUT_ACCESS =
      CompileTimeErrorCode('EXTENSION_OVERRIDE_WITHOUT_ACCESS',
          "An extension override can only be used to access instance members.",
          correction: "Consider adding an access to an instance member.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the maximum number of positional arguments
   * 1: the actual number of positional arguments given
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a method or function invocation
  // has more positional arguments than the method or function allows.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `f` defines 2
  // parameters but is invoked with 3 arguments:
  //
  // ```dart
  // void f(int a, int b) {}
  // void g() {
  //   f[!(1, 2, 3)!];
  // }
  // ```
  //
  // #### Common fixes
  //
  // Remove the arguments that don't correspond to parameters:
  //
  // ```dart
  // void f(int a, int b) {}
  // void g() {
  //   f(1, 2);
  // }
  // ```
  static const CompileTimeErrorCode EXTRA_POSITIONAL_ARGUMENTS =
      CompileTimeErrorCode('EXTRA_POSITIONAL_ARGUMENTS',
          "Too many positional arguments: {0} expected, but {1} found.",
          correction: "Try removing the extra arguments.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the maximum number of positional arguments
   * 1: the actual number of positional arguments given
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a method or function invocation
  // has more positional arguments than the method or function allows, but the
  // method or function defines named parameters.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `f` defines 2
  // positional parameters but has a named parameter that could be used for the
  // third argument:
  //
  // ```dart
  // void f(int a, int b, {int c}) {}
  // void g() {
  //   f[!(1, 2, 3)!];
  // }
  // ```
  //
  // #### Common fixes
  //
  // If some of the arguments should be values for named parameters, then add
  // the names before the arguments:
  //
  // ```dart
  // void f(int a, int b, {int c}) {}
  // void g() {
  //   f(1, 2, c: 3);
  // }
  // ```
  //
  // Otherwise, remove the arguments that don't correspond to positional
  // parameters:
  //
  // ```dart
  // void f(int a, int b, {int c}) {}
  // void g() {
  //   f(1, 2);
  // }
  // ```
  static const CompileTimeErrorCode EXTRA_POSITIONAL_ARGUMENTS_COULD_BE_NAMED =
      CompileTimeErrorCode('EXTRA_POSITIONAL_ARGUMENTS_COULD_BE_NAMED',
          "Too many positional arguments: {0} expected, but {1} found.",
          correction: "Try removing the extra positional arguments, "
              "or specifying the name for named arguments.",
          hasPublishedDocs: true);

  /**
   * 7.6.1 Generative Constructors: Let <i>k</i> be a generative constructor. It
   * is a compile time error if more than one initializer corresponding to a
   * given instance variable appears in <i>k</i>'s list.
   *
   * Parameters:
   * 0: the name of the field being initialized multiple times
   */
  static const CompileTimeErrorCode FIELD_INITIALIZED_BY_MULTIPLE_INITIALIZERS =
      CompileTimeErrorCode('FIELD_INITIALIZED_BY_MULTIPLE_INITIALIZERS',
          "The field '{0}' can't be initialized twice in the same constructor.",
          correction: "Try removing one of the initializations.");

  /**
   * 7.6.1 Generative Constructors: Let <i>k</i> be a generative constructor. It
   * is a compile time error if <i>k</i>'s initializer list contains an
   * initializer for a variable that is initialized by means of an initializing
   * formal of <i>k</i>.
   */
  static const CompileTimeErrorCode
      FIELD_INITIALIZED_IN_PARAMETER_AND_INITIALIZER = CompileTimeErrorCode(
          'FIELD_INITIALIZED_IN_PARAMETER_AND_INITIALIZER',
          "Fields can't be initialized in both the parameter list and the "
              "initializers.",
          correction: "Try removing one of the initializations.");

  /**
   * 7.6.1 Generative Constructors: It is a compile-time error if an
   * initializing formal is used by a function other than a non-redirecting
   * generative constructor.
   */
  static const CompileTimeErrorCode FIELD_INITIALIZER_FACTORY_CONSTRUCTOR =
      CompileTimeErrorCode(
          'FIELD_INITIALIZER_FACTORY_CONSTRUCTOR',
          "Initializing formal parameters can't be used in factory "
              "constructors.",
          correction: "Try using a normal parameter.");

  /**
   * 7.6.1 Generative Constructors: It is a compile-time error if an
   * initializing formal is used by a function other than a non-redirecting
   * generative constructor.
   */
  static const CompileTimeErrorCode FIELD_INITIALIZER_OUTSIDE_CONSTRUCTOR =
      CompileTimeErrorCode('FIELD_INITIALIZER_OUTSIDE_CONSTRUCTOR',
          "Initializing formal parameters can only be used in constructors.",
          correction: "Try using a normal parameter.");

  /**
   * 7.6.1 Generative Constructors: A generative constructor may be redirecting,
   * in which case its only action is to invoke another generative constructor.
   *
   * 7.6.1 Generative Constructors: It is a compile-time error if an
   * initializing formal is used by a function other than a non-redirecting
   * generative constructor.
   */
  static const CompileTimeErrorCode FIELD_INITIALIZER_REDIRECTING_CONSTRUCTOR =
      CompileTimeErrorCode('FIELD_INITIALIZER_REDIRECTING_CONSTRUCTOR',
          "The redirecting constructor can't have a field initializer.",
          correction: "Try using a normal parameter.");

  /**
   * 5 Variables: It is a compile-time error if a final instance variable that
   * has is initialized by means of an initializing formal of a constructor is
   * also initialized elsewhere in the same constructor.
   *
   * Parameters:
   * 0: the name of the field in question
   */
  static const CompileTimeErrorCode FINAL_INITIALIZED_MULTIPLE_TIMES =
      CompileTimeErrorCode('FINAL_INITIALIZED_MULTIPLE_TIMES',
          "'{0}' is a final field and so can only be set once.",
          correction: "Try removing all but one of the initializations.");

  static const CompileTimeErrorCode FOR_IN_WITH_CONST_VARIABLE =
      CompileTimeErrorCode('FOR_IN_WITH_CONST_VARIABLE',
          "A for-in loop-variable can't be 'const'.",
          correction: "Try removing the 'const' modifier from the variable, or "
              "use a different variable.");

  /**
   * It is a compile-time error if a generic function type is used as a bound
   * for a formal type parameter of a class or a function.
   */
  static const CompileTimeErrorCode GENERIC_FUNCTION_TYPE_CANNOT_BE_BOUND =
      CompileTimeErrorCode('GENERIC_FUNCTION_TYPE_CANNOT_BE_BOUND',
          "Generic function types can't be used as type parameter bounds",
          correction: "Try making the free variable in the function type part"
              " of the larger declaration signature");

  /**
   * It is a compile-time error if a generic function type is used as an actual
   * type argument.
   */
  static const CompileTimeErrorCode
      GENERIC_FUNCTION_TYPE_CANNOT_BE_TYPE_ARGUMENT = CompileTimeErrorCode(
          'GENERIC_FUNCTION_TYPE_CANNOT_BE_TYPE_ARGUMENT',
          "A generic function type can't be a type argument.",
          correction: "Try removing type parameters from the generic function "
              "type, or using 'dynamic' as the type argument here.");

  static const CompileTimeErrorCode IF_ELEMENT_CONDITION_FROM_DEFERRED_LIBRARY =
      CompileTimeErrorCode(
          'IF_ELEMENT_CONDITION_FROM_DEFERRED_LIBRARY',
          "Constant values from a deferred library can't be used as values in "
              "an if condition inside a const collection literal.",
          correction: "Try making the deferred import non-deferred.");

  /**
   * 7.10 Superinterfaces: It is a compile-time error if the implements clause
   * of a class <i>C</i> specifies a malformed type or deferred type as a
   * superinterface.
   *
   * See [EXTENDS_DEFERRED_CLASS], and [MIXIN_DEFERRED_CLASS].
   */
  static const CompileTimeErrorCode IMPLEMENTS_DEFERRED_CLASS =
      CompileTimeErrorCode('IMPLEMENTS_DEFERRED_CLASS',
          "Classes and mixins can't implement deferred classes.",
          correction: "Try specifying a different interface, "
              "removing the class from the list, or "
              "changing the import to not be deferred.");

  /**
   * 12.2 Null: It is a compile-time error for a class to attempt to extend or
   * implement Null.
   *
   * 12.3 Numbers: It is a compile-time error for a class to attempt to extend
   * or implement int.
   *
   * 12.3 Numbers: It is a compile-time error for a class to attempt to extend
   * or implement double.
   *
   * 12.3 Numbers: It is a compile-time error for any type other than the types
   * int and double to
   * attempt to extend or implement num.
   *
   * 12.4 Booleans: It is a compile-time error for a class to attempt to extend
   * or implement bool.
   *
   * 12.5 Strings: It is a compile-time error for a class to attempt to extend
   * or implement String.
   *
   * Parameters:
   * 0: the name of the type that cannot be implemented
   *
   * See [EXTENDS_DISALLOWED_CLASS].
   */
  static const CompileTimeErrorCode IMPLEMENTS_DISALLOWED_CLASS =
      CompileTimeErrorCode('IMPLEMENTS_DISALLOWED_CLASS',
          "Classes and mixins can't implement '{0}'.",
          correction: "Try specifying a different interface, or "
              "remove the class from the list.");

  /**
   * Parameters:
   * 0: the name of the interface that was not found
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a name used in the implements
  // clause of a class or mixin declaration is defined to be something other
  // than a class or mixin.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` is a variable
  // rather than a class or mixin:
  //
  // ```dart
  // var x;
  // class C implements [!x!] {}
  // ```
  //
  // #### Common fixes
  //
  // If the name is the name of an existing class or mixin that's already being
  // imported, then add a prefix to the import so that the local definition of
  // the name doesn't shadow the imported name.
  //
  // If the name is the name of an existing class or mixin that isn't being
  // imported, then add an import, with a prefix, for the library in which it’s
  // declared.
  //
  // Otherwise, either replace the name in the implements clause with the name
  // of an existing class or mixin, or remove the name from the implements
  // clause.
  static const CompileTimeErrorCode IMPLEMENTS_NON_CLASS = CompileTimeErrorCode(
      'IMPLEMENTS_NON_CLASS',
      "Classes and mixins can only implement other classes and mixins.",
      correction:
          "Try specifying a class or mixin, or remove the name from the "
          "list.",
      hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the interface that is implemented more than once
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a single class is specified more
  // than once in an implements clause.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `A` is in the list
  // twice:
  //
  // ```dart
  // class A {}
  // class B implements A, [!A!] {}
  // ```
  //
  // #### Common fixes
  //
  // Remove all except one occurrence of the class name:
  //
  // ```dart
  // class A {}
  // class B implements A {}
  // ```
  static const CompileTimeErrorCode IMPLEMENTS_REPEATED = CompileTimeErrorCode(
      'IMPLEMENTS_REPEATED', "'{0}' can only be implemented once.",
      correction: "Try removing all but one occurrence of the class name.");

  /**
   * 7.10 Superinterfaces: It is a compile-time error if the superclass of a
   * class <i>C</i> appears in the implements clause of <i>C</i>.
   *
   * Parameters:
   * 0: the name of the class that appears in both "extends" and "implements"
   *    clauses
   */
  static const CompileTimeErrorCode IMPLEMENTS_SUPER_CLASS =
      CompileTimeErrorCode('IMPLEMENTS_SUPER_CLASS',
          "'{0}' can't be used in both 'extends' and 'implements' clauses.",
          correction: "Try removing one of the occurrences.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it finds a reference to an
  // instance member in a constructor's initializer list.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `defaultX` is an
  // instance member:
  //
  // ```dart
  // class C {
  //   int x;
  //
  //   C() : x = [!defaultX!];
  //
  //   int get defaultX => 0;
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the member can be made static, then do so:
  //
  // ```dart
  // class C {
  //   int x;
  //
  //   C() : x = defaultX;
  //
  //   static int get defaultX => 0;
  // }
  // ```
  //
  // If not, then replace the reference in the initializer with a different
  // expression that doesn't use an instance member:
  //
  // ```dart
  // class C {
  //   int x;
  //
  //   C() : x = 0;
  //
  //   int get defaultX => 0;
  // }
  // ```
  static const CompileTimeErrorCode IMPLICIT_THIS_REFERENCE_IN_INITIALIZER =
      CompileTimeErrorCode('IMPLICIT_THIS_REFERENCE_IN_INITIALIZER',
          "Only static members can be accessed in initializers.",
          hasPublishedDocs: true);

  /**
   * SDK implementation libraries can be imported only by other SDK libraries.
   *
   * Parameters:
   * 0: the uri pointing to a library
   */
  static const CompileTimeErrorCode IMPORT_INTERNAL_LIBRARY =
      CompileTimeErrorCode('IMPORT_INTERNAL_LIBRARY',
          "The library '{0}' is internal and can't be imported.");

  /**
   * 14.1 Imports: It is a compile-time error if the specified URI of an
   * immediate import does not refer to a library declaration.
   *
   * Parameters:
   * 0: the uri pointing to a non-library declaration
   */
  static const CompileTimeErrorCode IMPORT_OF_NON_LIBRARY =
      CompileTimeErrorCode('IMPORT_OF_NON_LIBRARY',
          "The imported library '{0}' can't have a part-of directive.",
          correction: "Try importing the library that the part is a part of.");

  /**
   * 13.9 Switch: It is a compile-time error if values of the expressions
   * <i>e<sub>k</sub></i> are not instances of the same class <i>C</i>, for all
   * <i>1 &lt;= k &lt;= n</i>.
   *
   * Parameters:
   * 0: the expression source code that is the unexpected type
   * 1: the name of the expected type
   */
  static const CompileTimeErrorCode INCONSISTENT_CASE_EXPRESSION_TYPES =
      CompileTimeErrorCode('INCONSISTENT_CASE_EXPRESSION_TYPES',
          "Case expressions must have the same types, '{0}' isn't a '{1}'.");

  /**
   * If a class declaration does not have a member declaration with a
   * particular name, but some super-interfaces do have a member with that
   * name, it's a compile-time error if there is no signature among the
   * super-interfaces that is a valid override of all the other super-interface
   * signatures with the same name. That "most specific" signature becomes the
   * signature of the class's interface.
   *
   * Parameters:
   * 0: the name of the instance member with inconsistent inheritance.
   * 1: the list of all inherited signatures for this member.
   */
  static const CompileTimeErrorCode INCONSISTENT_INHERITANCE =
      CompileTimeErrorCode('INCONSISTENT_INHERITANCE',
          "Superinterfaces don't have a valid override for '{0}': {1}.",
          correction:
              "Try adding an explicit override that is consistent with all "
              "of the inherited members.");

  /**
   * 11.1.1 Inheritance and Overriding. Let `I` be the implicit interface of a
   * class `C` declared in library `L`. `I` inherits all members of
   * `inherited(I, L)` and `I` overrides `m'` if `m' ∈ overrides(I, L)`. It is
   * a compile-time error if `m` is a method and `m'` is a getter, or if `m`
   * is a getter and `m'` is a method.
   *
   * Parameters:
   * 0: the name of the the instance member with inconsistent inheritance.
   * 1: the name of the superinterface that declares the name as a getter.
   * 2: the name of the superinterface that declares the name as a method.
   */
  static const CompileTimeErrorCode INCONSISTENT_INHERITANCE_GETTER_AND_METHOD =
      CompileTimeErrorCode(
          'INCONSISTENT_INHERITANCE_GETTER_AND_METHOD',
          "'{0}' is inherited as a getter (from '{1}') and also a "
              "method (from '{2}').",
          correction:
              "Try adjusting the supertypes of this class to remove the "
              "inconsistency.");

  /**
   * Parameters:
   * 0: the name of the initializing formal that is not an instance variable in
   *    the immediately enclosing class
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a constructor initializes a
  // field that isn't declared in the class containing the constructor.
  // Constructors can't initialize fields that aren't declared and fields that
  // are inherited from superclasses.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the initializer is
  // initializing `x`, but `x` isn't a field in the class:
  //
  // ```dart
  // class C {
  //   int y;
  //
  //   C() : [!x = 0!];
  // }
  // ```
  //
  // #### Common fixes
  //
  // If a different field should be initialized, then change the name to the
  // name of the field:
  //
  // ```dart
  // class C {
  //   int y;
  //
  //   C() : y = 0;
  // }
  // ```
  //
  // If the field must be declared, then add a declaration:
  //
  // ```dart
  // class C {
  //   int x;
  //   int y;
  //
  //   C() : x = 0;
  // }
  // ```
  static const CompileTimeErrorCode INITIALIZER_FOR_NON_EXISTENT_FIELD =
      CompileTimeErrorCode('INITIALIZER_FOR_NON_EXISTENT_FIELD',
          "'{0}' isn't a field in the enclosing class.",
          correction: "Try correcting the name to match an existing field, or "
              "defining a field named '{0}'.");

  /**
   * 7.6.1 Generative Constructors: Let <i>k</i> be a generative constructor. It
   * is a compile-time error if <i>k</i>'s initializer list contains an
   * initializer for a variable that is not an instance variable declared in the
   * immediately surrounding class.
   *
   * Parameters:
   * 0: the name of the initializing formal that is a static variable in the
   *    immediately enclosing class
   *
   * See [INITIALIZING_FORMAL_FOR_STATIC_FIELD].
   */
  static const CompileTimeErrorCode INITIALIZER_FOR_STATIC_FIELD =
      CompileTimeErrorCode(
          'INITIALIZER_FOR_STATIC_FIELD',
          "'{0}' is a static field in the enclosing class. Fields initialized "
              "in a constructor can't be static.",
          correction: "Try removing the initialization.");

  /**
   * Parameters:
   * 0: the name of the initializing formal that is not an instance variable in
   *    the immediately enclosing class
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a field formal parameter is
  // found in a constructor in a class that doesn't declare the field being
  // initialized. Constructors can't initialize fields that aren't declared and
  // fields that are inherited from superclasses.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the field `x` isn't
  // defined:
  //
  // ```dart
  // class C {
  //   int y;
  //
  //   C([!this.x!]);
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the field name was wrong, then change it to the name of an existing
  // field:
  //
  // ```dart
  // class C {
  //   int y;
  //
  //   C(this.y);
  // }
  // ```
  //
  // If the field name is correct but hasn't yet been defined, then declare the
  // field:
  //
  // ```dart
  // class C {
  //   int x;
  //   int y;
  //
  //   C(this.x);
  // }
  // ```
  //
  // If the parameter is needed but shouldn't initialize a field, then convert
  // it to a normal parameter and use it:
  //
  // ```dart
  // class C {
  //   int y;
  //
  //   C(int x) : y = x * 2;
  // }
  // ```
  //
  // If the parameter isn't needed, then remove it:
  //
  // ```dart
  // class C {
  //   int y;
  //
  //   C();
  // }
  // ```
  static const CompileTimeErrorCode INITIALIZING_FORMAL_FOR_NON_EXISTENT_FIELD =
      CompileTimeErrorCode('INITIALIZING_FORMAL_FOR_NON_EXISTENT_FIELD',
          "'{0}' isn't a field in the enclosing class.",
          correction: "Try correcting the name to match an existing field, or "
              "defining a field named '{0}'.",
          hasPublishedDocs: true);

  /**
   * 7.6.1 Generative Constructors: An initializing formal has the form
   * <i>this.id</i>. It is a compile-time error if <i>id</i> is not the name of
   * an instance variable of the immediately enclosing class.
   *
   * Parameters:
   * 0: the name of the initializing formal that is a static variable in the
   *    immediately enclosing class
   *
   * See [INITIALIZER_FOR_STATIC_FIELD].
   */
  static const CompileTimeErrorCode INITIALIZING_FORMAL_FOR_STATIC_FIELD =
      CompileTimeErrorCode(
          'INITIALIZING_FORMAL_FOR_STATIC_FIELD',
          "'{0}' is a static field in the enclosing class. Fields initialized "
              "in a constructor can't be static.",
          correction: "Try removing the initialization.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a factory constructor contains
  // an unqualified reference to an instance member. In a generative
  // constructor, the instance of the class is created and initialized before
  // the body of the constructor is executed, so the instance can be bound to
  // `this` and accessed just like it would be in an instance method. But, in a
  // factory constructor, the instance isn't created before executing the body,
  // so `this` can't be used to reference it.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` isn't in scope in
  // the factory constructor:
  //
  // ```dart
  // class C {
  //   int x;
  //   factory C() {
  //     return C._([!x!]);
  //   }
  //   C._(this.x);
  // }
  // ```
  //
  // #### Common fixes
  //
  // Rewrite the code so that it doesn't reference the instance member:
  //
  // ```dart
  // class C {
  //   int x;
  //   factory C() {
  //     return C._(0);
  //   }
  //   C._(this.x);
  // }
  // ```
  static const CompileTimeErrorCode INSTANCE_MEMBER_ACCESS_FROM_FACTORY =
      CompileTimeErrorCode('INSTANCE_MEMBER_ACCESS_FROM_FACTORY',
          "Instance members can't be accessed from a factory constructor.",
          correction: "Try removing the reference to the instance member.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a static method contains an
  // unqualified reference to an instance member.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the instance field `x`
  // is being referenced in a static method:
  //
  // ```dart
  // class C {
  //   int x;
  //
  //   static int m() {
  //     return [!x!];
  //   }
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the method must reference the instance member, then it can't be static,
  // so remove the keyword:
  //
  // ```dart
  // class C {
  //   int x;
  //
  //   int m() {
  //     return x;
  //   }
  // }
  // ```
  //
  // If the method can't be made an instance method, then add a parameter so
  // that an instance of the class can be passed in:
  //
  // ```dart
  // class C {
  //   int x;
  //
  //   static int m(C c) {
  //     return c.x;
  //   }
  // }
  // ```
  static const CompileTimeErrorCode INSTANCE_MEMBER_ACCESS_FROM_STATIC =
      CompileTimeErrorCode('INSTANCE_MEMBER_ACCESS_FROM_STATIC',
          "Instance members can't be accessed from a static method.",
          correction: "Try removing the reference to the instance member, or "
              "removing the keyword 'static' from the method.");

  /**
   * Enum proposal: It is also a compile-time error to explicitly instantiate an
   * enum via 'new' or 'const' or to access its private fields.
   */
  static const CompileTimeErrorCode INSTANTIATE_ENUM = CompileTimeErrorCode(
      'INSTANTIATE_ENUM', "Enums can't be instantiated.",
      correction: "Try using one of the defined constants.");

  static const CompileTimeErrorCode INTEGER_LITERAL_OUT_OF_RANGE =
      CompileTimeErrorCode('INTEGER_LITERAL_OUT_OF_RANGE',
          "The integer literal {0} can't be represented in 64 bits.",
          correction:
              "Try using the BigInt class if you need an integer larger than "
              "9,223,372,036,854,775,807 or less than "
              "-9,223,372,036,854,775,808.");

  /**
   * An integer literal with static type `double` and numeric value `i`
   * evaluates to an instance of the `double` class representing the value `i`.
   * It is a compile-time error if the value `i` cannot be represented
   * _precisely_ by the an instace of `double`.
   */
  static const CompileTimeErrorCode INTEGER_LITERAL_IMPRECISE_AS_DOUBLE =
      CompileTimeErrorCode(
          'INTEGER_LITERAL_IMPRECISE_AS_DOUBLE',
          "The integer literal is being used as a double, but can't be "
              "represented as a 64 bit double without overflow and/or loss of "
              "precision: {0}",
          correction:
              "Try using the BigInt class, or switch to the closest valid "
              "double: {1}");

  /**
   * 15 Metadata: Metadata consists of a series of annotations, each of which
   * begin with the character @, followed by a constant expression that must be
   * either a reference to a compile-time constant variable, or a call to a
   * constant constructor.
   */
  static const CompileTimeErrorCode INVALID_ANNOTATION = CompileTimeErrorCode(
      'INVALID_ANNOTATION',
      "Annotation must be either a const variable reference or const "
          "constructor invocation.");

  /**
   * 15 Metadata: Metadata consists of a series of annotations, each of which
   * begin with the character @, followed by a constant expression that must be
   * either a reference to a compile-time constant variable, or a call to a
   * constant constructor.
   *
   * 12.1 Constants: A qualified reference to a static constant variable that is
   * not qualified by a deferred prefix.
   */
  static const CompileTimeErrorCode INVALID_ANNOTATION_FROM_DEFERRED_LIBRARY =
      CompileTimeErrorCode(
          'INVALID_ANNOTATION_FROM_DEFERRED_LIBRARY',
          "Constant values from a deferred library can't be used as "
              "annotations.",
          correction: "Try removing the annotation, or "
              "changing the import to not be deferred.");

  /**
   * 15 Metadata: Metadata consists of a series of annotations, each of which
   * begin with the character @, followed by a constant expression that must be
   * either a reference to a compile-time constant variable, or a call to a
   * constant constructor.
   */
  static const CompileTimeErrorCode INVALID_ANNOTATION_GETTER =
      CompileTimeErrorCode(
          'INVALID_ANNOTATION_GETTER', "Getters can't be used as annotations.",
          correction: "Try using a top-level variable or a field.");

  /**
   * TODO(brianwilkerson) Remove this when we have decided on how to report
   * errors in compile-time constants. Until then, this acts as a placeholder
   * for more informative errors.
   *
   * See TODOs in ConstantVisitor
   */
  static const CompileTimeErrorCode INVALID_CONSTANT =
      CompileTimeErrorCode('INVALID_CONSTANT', "Invalid constant value.");

  /**
   * 7.6 Constructors: It is a compile-time error if the name of a constructor
   * is not a constructor name.
   */
  static const CompileTimeErrorCode INVALID_CONSTRUCTOR_NAME =
      CompileTimeErrorCode(
          'INVALID_CONSTRUCTOR_NAME', "Invalid constructor name.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extension override doesn't
  // have exactly one argument. The argument is the expression used to compute
  // the value of `this` within the extension method, so there must be one
  // argument.
  //
  // #### Example
  //
  // The following code produces this diagnostic because there are no arguments:
  //
  // ```dart
  // extension E on String {
  //   String join(String other) => '$this $other';
  // }
  //
  // void f() {
  //   E[!()!].join('b');
  // }
  // ```
  //
  // And, the following code produces this diagnostic because there's more than
  // one argument:
  //
  // ```dart
  // extension E on String {
  //   String join(String other) => '$this $other';
  // }
  //
  // void f() {
  //   E[!('a', 'b')!].join('c');
  // }
  // ```
  //
  // #### Common fixes
  //
  // Provide one argument for the extension override:
  //
  // ```dart
  // extension E on String {
  //   String join(String other) => '$this $other';
  // }
  //
  // void f() {
  //   E('a').join('b');
  // }
  // ```
  static const CompileTimeErrorCode INVALID_EXTENSION_ARGUMENT_COUNT =
      CompileTimeErrorCode(
          'INVALID_EXTENSION_ARGUMENT_COUNT',
          "Extension overrides must have exactly one argument: "
              "the value of 'this' in the extension method.",
          correction: "Try specifying exactly one argument.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the name of a factory
  // constructor isn't the same as the name of the surrounding class.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the name of the factory
  // constructor (`A`) isn't the same as the surrounding class (`C`):
  //
  // ```dart
  // class A {}
  //
  // class C {
  //   factory [!A!]() => null;
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the factory returns an instance of the surrounding class, then rename
  // the factory:
  //
  // ```dart
  // class A {}
  //
  // class C {
  //   factory C() => null;
  // }
  // ```
  //
  // If the factory returns an instance of a different class, then move the
  // factory to that class:
  //
  // ```dart
  // class A {
  //   factory A() => null;
  // }
  //
  // class C {}
  // ```
  //
  // If the factory returns an instance of a different class, but you can't
  // modify that class or don't want to move the factory, then convert it to be
  // a static method:
  //
  // ```dart
  // class A {}
  //
  // class C {
  //   static A a() => null;
  // }
  // ```
  static const CompileTimeErrorCode INVALID_FACTORY_NAME_NOT_A_CLASS =
      CompileTimeErrorCode(
          'INVALID_FACTORY_NAME_NOT_A_CLASS',
          "The name of a factory constructor must be the same as the name of "
              "the immediately enclosing class.");

  static const CompileTimeErrorCode INVALID_INLINE_FUNCTION_TYPE =
      CompileTimeErrorCode(
          'INVALID_INLINE_FUNCTION_TYPE',
          "Inline function types can't be used for parameters in a generic "
              "function type.",
          correction: "Try using a generic function type "
              "(returnType 'Function(' parameters ')').");

  /**
   * 9. Functions: It is a compile-time error if an async, async* or sync*
   * modifier is attached to the body of a setter or constructor.
   */
  static const CompileTimeErrorCode INVALID_MODIFIER_ON_CONSTRUCTOR =
      CompileTimeErrorCode('INVALID_MODIFIER_ON_CONSTRUCTOR',
          "The modifier '{0}' can't be applied to the body of a constructor.",
          correction: "Try removing the modifier.");

  /**
   * 9. Functions: It is a compile-time error if an async, async* or sync*
   * modifier is attached to the body of a setter or constructor.
   */
  static const CompileTimeErrorCode INVALID_MODIFIER_ON_SETTER =
      CompileTimeErrorCode('INVALID_MODIFIER_ON_SETTER',
          "The modifier '{0}' can't be applied to the body of a setter.",
          correction: "Try removing the modifier.");

  /**
   * It is an error if an optional parameter (named or otherwise) with no
   * default value has a potentially non-nullable type. This is produced in
   * cases where there is no valid default value.
   */
  static const CompileTimeErrorCode INVALID_OPTIONAL_PARAMETER_TYPE =
      CompileTimeErrorCode(
          'INVALID_OPTIONAL_PARAMETER_TYPE',
          "The parameter '{0}' can't have a value of 'null' because of its "
              "type, but no non-null default value is provided.",
          correction: "Try making this nullable (by adding a '?'), "
              "adding a default value, or "
              "making this a required parameter.");

  /**
   * Parameters:
   * 0: the name of the declared member that is not a valid override.
   * 1: the name of the interface that declares the member.
   * 2: the type of the declared member in the interface.
   * 3. the name of the interface with the overridden member.
   * 4. the type of the overridden member.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a member of a class is found
  // that overrides a member from a supertype and the override isn't valid. An
  // override is valid if all of these are true:
  // * It allows all of the arguments allowed by the overridden member.
  // * It doesn't require any arguments that aren't required by the overridden
  //   member.
  // * The type of every parameter of the overridden member is assignable to the
  //   corresponding parameter of the override.
  // * The return type of the override is assignable to the return type of the
  //   overridden member.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the type of the
  // parameter `s` (`String`) isn't assignable to the type of the parameter `i`
  // (`int`):
  //
  // ```dart
  // class A {
  //   void m(int i) {}
  // }
  //
  // class B extends A {
  //   void [!m!](String s) {}
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the invalid method is intended to override the method from the
  // superclass, then change it to conform:
  //
  // ```dart
  // class A {
  //   void m(int i) {}
  // }
  //
  // class B extends A {
  //   void m(int i) {}
  // }
  // ```
  //
  // If it isn't intended to override the method from the superclass, then
  // rename it:
  //
  // ```dart
  // class A {
  //   void m(int i) {}
  // }
  //
  // class B extends A {
  //   void m2(String s) {}
  // }
  // ```
  static const CompileTimeErrorCode INVALID_OVERRIDE = CompileTimeErrorCode(
      'INVALID_OVERRIDE',
      "'{1}.{0}' ('{2}') isn't a valid override of '{3}.{0}' ('{4}').",
      hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when `this` is used outside of an
  // instance method or a generative constructor. The reserved word `this` is
  // only defined in the context of an instance method or a generative
  // constructor.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `v` is a top-level
  // variable:
  //
  // ```dart
  // C f() => [!this!];
  //
  // class C {}
  // ```
  //
  // #### Common fixes
  //
  // Use a variable of the appropriate type in place of `this`, declaring it if
  // necessary:
  //
  // ```dart
  // C f(C c) => c;
  //
  // class C {}
  // ```
  static const CompileTimeErrorCode INVALID_REFERENCE_TO_THIS =
      CompileTimeErrorCode('INVALID_REFERENCE_TO_THIS',
          "Invalid reference to 'this' expression.");

  /**
   * 12.6 Lists: It is a compile time error if the type argument of a constant
   * list literal includes a type parameter.
   *
   * Parameters:
   * 0: the name of the type parameter
   */
  static const CompileTimeErrorCode INVALID_TYPE_ARGUMENT_IN_CONST_LIST =
      CompileTimeErrorCode(
          'INVALID_TYPE_ARGUMENT_IN_CONST_LIST',
          "Constant list literals can't include a type parameter as a type "
              "argument, such as '{0}'.",
          correction:
              "Try replacing the type parameter with a different type.");

  /**
   * 12.7 Maps: It is a compile time error if the type arguments of a constant
   * map literal include a type parameter.
   *
   * Parameters:
   * 0: the name of the type parameter
   */
  static const CompileTimeErrorCode INVALID_TYPE_ARGUMENT_IN_CONST_MAP =
      CompileTimeErrorCode(
          'INVALID_TYPE_ARGUMENT_IN_CONST_MAP',
          "Constant map literals can't include a type parameter as a type "
              "argument, such as '{0}'.",
          correction:
              "Try replacing the type parameter with a different type.");

  static const CompileTimeErrorCode INVALID_TYPE_ARGUMENT_IN_CONST_SET =
      CompileTimeErrorCode(
          'INVALID_TYPE_ARGUMENT_IN_CONST_SET',
          "Constant set literals can't include a type parameter as a type "
              "argument, such as '{0}'.",
          correction:
              "Try replacing the type parameter with a different type.");

  /**
   * The 'covariant' keyword was found in an inappropriate location.
   */
  static const CompileTimeErrorCode INVALID_USE_OF_COVARIANT =
      CompileTimeErrorCode(
          'INVALID_USE_OF_COVARIANT',
          "The 'covariant' keyword can only be used for parameters in instance "
              "methods or before non-final instance fields.",
          correction: "Try removing the 'covariant' keyword.");

  @Deprecated('Use ParserErrorCode.INVALID_USE_OF_COVARIANT_IN_EXTENSION')
  static const ParserErrorCode INVALID_USE_OF_COVARIANT_IN_EXTENSION =
      ParserErrorCode.INVALID_USE_OF_COVARIANT_IN_EXTENSION;

  /**
   * 14.2 Exports: It is a compile-time error if the compilation unit found at
   * the specified URI is not a library declaration.
   *
   * 14.1 Imports: It is a compile-time error if the compilation unit found at
   * the specified URI is not a library declaration.
   *
   * 14.3 Parts: It is a compile time error if the contents of the URI are not a
   * valid part declaration.
   *
   * Parameters:
   * 0: the URI that is invalid
   *
   * See [URI_DOES_NOT_EXIST].
   */
  static const CompileTimeErrorCode INVALID_URI =
      CompileTimeErrorCode('INVALID_URI', "Invalid URI syntax: '{0}'.");

  /**
   * Parameters:
   * 0: the name of the extension
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extension override is used to
  // invoke a function but the extension doesn't declare a `call` method.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the extension `E`
  // doesn't define a `call` method:
  //
  // ```dart
  // extension E on String {}
  //
  // void f() {
  //   [!E('')!]();
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the extension is intended to define a `call` method, then declare it:
  //
  // ```dart
  // extension E on String {
  //   int call() => 0;
  // }
  //
  // void f() {
  //   E('')();
  // }
  // ```
  //
  // If the extended type defines a `call` method, then remove the extension
  // override.
  //
  // If the `call` method isn't defined, then rewrite the code so that it
  // doesn't invoke the `call` method.
  static const CompileTimeErrorCode INVOCATION_OF_EXTENSION_WITHOUT_CALL =
      CompileTimeErrorCode(
          'INVOCATION_OF_EXTENSION_WITHOUT_CALL',
          "The extension '{0}' doesn't define a 'call' method so the override "
              "can't be used in an invocation.",
          hasPublishedDocs: true);

  /**
   * 13.13 Break: It is a compile-time error if no such statement
   * <i>s<sub>E</sub></i> exists within the innermost function in which
   * <i>s<sub>b</sub></i> occurs.
   *
   * 13.14 Continue: It is a compile-time error if no such statement or case
   * clause <i>s<sub>E</sub></i> exists within the innermost function in which
   * <i>s<sub>c</sub></i> occurs.
   *
   * Parameters:
   * 0: the name of the unresolvable label
   */
  static const CompileTimeErrorCode LABEL_IN_OUTER_SCOPE = CompileTimeErrorCode(
      'LABEL_IN_OUTER_SCOPE',
      "Can't reference label '{0}' declared in an outer method.");

  /**
   * 13.13 Break: It is a compile-time error if no such statement
   * <i>s<sub>E</sub></i> exists within the innermost function in which
   * <i>s<sub>b</sub></i> occurs.
   *
   * 13.14 Continue: It is a compile-time error if no such statement or case
   * clause <i>s<sub>E</sub></i> exists within the innermost function in which
   * <i>s<sub>c</sub></i> occurs.
   *
   * Parameters:
   * 0: the name of the unresolvable label
   */
  static const CompileTimeErrorCode LABEL_UNDEFINED = CompileTimeErrorCode(
      'LABEL_UNDEFINED', "Can't reference undefined label '{0}'.",
      correction: "Try defining the label, or "
          "correcting the name to match an existing label.");

  /**
   * nnbd/feature-specification.md
   *
   * It is an error for a class with a `const` constructor to have a
   * `late final` field.
   */
  static const CompileTimeErrorCode LATE_FINAL_FIELD_WITH_CONST_CONSTRUCTOR =
      CompileTimeErrorCode('LATE_FINAL_FIELD_WITH_CONST_CONSTRUCTOR',
          "Can't have a late final field in a class with a const constructor.",
          correction: "Try removing the 'late' modifier, or don't declare "
              "'const' constructors.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a map entry (a key/value pair)
  // is found in a set literal.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the literal has a map
  // entry even though it's a set literal:
  //
  // ```dart
  // const collection = <String>{[!'a' : 'b'!]};
  // ```
  //
  // #### Common fixes
  //
  // If you intended for the collection to be a map, then change the code so
  // that it is a map. In the previous example, you could do this by adding
  // another type argument:
  //
  // ```dart
  // const collection = <String, String>{'a' : 'b'};
  // ```
  //
  // In other cases, you might need to change the explicit type from `Set` to
  // `Map`.
  //
  // If you intended for the collection to be a set, then remove the map entry,
  // possibly by replacing the colon with a comma if both values should be
  // included in the set:
  //
  // ```dart
  // const collection = <String>{'a', 'b'};
  // ```
  static const CompileTimeErrorCode MAP_ENTRY_NOT_IN_MAP = CompileTimeErrorCode(
      'MAP_ENTRY_NOT_IN_MAP', "Map entries can only be used in a map literal.",
      correction: "Try converting the collection to a map or removing the map "
          "entry.",
      hasPublishedDocs: true);

  /**
   * 7 Classes: It is a compile time error if a class <i>C</i> declares a member
   * with the same name as <i>C</i>.
   */
  static const CompileTimeErrorCode MEMBER_WITH_CLASS_NAME =
      CompileTimeErrorCode('MEMBER_WITH_CLASS_NAME',
          "Class members can't have the same name as the enclosing class.");

  /**
   * 12.1 Constants: A constant expression is ... a constant list literal.
   */
  static const CompileTimeErrorCode MISSING_CONST_IN_LIST_LITERAL =
      CompileTimeErrorCode(
          'MISSING_CONST_IN_LIST_LITERAL',
          "List literals must be prefixed with 'const' when used as a constant "
              "expression.",
          correction: "Try adding the keyword 'const' before the literal.");

  /**
   * 12.1 Constants: A constant expression is ... a constant map literal.
   */
  static const CompileTimeErrorCode MISSING_CONST_IN_MAP_LITERAL =
      CompileTimeErrorCode(
          'MISSING_CONST_IN_MAP_LITERAL',
          "Map literals must be prefixed with 'const' when used as a constant "
              "expression.",
          correction: "Try adding the keyword 'const' before the literal.");

  /**
   * 12.1 Constants: A constant expression is ... a constant set literal.
   */
  static const CompileTimeErrorCode MISSING_CONST_IN_SET_LITERAL =
      CompileTimeErrorCode(
          'MISSING_CONST_IN_SET_LITERAL',
          "Set literals must be prefixed with 'const' when used as a constant "
              "expression.",
          correction: "Try adding the keyword 'const' before the literal.");

  static const CompileTimeErrorCode MISSING_DART_LIBRARY = CompileTimeErrorCode(
      'MISSING_DART_LIBRARY', "Required library '{0}' is missing.",
      correction: "Check your Dart SDK installation for completeness.");

  /**
   * No parameters.
   */
  /* #### Description
  //
  // The analyzer produces this diagnostic when an optional parameter doesn't
  // have a default value, but has a
  // <a href=”#potentially-non-nullable”>potentially non-nullable</a> type.
  // Optional parameters that have no explicit default value have an implicit
  // default value of `null`. If the type of the parameter doesn't allow the
  // parameter to have a value of null, then the implicit default value is not
  // valid.
  //
  // #### Example
  //
  // The following code generates this diagnostic:
  //
  // ```dart
  // void log({String [!message!]}) {}
  // ```
  //
  // #### Common fixes
  //
  // If the parameter can have the value `null`, then add a question mark after
  // the type annotation:
  //
  // ```dart
  // void log({String? message}) {}
  // ```
  //
  // If the parameter can't be null, then either provide a default value:
  //
  // ```dart
  // void log({String message = ''}) {}
  // ```
  //
  // or add the `required` modifier to the parameter:
  //
  // ```dart
  // void log({required String message}) {}
  // ``` */
  static const CompileTimeErrorCode MISSING_DEFAULT_VALUE_FOR_PARAMETER =
      CompileTimeErrorCode(
          'MISSING_DEFAULT_VALUE_FOR_PARAMETER',
          "The parameter '{0}' can't have a value of 'null' because of its "
              "type, so it must either be a required parameter or have a "
              "default value.",
          correction:
              "Try adding either a default value or the 'required' modifier.");

  /**
   * It is an error if a named parameter that is marked as being required is
   * not bound to an argument at a call site.
   *
   * Parameters:
   * 0: the name of the parameter
   */
  static const CompileTimeErrorCode MISSING_REQUIRED_ARGUMENT =
      CompileTimeErrorCode('MISSING_REQUIRED_ARGUMENT',
          "The named parameter '{0}' is required but was not provided.",
          correction: "Try adding the required argument.");

  /**
   * It's a compile-time error to apply a mixin containing super-invocations to
   * a class that doesn't have a concrete implementation of the super-invoked
   * members compatible with the super-constraint interface.
   *
   * This ensures that if more than one super-constraint interface declares a
   * member with the same name, at least one of those members is more specific
   * than the rest, and this is the unique signature that super-invocations
   * are allowed to invoke.
   *
   * Parameters:
   * 0: the name of the super-invoked member
   * 1: the display name of the type of the super-invoked member in the mixin
   * 2: the display name of the type of the concrete member in the class
   */
  static const CompileTimeErrorCode
      MIXIN_APPLICATION_CONCRETE_SUPER_INVOKED_MEMBER_TYPE =
      CompileTimeErrorCode(
          'MIXIN_APPLICATION_CONCRETE_SUPER_INVOKED_MEMBER_TYPE',
          "The super-invoked member '{0}' has the type '{1}', but the "
              "concrete member in the class has type '{2}'.");

  /**
   * It's a compile-time error to apply a mixin to a class that doesn't
   * implement all the `on` type requirements of the mixin declaration.
   *
   * Parameters:
   * 0: the display name of the mixin
   * 1: the display name of the superclass
   * 2: the display name of the type that is not implemented
   */
  static const CompileTimeErrorCode
      MIXIN_APPLICATION_NOT_IMPLEMENTED_INTERFACE = CompileTimeErrorCode(
          'MIXIN_APPLICATION_NOT_IMPLEMENTED_INTERFACE',
          "'{0}' can't be mixed onto '{1}' because '{1}' doesn't implement "
              "'{2}'.",
          correction: "Try extending the class '{0}'.");

  /**
   * It's a compile-time error to apply a mixin containing super-invocations to
   * a class that doesn't have a concrete implementation of the super-invoked
   * members compatible with the super-constraint interface.
   *
   * Parameters:
   * 0: the display name of the member without a concrete implementation
   */
  static const CompileTimeErrorCode
      MIXIN_APPLICATION_NO_CONCRETE_SUPER_INVOKED_MEMBER = CompileTimeErrorCode(
          'MIXIN_APPLICATION_NO_CONCRETE_SUPER_INVOKED_MEMBER',
          "The class doesn't have a concrete implementation of the "
              "super-invoked member '{0}'.");

  /**
   * 9 Mixins: It is a compile-time error if a declared or derived mixin
   * explicitly declares a constructor.
   *
   * Parameters:
   * 0: the name of the mixin that is invalid
   */
  static const CompileTimeErrorCode MIXIN_CLASS_DECLARES_CONSTRUCTOR =
      CompileTimeErrorCode(
          'MIXIN_CLASS_DECLARES_CONSTRUCTOR',
          "The class '{0}' can't be used as a mixin because it declares a "
              "constructor.");

  /**
   * The <i>mixinMember</i> production allows the same instance or static
   * members that a class would allow, but no constructors (for now).
   */
  static const CompileTimeErrorCode MIXIN_DECLARES_CONSTRUCTOR =
      CompileTimeErrorCode(
          'MIXIN_DECLARES_CONSTRUCTOR', "Mixins can't declare constructors.");

  /**
   * 9.1 Mixin Application: It is a compile-time error if the with clause of a
   * mixin application <i>C</i> includes a deferred type expression.
   *
   * Parameters:
   * 0: the name of the type that cannot be extended
   *
   * See [EXTENDS_DEFERRED_CLASS], and [IMPLEMENTS_DEFERRED_CLASS].
   */
  static const CompileTimeErrorCode MIXIN_DEFERRED_CLASS = CompileTimeErrorCode(
      'MIXIN_DEFERRED_CLASS', "Classes can't mixin deferred classes.",
      correction: "Try changing the import to not be deferred.");

  static const CompileTimeErrorCode
      MIXIN_INFERENCE_INCONSISTENT_MATCHING_CLASSES = CompileTimeErrorCode(
          'MIXIN_INFERENCE_INCONSISTENT_MATCHING_CLASSES',
          "Type parameters couldn't be inferred for the mixin '{0}' because "
              "the base class implements the mixin's supertype constraint "
              "'{1}' in multiple conflicting ways");

  static const CompileTimeErrorCode MIXIN_INFERENCE_NO_MATCHING_CLASS =
      CompileTimeErrorCode(
          'MIXIN_INFERENCE_NO_MATCHING_CLASS',
          "Type parameters couldn't be inferred for the mixin '{0}' because "
              "the base class doesn't implement the mixin's supertype "
              "constraint '{1}'");

  static const CompileTimeErrorCode MIXIN_INFERENCE_NO_POSSIBLE_SUBSTITUTION =
      CompileTimeErrorCode(
          'MIXIN_INFERENCE_NO_POSSIBLE_SUBSTITUTION',
          "Type parameters couldn't be inferred for the mixin '{0}' because "
              "no type parameter substitution could be found matching the "
              "mixin's supertype constraints");

  /**
   * 9 Mixins: It is a compile-time error if a mixin is derived from a class
   * whose superclass is not Object.
   *
   * Parameters:
   * 0: the name of the mixin that is invalid
   */
  static const CompileTimeErrorCode MIXIN_INHERITS_FROM_NOT_OBJECT =
      CompileTimeErrorCode(
          'MIXIN_INHERITS_FROM_NOT_OBJECT',
          "The class '{0}' can't be used as a mixin because it extends a class "
              "other than Object.");

  /**
   * A mixin declaration introduces a mixin and an interface, but not a class.
   */
  static const CompileTimeErrorCode MIXIN_INSTANTIATE = CompileTimeErrorCode(
      'MIXIN_INSTANTIATE', "Mixins can't be instantiated.");

  /**
   * 12.2 Null: It is a compile-time error for a class to attempt to extend or
   * implement Null.
   *
   * 12.3 Numbers: It is a compile-time error for a class to attempt to extend
   * or implement int.
   *
   * 12.3 Numbers: It is a compile-time error for a class to attempt to extend
   * or implement double.
   *
   * 12.3 Numbers: It is a compile-time error for any type other than the types
   * int and double to attempt to extend or implement num.
   *
   * 12.4 Booleans: It is a compile-time error for a class to attempt to extend
   * or implement bool.
   *
   * 12.5 Strings: It is a compile-time error for a class to attempt to extend
   * or implement String.
   *
   * Parameters:
   * 0: the name of the type that cannot be extended
   *
   * See [IMPLEMENTS_DISALLOWED_CLASS].
   */
  static const CompileTimeErrorCode MIXIN_OF_DISALLOWED_CLASS =
      CompileTimeErrorCode(
          'MIXIN_OF_DISALLOWED_CLASS', "Classes can't mixin '{0}'.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a name in a mixin clause is
  // defined to be something other than a mixin or a class.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `F` is defined to be a
  // function type:
  //
  // ```dart
  // typedef F = int Function(String);
  //
  // class C with [!F!] {}
  // ```
  //
  // #### Common fixes
  //
  // Remove the invalid name from the list, possibly replacing it with the name of the intended mixin or class:
  //
  // ```dart
  // typedef F = int Function(String);
  //
  // class C {}
  // ```
  static const CompileTimeErrorCode MIXIN_OF_NON_CLASS = CompileTimeErrorCode(
      'MIXIN_OF_NON_CLASS', "Classes can only mix in mixins and classes.");

  /**
   * 9 Mixins: It is a compile-time error if a declared or derived mixin refers
   * to super.
   */
  static const CompileTimeErrorCode MIXIN_REFERENCES_SUPER =
      CompileTimeErrorCode(
          'MIXIN_REFERENCES_SUPER',
          "The class '{0}' can't be used as a mixin because it references "
              "'super'.");

  static const CompileTimeErrorCode
      MIXIN_SUPER_CLASS_CONSTRAINT_DEFERRED_CLASS = CompileTimeErrorCode(
          'MIXIN_SUPER_CLASS_CONSTRAINT_DEFERRED_CLASS',
          "Deferred classes can't be used as super-class constraints.",
          correction: "Try changing the import to not be deferred.");

  static const CompileTimeErrorCode
      MIXIN_SUPER_CLASS_CONSTRAINT_DISALLOWED_CLASS = CompileTimeErrorCode(
          'MIXIN_SUPER_CLASS_CONSTRAINT_DISALLOWED_CLASS',
          "'{0}' can't be used as a super-class constraint.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a type following the `on`
  // keyword in a mixin declaration is neither a class nor a mixin.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `F` is neither a class
  // nor a mixin:
  //
  // ```dart
  // typedef F = void Function();
  //
  // mixin M on [!F!] {}
  // ```
  //
  // #### Common fixes
  //
  // If the type was intended to be a class but was mistyped, then replace the
  // name.
  //
  // Otherwise, remove the type from the on clause.
  static const CompileTimeErrorCode MIXIN_SUPER_CLASS_CONSTRAINT_NON_INTERFACE =
      CompileTimeErrorCode('MIXIN_SUPER_CLASS_CONSTRAINT_NON_INTERFACE',
          "Only classes and mixins can be used as superclass constraints.",
          hasPublishedDocs: true);

  /**
   * 9.1 Mixin Application: It is a compile-time error if <i>S</i> does not
   * denote a class available in the immediately enclosing scope.
   */
  static const CompileTimeErrorCode MIXIN_WITH_NON_CLASS_SUPERCLASS =
      CompileTimeErrorCode('MIXIN_WITH_NON_CLASS_SUPERCLASS',
          "Mixin can only be applied to class.");

  /**
   * 7.6.1 Generative Constructors: A generative constructor may be redirecting,
   * in which case its only action is to invoke another generative constructor.
   */
  static const CompileTimeErrorCode
      MULTIPLE_REDIRECTING_CONSTRUCTOR_INVOCATIONS = CompileTimeErrorCode(
          'MULTIPLE_REDIRECTING_CONSTRUCTOR_INVOCATIONS',
          "Constructors can have at most one 'this' redirection.",
          correction: "Try removing all but one of the redirections.");

  /**
   * 7.6.1 Generative Constructors: Let <i>k</i> be a generative constructor.
   * Then <i>k</i> may include at most one superinitializer in its initializer
   * list or a compile time error occurs.
   */
  static const CompileTimeErrorCode MULTIPLE_SUPER_INITIALIZERS =
      CompileTimeErrorCode('MULTIPLE_SUPER_INITIALIZERS',
          "Constructor may have at most one 'super' initializer.",
          correction: "Try removing all but one of the 'super' initializers.");

  /**
   * 15 Metadata: Metadata consists of a series of annotations, each of which
   * begin with the character @, followed by a constant expression that must be
   * either a reference to a compile-time constant variable, or a call to a
   * constant constructor.
   */
  static const CompileTimeErrorCode NO_ANNOTATION_CONSTRUCTOR_ARGUMENTS =
      CompileTimeErrorCode('NO_ANNOTATION_CONSTRUCTOR_ARGUMENTS',
          "Annotation creation must have arguments.",
          correction: "Try adding an empty argument list.");

  /**
   * Parameters:
   * 0: the name of the superclass that does not define an implicitly invoked
   *    constructor
   */
  static const CompileTimeErrorCode NO_DEFAULT_SUPER_CONSTRUCTOR_EXPLICIT =
      CompileTimeErrorCodeWithUniqueName(
          'NO_DEFAULT_SUPER_CONSTRUCTOR',
          'NO_DEFAULT_SUPER_CONSTRUCTOR_EXPLICIT',
          "The superclass '{0}' doesn't have a zero argument constructor.",
          correction: "Try declaring a zero argument constructor in '{0}', or "
              "explicitly invoking a different constructor in '{0}'.");

  /**
   * Parameters:
   * 0: the name of the superclass that does not define an implicitly invoked
   *    constructor
   * 1: the name of the subclass that does not contain any explicit constructors
   */
  static const CompileTimeErrorCode NO_DEFAULT_SUPER_CONSTRUCTOR_IMPLICIT =
      CompileTimeErrorCodeWithUniqueName(
          'NO_DEFAULT_SUPER_CONSTRUCTOR',
          'NO_DEFAULT_SUPER_CONSTRUCTOR_IMPLICIT',
          "The superclass '{0}' doesn't have a zero argument constructor.",
          correction: "Try declaring a zero argument constructor in '{0}', or "
              "declaring a constructor in {1} that explicitly invokes a "
              "constructor in '{0}'.");

  /**
   * 13.2 Expression Statements: It is a compile-time error if a non-constant
   * map literal that has no explicit type arguments appears in a place where a
   * statement is expected.
   */
  static const CompileTimeErrorCode NON_CONST_MAP_AS_EXPRESSION_STATEMENT =
      CompileTimeErrorCode(
          'NON_CONST_MAP_AS_EXPRESSION_STATEMENT',
          "A non-constant map or set literal without type arguments can't be "
              "used as an expression statement.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the expression in a case clause
  // isn't a constant expression.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `j` isn't a constant:
  //
  // ```dart
  // void f(int i, int j) {
  //   switch (i) {
  //     case [!j!]:
  //       // ...
  //       break;
  //   }
  // }
  // ```
  //
  // #### Common fixes
  //
  // Either make the expression a constant expression, or rewrite the switch
  // statement as a sequence of if statements:
  //
  // ```dart
  // void f(int i, int j) {
  //   if (i == j) {
  //     // ...
  //   }
  // }
  // ```
  static const CompileTimeErrorCode NON_CONSTANT_CASE_EXPRESSION =
      CompileTimeErrorCode(
          'NON_CONSTANT_CASE_EXPRESSION', "Case expressions must be constant.",
          hasPublishedDocs: true);

  /**
   * 13.9 Switch: Given a switch statement of the form <i>switch (e) {
   * label<sub>11</sub> &hellip; label<sub>1j1</sub> case e<sub>1</sub>:
   * s<sub>1</sub> &hellip; label<sub>n1</sub> &hellip; label<sub>njn</sub> case
   * e<sub>n</sub>: s<sub>n</sub> default: s<sub>n+1</sub>}</i> or the form
   * <i>switch (e) { label<sub>11</sub> &hellip; label<sub>1j1</sub> case
   * e<sub>1</sub>: s<sub>1</sub> &hellip; label<sub>n1</sub> &hellip;
   * label<sub>njn</sub> case e<sub>n</sub>: s<sub>n</sub>}</i>, it is a
   * compile-time error if the expressions <i>e<sub>k</sub></i> are not
   * compile-time constants, for all <i>1 &lt;= k &lt;= n</i>.
   *
   * 12.1 Constants: A qualified reference to a static constant variable that is
   * not qualified by a deferred prefix.
   */
  static const CompileTimeErrorCode
      NON_CONSTANT_CASE_EXPRESSION_FROM_DEFERRED_LIBRARY = CompileTimeErrorCode(
          'NON_CONSTANT_CASE_EXPRESSION_FROM_DEFERRED_LIBRARY',
          "Constant values from a deferred library can't be used as a case "
              "expression.",
          correction:
              "Try re-writing the switch as a series of if statements, or "
              "changing the import to not be deferred.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an optional parameter, either
  // named or positional, has a default value that isn't a compile-time
  // constant.
  //
  // #### Example
  //
  // The following code produces this diagnostic:
  //
  // ```dart
  // var defaultValue = 3;
  //
  // void f([int value = [!defaultValue!]]) {}
  // ```
  //
  // #### Common fixes
  //
  // If the default value can be converted to be a constant, then convert it:
  //
  // ```dart
  // const defaultValue = 3;
  //
  // void f([int value = defaultValue]) {}
  // ```
  //
  // If the default value needs to change over time, then apply the default
  // value inside the function:
  //
  // ```dart
  // var defaultValue = 3;
  //
  // void f([int value]) {
  //   value ??= defaultValue;
  // }
  // ```
  static const CompileTimeErrorCode NON_CONSTANT_DEFAULT_VALUE =
      CompileTimeErrorCode('NON_CONSTANT_DEFAULT_VALUE',
          "The default value of an optional parameter must be constant.",
          hasPublishedDocs: true);

  /**
   * 6.2.2 Optional Formals: It is a compile-time error if the default value of
   * an optional parameter is not a compile-time constant.
   *
   * 12.1 Constants: A qualified reference to a static constant variable that is
   * not qualified by a deferred prefix.
   */
  static const CompileTimeErrorCode
      NON_CONSTANT_DEFAULT_VALUE_FROM_DEFERRED_LIBRARY = CompileTimeErrorCode(
          'NON_CONSTANT_DEFAULT_VALUE_FROM_DEFERRED_LIBRARY',
          "Constant values from a deferred library can't be used as a default "
              "parameter value.",
          correction:
              "Try leaving the default as null and initializing the parameter "
              "inside the function body.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an element in a constant list
  // literal isn't a constant value. The list literal can be constant either
  // explicitly (because it's prefixed by the `const` keyword) or implicitly
  // (because it appears in a [constant context](#constant-context)).
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` isn't a constant,
  // even though it appears in an implicitly constant list literal:
  //
  // ```dart
  // var x = 2;
  // var y = const <int>[0, 1, [!x!]];
  // ```
  //
  // #### Common fixes
  //
  // If the list needs to be a constant list, then convert the element to be a
  // constant. In the example above, you might add the `const` keyword to the
  // declaration of `x`:
  //
  // ```dart
  // const x = 2;
  // var y = const <int>[0, 1, x];
  // ```
  //
  // If the expression can't be made a constant, then the list can't be a
  // constant either, so you must change the code so that the list isn't a
  // constant. In the example above this means removing the `const` keyword
  // before the list literal:
  //
  // ```dart
  // var x = 2;
  // var y = <int>[0, 1, x];
  // ```
  static const CompileTimeErrorCode NON_CONSTANT_LIST_ELEMENT =
      CompileTimeErrorCode('NON_CONSTANT_LIST_ELEMENT',
          "The values in a const list literal must be constants.",
          correction: "Try removing the keyword 'const' from the list literal.",
          hasPublishedDocs: true);

  /**
   * 12.6 Lists: It is a compile time error if an element of a constant list
   * literal is not a compile-time constant.
   *
   * 12.1 Constants: A qualified reference to a static constant variable that is
   * not qualified by a deferred prefix.
   */
  static const CompileTimeErrorCode
      NON_CONSTANT_LIST_ELEMENT_FROM_DEFERRED_LIBRARY = CompileTimeErrorCode(
          'NON_CONSTANT_LIST_ELEMENT_FROM_DEFERRED_LIBRARY',
          "Constant values from a deferred library can't be used as values in "
              "a 'const' list.",
          correction:
              "Try removing the keyword 'const' from the list literal.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a key in a constant map literal
  // isn't a constant value.
  //
  // #### Example
  //
  // The following code produces this diagnostic beause `a` isn't a constant:
  //
  // ```dart
  // var a = 'a';
  // var m = const {[!a!]: 0};
  // ```
  //
  // #### Common fixes
  //
  // If the map needs to be a constant map, then make the key a constant:
  //
  // ```dart
  // const a = 'a';
  // var m = const {a: 0};
  // ```
  //
  // If the map doesn't need to be a constant map, then remove the `const`
  // keyword:
  //
  // ```dart
  // var a = 'a';
  // var m = {a: 0};
  // ```
  static const CompileTimeErrorCode NON_CONSTANT_MAP_KEY = CompileTimeErrorCode(
      'NON_CONSTANT_MAP_KEY',
      "The keys in a const map literal must be constant.",
      correction: "Try removing the keyword 'const' from the map literal.",
      hasPublishedDocs: true);

  /**
   * 12.7 Maps: It is a compile time error if either a key or a value of an
   * entry in a constant map literal is not a compile-time constant.
   *
   * 12.1 Constants: A qualified reference to a static constant variable that is
   * not qualified by a deferred prefix.
   */
  static const CompileTimeErrorCode NON_CONSTANT_MAP_KEY_FROM_DEFERRED_LIBRARY =
      CompileTimeErrorCode(
          'NON_CONSTANT_MAP_KEY_FROM_DEFERRED_LIBRARY',
          "Constant values from a deferred library can't be used as keys in a "
              "const map literal.",
          correction: "Try removing the keyword 'const' from the map literal.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a value in a constant map
  // literal isn't a constant value.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `a` isn't a constant:
  //
  // ```dart
  // var a = 'a';
  // var m = const {0: [!a!]};
  // ```
  //
  // #### Common fixes
  //
  // If the map needs to be a constant map, then make the key a constant:
  //
  // ```dart
  // const a = 'a';
  // var m = const {0: a};
  // ```
  //
  // If the map doesn't need to be a constant map, then remove the `const`
  // keyword:
  //
  // ```dart
  // var a = 'a';
  // var m = {0: a};
  // ```
  static const CompileTimeErrorCode NON_CONSTANT_MAP_VALUE =
      CompileTimeErrorCode('NON_CONSTANT_MAP_VALUE',
          "The values in a const map literal must be constant.",
          correction: "Try removing the keyword 'const' from the map literal.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an if element or a spread
  // element in a constant map isn't a constant element.
  //
  // #### Example
  //
  // The following code produces this diagnostic because it is attempting to
  // spread a non-constant map:
  //
  // ```dart
  // var notConst = <int, int>{};
  // var map = const <int, int>{...[!notConst!]};
  // ```
  //
  // Similarly, the following code produces this diagnostic because the
  // condition in the if element isn't a constant expression:
  //
  // ```dart
  // bool notConst = true;
  // var map = const <int, int>{if ([!notConst!]) 1 : 2};
  // ```
  //
  // #### Common fixes
  //
  // If the map needs to be a constant map, then make the elements  constants.
  // In the spread example, you might do that by making the collection being
  // spread a constant:
  //
  // ```dart
  // const notConst = <int, int>{};
  // var map = const <int, int>{...notConst};
  // ```
  //
  // If the map doesn't need to be a constant map, then remove the `const`
  // keyword:
  //
  // ```dart
  // bool notConst = true;
  // var map = <int, int>{if (notConst) 1 : 2};
  // ```
  static const CompileTimeErrorCode NON_CONSTANT_MAP_ELEMENT =
      CompileTimeErrorCode('NON_CONSTANT_MAP_ELEMENT',
          "The elements in a const map literal must be constant.",
          correction: "Try removing the keyword 'const' from the map literal.",
          hasPublishedDocs: true);

  /**
   * 12.7 Maps: It is a compile time error if either a key or a value of an
   * entry in a constant map literal is not a compile-time constant.
   *
   * 12.1 Constants: A qualified reference to a static constant variable that is
   * not qualified by a deferred prefix.
   */
  static const CompileTimeErrorCode
      NON_CONSTANT_MAP_VALUE_FROM_DEFERRED_LIBRARY = CompileTimeErrorCode(
          'NON_CONSTANT_MAP_VALUE_FROM_DEFERRED_LIBRARY',
          "Constant values from a deferred library can't be used as values in "
              "a const map literal.",
          correction: "Try removing the keyword 'const' from the map literal.");

  /**
   * 15 Metadata: Metadata consists of a series of annotations, each of which
   * begin with the character @, followed by a constant expression that must be
   * either a reference to a compile-time constant variable, or a call to a
   * constant constructor.
   *
   * "From deferred library" case is covered by
   * [CompileTimeErrorCode.INVALID_ANNOTATION_FROM_DEFERRED_LIBRARY].
   */
  static const CompileTimeErrorCode NON_CONSTANT_ANNOTATION_CONSTRUCTOR =
      CompileTimeErrorCode('NON_CONSTANT_ANNOTATION_CONSTRUCTOR',
          "Annotation creation can only call a const constructor.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a constant set literal contains
  // an element that isn't a compile-time constant.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `i` isn't a constant:
  //
  // ```dart
  // var i = 0;
  //
  // var s = const {[!i!]};
  // ```
  //
  // #### Common fixes
  //
  // If the element can be changed to be a constant, then change it:
  //
  // ```dart
  // const i = 0;
  //
  // var s = const {i};
  // ```
  //
  // If the element can't be a constant, then remove the keyword `const`:
  //
  // ```dart
  // var i = 0;
  //
  // var s = {i};
  // ```
  static const CompileTimeErrorCode NON_CONSTANT_SET_ELEMENT =
      CompileTimeErrorCode('NON_CONSTANT_SET_ELEMENT',
          "The values in a const set literal must be constants.",
          correction: "Try removing the keyword 'const' from the set literal.");

  /**
   * This error code is no longer being generated. It should be removed when the
   * reference to it in the linter has been removed and rolled into the SDK.
   */
  @deprecated
  static const CompileTimeErrorCode NON_CONSTANT_VALUE_IN_INITIALIZER =
      CompileTimeErrorCode(
          'NON_CONSTANT_VALUE_IN_INITIALIZER',
          "Initializer expressions in constant constructors must be "
              "constants.");

  /**
   * 7.6.1 Generative Constructors: Let <i>C</i> be the class in which the
   * superinitializer appears and let <i>S</i> be the superclass of <i>C</i>.
   * Let <i>k</i> be a generative constructor. It is a compile-time error if
   * class <i>S</i> does not declare a generative constructor named <i>S</i>
   * (respectively <i>S.id</i>)
   */
  static const CompileTimeErrorCode NON_GENERATIVE_CONSTRUCTOR =
      CompileTimeErrorCode('NON_GENERATIVE_CONSTRUCTOR',
          "The generative constructor '{0}' expected, but factory found.",
          correction:
              "Try calling a different constructor in the superclass, or "
              "making the called constructor not be a factory constructor.");

  static const CompileTimeErrorCode NON_SYNC_FACTORY = CompileTimeErrorCode(
      'NON_SYNC_FACTORY',
      "Factory bodies can't use 'async', 'async*', or 'sync*'.");

  /**
   * It is an error if a potentially non-nullable local variable which has no
   * initializer expression and is not marked `late` is used before it is
   * definitely assigned.
   *
   * Parameters:
   * 0: the name of the variable that is invalid
   */
  static const CompileTimeErrorCode
      NOT_ASSIGNED_POTENTIALLY_NON_NULLABLE_LOCAL_VARIABLE =
      CompileTimeErrorCode(
          'NOT_ASSIGNED_POTENTIALLY_NON_NULLABLE_LOCAL_VARIABLE',
          "The non-nullable local variable '{0}' must be assigned before it "
              "can be used.",
          correction: "Try giving it an initializer expression, "
              "or ensure that it is assigned on every execution path, "
              "or mark it 'late'.");

  /**
   * Parameters:
   * 0: the expected number of required arguments
   * 1: the actual number of positional arguments given
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a method or function invocation
  // has fewer positional arguments than the number of required positional
  // parameters.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `f` declares two
  // required parameters, but only one argument is provided:
  //
  // ```dart
  // void f(int a, int b) {}
  // void g() {
  //   f[!(0)!];
  // }
  // ```
  //
  // #### Common fixes
  //
  // Add arguments corresponding to the remaining parameters:
  //
  // ```dart
  // void f(int a, int b) {}
  // void g() {
  //   f(0, 1);
  // }
  // ```
  static const CompileTimeErrorCode NOT_ENOUGH_POSITIONAL_ARGUMENTS =
      CompileTimeErrorCode('NOT_ENOUGH_POSITIONAL_ARGUMENTS',
          "{0} positional argument(s) expected, but {1} found.",
          correction: "Try adding the missing arguments.",
          hasPublishedDocs: true);

  @Deprecated('Use CompileTimeErrorCode.NOT_ENOUGH_POSITIONAL_ARGUMENTS')
  static const CompileTimeErrorCode NOT_ENOUGH_REQUIRED_ARGUMENTS =
      NOT_ENOUGH_POSITIONAL_ARGUMENTS;

  /**
   * It is an error if an instance field with potentially non-nullable type has
   * no initializer expression and is not initialized in a constructor via an
   * initializing formal or an initializer list entry, unless the field is
   * marked with the `late` modifier.
   *
   * Parameters:
   * 0: the name of the field that is not initialized
   */
  static const CompileTimeErrorCode
      NOT_INITIALIZED_NON_NULLABLE_INSTANCE_FIELD = CompileTimeErrorCode(
          'NOT_INITIALIZED_NON_NULLABLE_INSTANCE_FIELD',
          "Non-nullable instance field '{0}' must be initialized.",
          correction: "Try adding an initializer expression, "
              "or a generative constructor that initializes it, "
              "or mark it 'late'.");

  /**
   * It is an error if an instance field with potentially non-nullable type has
   * no initializer expression and is not initialized in a constructor via an
   * initializing formal or an initializer list entry, unless the field is
   * marked with the `late` modifier.
   *
   * Parameters:
   *
   * Parameters:
   * 0: the name of the field that is not initialized
   */
  static const CompileTimeErrorCode
      NOT_INITIALIZED_NON_NULLABLE_INSTANCE_FIELD_CONSTRUCTOR =
      CompileTimeErrorCode(
          'NOT_INITIALIZED_NON_NULLABLE_INSTANCE_FIELD_CONSTRUCTOR',
          "Non-nullable instance field '{0}' must be initialized.",
          correction: "Try adding an initializer expression, "
              "or add a field initializer in this constructor, "
              "or mark it 'late'.");

  /**
   * It is an error if a static field or top-level variable with potentially
   * non-nullable type has no initializer expression.
   *
   * Parameters:
   * 0: the name of the variable that is invalid
   */
  static const CompileTimeErrorCode NOT_INITIALIZED_NON_NULLABLE_VARIABLE =
      CompileTimeErrorCode('NOT_INITIALIZED_NON_NULLABLE_VARIABLE',
          "The non-nullable variable '{0}' must be initialized.",
          correction: "Try adding an initializer expression.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the static type of the
  // expression of a spread element that appears in either a list literal or a
  // set literal doesn't implement the type `Iterable`.
  //
  // #### Example
  //
  // The following code generates this diagnostic:
  //
  // ```dart
  // var m = <String, int>{'a': 0, 'b': 1};
  // var s = <String>{...[!m!]};
  // ```
  //
  // #### Common fixes
  //
  // The most common fix is to replace the expression with one that produces an
  // iterable object:
  //
  // ```dart
  // var m = <String, int>{'a': 0, 'b': 1};
  // var s = <String>{...m.keys};
  // ```
  static const CompileTimeErrorCode NOT_ITERABLE_SPREAD = CompileTimeErrorCode(
      'NOT_ITERABLE_SPREAD',
      "Spread elements in list or set literals must implement 'Iterable'.",
      hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the static type of the
  // expression of a spread element that appears in a map literal doesn't
  // implement the type `Map`.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `l` isn't a `Map`:
  //
  // ```dart
  // var l =  <String>['a', 'b'];
  // var m = <int, String>{...[!l!]};
  // ```
  //
  // #### Common fixes
  //
  // The most common fix is to replace the expression with one that produces a
  // map:
  //
  // ```dart
  // var l =  <String>['a', 'b'];
  // var m = <int, String>{...l.asMap()};
  // ```
  static const CompileTimeErrorCode NOT_MAP_SPREAD = CompileTimeErrorCode(
      'NOT_MAP_SPREAD', "Spread elements in map literals must implement 'Map'.",
      hasPublishedDocs: true);

  static const CompileTimeErrorCode NOT_NULL_AWARE_NULL_SPREAD =
      CompileTimeErrorCode(
          'NOT_NULL_AWARE_NULL_SPREAD',
          "The Null typed expression can't be used with a non-null-aware "
              "spread.");

  /**
   * It is an error if the type `T` in the on-catch clause `on T catch` is
   * potentially nullable.
   */
  static const CompileTimeErrorCode NULLABLE_TYPE_IN_CATCH_CLAUSE =
      CompileTimeErrorCode(
          'NULLABLE_TYPE_IN_CATCH_CLAUSE',
          "A nullable type can't be used in an 'on' clause because it isn't "
              "valid to throw 'null'.",
          correction: "Try removing the question mark.");

  /**
   * No parameters.
   */
  /* #### Description
  //
  // The analyzer produces this diagnostic when a class declaration uses an
  // extends clause to specify a superclass, and the type that's specified is a
  // nullable type.
  //
  // The reason the supertype is a _type_ rather than a class name is to allow
  // you to control the signatures of the members to be inherited from the
  // supertype, such as by specifying type arguments. However, the nullability
  // of a type doesn't change the signatures of any members, so there isn't any
  // reason to allow the nullability to be specified when used in the extends
  // clause.
  //
  // #### Example
  //
  // The following code generates this diagnostic:
  //
  // ```dart
  // class Invalid extends [!Duration?!] {}
  // ```
  //
  // #### Common fixes
  //
  // The most common fix is to remove the question mark:
  //
  // ```dart
  // class Invalid extends Duration {}
  // ``` */
  static const CompileTimeErrorCode NULLABLE_TYPE_IN_EXTENDS_CLAUSE =
      CompileTimeErrorCode('NULLABLE_TYPE_IN_EXTENDS_CLAUSE',
          "A class can't extend a nullable type.",
          correction: "Try removing the question mark.");

  /**
   * It is a compile-time error for a class to extend, implement, or mixin a
   * type of the form T? for any T.
   */
  static const CompileTimeErrorCode NULLABLE_TYPE_IN_IMPLEMENTS_CLAUSE =
      CompileTimeErrorCode('NULLABLE_TYPE_IN_IMPLEMENTS_CLAUSE',
          "A class or mixin can't implement a nullable type.",
          correction: "Try removing the question mark.");

  /**
   * It is a compile-time error for a class to extend, implement, or mixin a
   * type of the form T? for any T.
   */
  static const CompileTimeErrorCode NULLABLE_TYPE_IN_ON_CLAUSE =
      CompileTimeErrorCode('NULLABLE_TYPE_IN_ON_CLAUSE',
          "A mixin can't have a nullable type as a superclass constraint.",
          correction: "Try removing the question mark.");

  /**
   * It is a compile-time error for a class to extend, implement, or mixin a
   * type of the form T? for any T.
   */
  static const CompileTimeErrorCode NULLABLE_TYPE_IN_WITH_CLAUSE =
      CompileTimeErrorCode('NULLABLE_TYPE_IN_WITH_CLAUSE',
          "A class or mixin can't mix in a nullable type.",
          correction: "Try removing the question mark.");

  /**
   * 7.9 Superclasses: It is a compile-time error to specify an extends clause
   * for class Object.
   */
  static const CompileTimeErrorCode OBJECT_CANNOT_EXTEND_ANOTHER_CLASS =
      CompileTimeErrorCode('OBJECT_CANNOT_EXTEND_ANOTHER_CLASS',
          "The class 'Object' can't extend any other class.");

  /**
   * 10.10 Superinterfaces: It is a compile-time error if two elements in the
   * type list of the implements clause of a class `C` specifies the same
   * type `T`.
   *
   * Parameters:
   * 0: the name of the interface that is implemented more than once
   */
  static const CompileTimeErrorCode ON_REPEATED = CompileTimeErrorCode(
      'ON_REPEATED',
      "'{0}' can only be used in super-class constraints only once.",
      correction: "Try removing all but one occurrence of the class name.");

  /**
   * 7.1.1 Operators: It is a compile-time error to declare an optional
   * parameter in an operator.
   */
  static const CompileTimeErrorCode OPTIONAL_PARAMETER_IN_OPERATOR =
      CompileTimeErrorCode('OPTIONAL_PARAMETER_IN_OPERATOR',
          "Optional parameters aren't allowed when defining an operator.",
          correction: "Try removing the optional parameters.");

  /**
   * Parameters:
   * 0: the uri pointing to a non-library declaration
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a part directive is found and
  // the referenced file doesn't have a part-of directive.
  //
  // #### Example
  //
  // Given a file (`a.dart`) containing:
  //
  // ```dart
  // %uri="lib/a.dart"
  // class A {}
  // ```
  //
  // The following code produces this diagnostic because `a.dart` doesn't
  // contain a part-of directive:
  //
  // ```dart
  // part [!'a.dart'!];
  // ```
  //
  // #### Common fixes
  //
  // If the referenced file is intended to be a part of another library, then
  // add a part-of directive to the file:
  //
  // ```dart
  // part of 'test.dart';
  //
  // class A {}
  // ```
  //
  // If the referenced file is intended to be a library, then replace the part
  // directive with an import directive:
  //
  // ```dart
  // import 'a.dart';
  // ```
  static const CompileTimeErrorCode PART_OF_NON_PART = CompileTimeErrorCode(
      'PART_OF_NON_PART',
      "The included part '{0}' must have a part-of directive.",
      correction: "Try adding a part-of directive to '{0}'.");

  /**
   * 14.1 Imports: It is a compile-time error if the current library declares a
   * top-level member named <i>p</i>.
   */
  static const CompileTimeErrorCode PREFIX_COLLIDES_WITH_TOP_LEVEL_MEMBER =
      CompileTimeErrorCode(
          'PREFIX_COLLIDES_WITH_TOP_LEVEL_MEMBER',
          "The name '{0}' is already used as an import prefix and can't be "
              "used to name a top-level element.",
          correction:
              "Try renaming either the top-level element or the prefix.");

  /**
   * 16.32 Identifier Reference: If d is a prefix p, a compile-time error
   * occurs unless the token immediately following d is '.'.
   */
  static const CompileTimeErrorCode PREFIX_IDENTIFIER_NOT_FOLLOWED_BY_DOT =
      CompileTimeErrorCode(
          'PREFIX_IDENTIFIER_NOT_FOLLOWED_BY_DOT',
          "The name '{0}' refers to an import prefix, so it must be followed "
              "by '.'.",
          correction:
              "Try correcting the name to refer to something other than a "
              "prefix, or renaming the prefix.");

  /**
   * It is an error for a mixin to add a private name that conflicts with a
   * private name added by a superclass or another mixin.
   */
  static const CompileTimeErrorCode PRIVATE_COLLISION_IN_MIXIN_APPLICATION =
      CompileTimeErrorCode(
          'PRIVATE_COLLISION_IN_MIXIN_APPLICATION',
          "The private name '{0}', defined by '{1}', "
              "conflicts with the same name defined by '{2}'.",
          correction: "Try removing '{1}' from the 'with' clause.");

  /**
   * 6.2.2 Optional Formals: It is a compile-time error if the name of a named
   * optional parameter begins with an '_' character.
   */
  static const CompileTimeErrorCode PRIVATE_OPTIONAL_PARAMETER =
      CompileTimeErrorCode('PRIVATE_OPTIONAL_PARAMETER',
          "Named optional parameters can't start with an underscore.");

  /**
   * 12.1 Constants: It is a compile-time error if the value of a compile-time
   * constant expression depends on itself.
   */
  static const CompileTimeErrorCode RECURSIVE_COMPILE_TIME_CONSTANT =
      CompileTimeErrorCode('RECURSIVE_COMPILE_TIME_CONSTANT',
          "Compile-time constant expression depends on itself.");

  /**
   * 7.6.1 Generative Constructors: A generative constructor may be redirecting,
   * in which case its only action is to invoke another generative constructor.
   *
   * TODO(scheglov) review this later, there are no explicit "it is a
   * compile-time error" in specification. But it was added to the co19 and
   * there is same error for factories.
   *
   * https://code.google.com/p/dart/issues/detail?id=954
   */
  static const CompileTimeErrorCode RECURSIVE_CONSTRUCTOR_REDIRECT =
      CompileTimeErrorCode('RECURSIVE_CONSTRUCTOR_REDIRECT',
          "Cycle in redirecting generative constructors.");

  /**
   * 7.6.2 Factories: It is a compile-time error if a redirecting factory
   * constructor redirects to itself, either directly or indirectly via a
   * sequence of redirections.
   */
  static const CompileTimeErrorCode RECURSIVE_FACTORY_REDIRECT =
      CompileTimeErrorCode('RECURSIVE_FACTORY_REDIRECT',
          "Cycle in redirecting factory constructors.");

  /**
   * 7.10 Superinterfaces: It is a compile-time error if the interface of a
   * class <i>C</i> is a superinterface of itself.
   *
   * 8.1 Superinterfaces: It is a compile-time error if an interface is a
   * superinterface of itself.
   *
   * 7.9 Superclasses: It is a compile-time error if a class <i>C</i> is a
   * superclass of itself.
   *
   * Parameters:
   * 0: the name of the class that implements itself recursively
   * 1: a string representation of the implements loop
   */
  static const CompileTimeErrorCode RECURSIVE_INTERFACE_INHERITANCE =
      CompileTimeErrorCode('RECURSIVE_INTERFACE_INHERITANCE',
          "'{0}' can't be a superinterface of itself: {1}.");

  /**
   * 7.10 Superinterfaces: It is a compile-time error if the interface of a
   * class <i>C</i> is a superinterface of itself.
   *
   * 8.1 Superinterfaces: It is a compile-time error if an interface is a
   * superinterface of itself.
   *
   * 7.9 Superclasses: It is a compile-time error if a class <i>C</i> is a
   * superclass of itself.
   *
   * Parameters:
   * 0: the name of the class that implements itself recursively
   */
  static const CompileTimeErrorCode RECURSIVE_INTERFACE_INHERITANCE_EXTENDS =
      CompileTimeErrorCode('RECURSIVE_INTERFACE_INHERITANCE_EXTENDS',
          "'{0}' can't extend itself.");

  /**
   * 7.10 Superinterfaces: It is a compile-time error if the interface of a
   * class <i>C</i> is a superinterface of itself.
   *
   * 8.1 Superinterfaces: It is a compile-time error if an interface is a
   * superinterface of itself.
   *
   * 7.9 Superclasses: It is a compile-time error if a class <i>C</i> is a
   * superclass of itself.
   *
   * Parameters:
   * 0: the name of the class that implements itself recursively
   */
  static const CompileTimeErrorCode RECURSIVE_INTERFACE_INHERITANCE_IMPLEMENTS =
      CompileTimeErrorCode('RECURSIVE_INTERFACE_INHERITANCE_IMPLEMENTS',
          "'{0}' can't implement itself.");

  /**
   * Parameters:
   * 0: the name of the mixin that constraints itself recursively
   */
  static const CompileTimeErrorCode RECURSIVE_INTERFACE_INHERITANCE_ON =
      CompileTimeErrorCode('RECURSIVE_INTERFACE_INHERITANCE_ON',
          "'{0}' can't use itself as a superclass constraint.");

  /**
   * 7.10 Superinterfaces: It is a compile-time error if the interface of a
   * class <i>C</i> is a superinterface of itself.
   *
   * 8.1 Superinterfaces: It is a compile-time error if an interface is a
   * superinterface of itself.
   *
   * 7.9 Superclasses: It is a compile-time error if a class <i>C</i> is a
   * superclass of itself.
   *
   * Parameters:
   * 0: the name of the class that implements itself recursively
   */
  static const CompileTimeErrorCode RECURSIVE_INTERFACE_INHERITANCE_WITH =
      CompileTimeErrorCode('RECURSIVE_INTERFACE_INHERITANCE_WITH',
          "'{0}' can't use itself as a mixin.");

  /**
   * 7.6.1 Generative constructors: A generative constructor may be
   * <i>redirecting</i>, in which case its only action is to invoke another
   * generative constructor.
   */
  static const CompileTimeErrorCode REDIRECT_GENERATIVE_TO_MISSING_CONSTRUCTOR =
      CompileTimeErrorCode('REDIRECT_GENERATIVE_TO_MISSING_CONSTRUCTOR',
          "The constructor '{0}' couldn't be found in '{1}'.",
          correction: "Try redirecting to a different constructor, or "
              "defining the constructor named '{0}'.");

  /**
   * 7.6.1 Generative constructors: A generative constructor may be
   * <i>redirecting</i>, in which case its only action is to invoke another
   * generative constructor.
   */
  static const CompileTimeErrorCode
      REDIRECT_GENERATIVE_TO_NON_GENERATIVE_CONSTRUCTOR = CompileTimeErrorCode(
          'REDIRECT_GENERATIVE_TO_NON_GENERATIVE_CONSTRUCTOR',
          "Generative constructor can't redirect to a factory constructor.",
          correction: "Try redirecting to a different constructor.");

  /**
   * 7.6.2 Factories: It is a compile-time error if <i>k</i> is prefixed with
   * the const modifier but <i>k'</i> is not a constant constructor.
   */
  static const CompileTimeErrorCode REDIRECT_TO_MISSING_CONSTRUCTOR =
      CompileTimeErrorCode('REDIRECT_TO_MISSING_CONSTRUCTOR',
          "The constructor '{0}' couldn't be found in '{1}'.",
          correction: "Try redirecting to a different constructor, or "
              "define the constructor named '{0}'.");

  /**
   * Parameters:
   * 0: the name of the non-type referenced in the redirect
   */
  // #### Description
  //
  // One way to implement a factory constructor is to redirect to another
  // constructor by referencing the name of the constructor. The analyzer
  // produces this diagnostic when the redirect is to something other than a
  // constructor.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `f` is a function:
  //
  // ```dart
  // C f() => null;
  //
  // class C {
  //   factory C() = [!f!];
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the constructor isn't defined, then either define it or replace it with
  // a constructor that is defined.
  //
  // If the constructor is defined but the class that defines it isn't visible,
  // then you probably need to add an import.
  //
  // If you're trying to return the value returned by a function, then rewrite
  // the constructor to return the value from the constructor's body:
  //
  // ```dart
  // C f() => null;
  //
  // class C {
  //   factory C() => f();
  // }
  // ```
  static const CompileTimeErrorCode REDIRECT_TO_NON_CLASS =
      CompileTimeErrorCode(
          'REDIRECT_TO_NON_CLASS',
          "The name '{0}' isn't a type and can't be used in a redirected "
              "constructor.",
          correction: "Try redirecting to a different constructor.",
          hasPublishedDocs: true);

  /**
   * 7.6.2 Factories: It is a compile-time error if <i>k</i> is prefixed with
   * the const modifier but <i>k'</i> is not a constant constructor.
   */
  static const CompileTimeErrorCode REDIRECT_TO_NON_CONST_CONSTRUCTOR =
      CompileTimeErrorCode(
          'REDIRECT_TO_NON_CONST_CONSTRUCTOR',
          "Constant redirecting constructor can't redirect to a non-constant "
              "constructor.",
          correction: "Try redirecting to a different constructor.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a variable is referenced before
  // it’s declared. In Dart, variables are visible everywhere in the block in
  // which they are declared, but can only be referenced after they are
  // declared.
  //
  // The analyzer also produces a context message that indicates where the
  // declaration is located.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `i` is used before it
  // is declared:
  //
  // ```dart
  // void f() {
  //   print([!i!]);
  //   int i = 5;
  // }
  // ```
  //
  // #### Common fixes
  //
  // If you intended to reference the local variable, move the declaration
  // before the first reference:
  //
  // ```dart
  // void f() {
  //   int i = 5;
  //   print(i);
  // }
  // ```
  //
  // If you intended to reference a name from an outer scope, such as a
  // parameter, instance field or top-level variable, then rename the local
  // declaration so that it doesn't hide the outer variable.
  //
  // ```dart
  // void f(int i) {
  //   print(i);
  //   int x = 5;
  //   print(x);
  // }
  // ```
  static const CompileTimeErrorCode REFERENCED_BEFORE_DECLARATION =
      CompileTimeErrorCode('REFERENCED_BEFORE_DECLARATION',
          "Local variable '{0}' can't be referenced before it is declared.",
          correction: "Try moving the declaration to before the first use, or "
              "renaming the local variable so that it doesn't hide a name from "
              "an enclosing scope.",
          hasPublishedDocs: true);

  /**
   * 12.8.1 Rethrow: It is a compile-time error if an expression of the form
   * <i>rethrow;</i> is not enclosed within a on-catch clause.
   */
  static const CompileTimeErrorCode RETHROW_OUTSIDE_CATCH =
      CompileTimeErrorCode(
          'RETHROW_OUTSIDE_CATCH', "Rethrow must be inside of catch clause.",
          correction:
              "Try moving the expression into a catch clause, or using a "
              "'throw' expression.");

  /**
   * 13.12 Return: It is a compile-time error if a return statement of the form
   * <i>return e;</i> appears in a generative constructor.
   */
  static const CompileTimeErrorCode RETURN_IN_GENERATIVE_CONSTRUCTOR =
      CompileTimeErrorCode('RETURN_IN_GENERATIVE_CONSTRUCTOR',
          "Constructors can't return values.",
          correction: "Try removing the return statement or using a factory "
              "constructor.");

  /**
   * 13.12 Return: It is a compile-time error if a return statement of the form
   * <i>return e;</i> appears in a generator function.
   */
  static const CompileTimeErrorCode RETURN_IN_GENERATOR = CompileTimeErrorCode(
      'RETURN_IN_GENERATOR',
      "Can't return a value from a generator function (using the '{0}' "
          "modifier).",
      correction: "Try removing the value, replacing 'return' with 'yield' or "
          "changing the method body modifier.");

  static const CompileTimeErrorCode SET_ELEMENT_FROM_DEFERRED_LIBRARY =
      CompileTimeErrorCode(
          'SET_ELEMENT_FROM_DEFERRED_LIBRARY',
          "Constant values from a deferred library can't be used as values in "
              "a const set.",
          correction: "Try making the deferred import non-deferred.");

  /**
   * 14.1 Imports: It is a compile-time error if a prefix used in a deferred
   * import is used in another import clause.
   */
  static const CompileTimeErrorCode SHARED_DEFERRED_PREFIX =
      CompileTimeErrorCode(
          'SHARED_DEFERRED_PREFIX',
          "The prefix of a deferred import can't be used in other import "
              "directives.",
          correction: "Try renaming one of the prefixes.");

  static const CompileTimeErrorCode SPREAD_EXPRESSION_FROM_DEFERRED_LIBRARY =
      CompileTimeErrorCode(
          'SPREAD_EXPRESSION_FROM_DEFERRED_LIBRARY',
          "Constant values from a deferred library can't be spread into a "
              "const literal.",
          correction: "Try making the deferred import non-deferred.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a member declared inside an
  // extension uses the `super` keyword . Extensions aren't classes and don't
  // have superclasses, so the `super` keyword serves no purpose.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `super` can't be used
  // in an extension:
  //
  // ```dart
  // extension E on Object {
  //   String get displayString => [!super!].toString();
  // }
  // ```
  //
  // #### Common fixes
  //
  // Remove the `super` keyword :
  //
  // ```dart
  // extension E on Object {
  //   String get displayString => toString();
  // }
  // ```
  static const CompileTimeErrorCode SUPER_IN_EXTENSION = CompileTimeErrorCode(
      'SUPER_IN_EXTENSION',
      "The 'super' keyword can't be used in an extension because an "
          "extension doesn't have a superclass.",
      hasPublishedDocs: true);

  /**
   * 12.15.4 Super Invocation: A super method invocation <i>i</i> has the form
   * <i>super.m(a<sub>1</sub>, &hellip;, a<sub>n</sub>, x<sub>n+1</sub>:
   * a<sub>n+1</sub>, &hellip; x<sub>n+k</sub>: a<sub>n+k</sub>)</i>. It is a
   * compile-time error if a super method invocation occurs in a top-level
   * function or variable initializer, in an instance variable initializer or
   * initializer list, in class Object, in a factory constructor, or in a static
   * method or variable initializer.
   */
  static const CompileTimeErrorCode SUPER_IN_INVALID_CONTEXT =
      CompileTimeErrorCode('SUPER_IN_INVALID_CONTEXT',
          "Invalid context for 'super' invocation.");

  /**
   * 7.6.1 Generative Constructors: A generative constructor may be redirecting,
   * in which case its only action is to invoke another generative constructor.
   */
  static const CompileTimeErrorCode SUPER_IN_REDIRECTING_CONSTRUCTOR =
      CompileTimeErrorCode('SUPER_IN_REDIRECTING_CONSTRUCTOR',
          "The redirecting constructor can't have a 'super' initializer.");

  /**
   * 7.6.1 Generative Constructors: Let <i>k</i> be a generative constructor. It
   * is a compile-time error if a generative constructor of class Object
   * includes a superinitializer.
   */
  static const CompileTimeErrorCode SUPER_INITIALIZER_IN_OBJECT =
      CompileTimeErrorCode('SUPER_INITIALIZER_IN_OBJECT',
          "The class 'Object' can't invoke a constructor from a superclass.");

  /**
   * Parameters:
   * 0: the name of the type used in the instance creation that should be
   *    limited by the bound as specified in the class declaration
   * 1: the name of the bounding type
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a type argument isn't the same
  // as or a subclass of the bounds of the corresponding type parameter.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `String` isn't a
  // subclass of `num`:
  //
  // ```dart
  // class A<E extends num> {}
  //
  // var a = A<[!String!]>();
  // ```
  //
  // #### Common fixes
  //
  // Change the type argument to be a subclass of the bounds:
  //
  // ```dart
  // class A<E extends num> {}
  //
  // var a = A<int>();
  // ```
  static const CompileTimeErrorCode TYPE_ARGUMENT_NOT_MATCHING_BOUNDS =
      CompileTimeErrorCode(
          'TYPE_ARGUMENT_NOT_MATCHING_BOUNDS', "'{0}' doesn't extend '{1}'.",
          correction: "Try using a type that is or is a subclass of '{1}'.",
          hasPublishedDocs: true);

  /**
   * 15.3.1 Typedef: Any self reference, either directly, or recursively via
   * another typedef, is a compile time error.
   */
  static const CompileTimeErrorCode TYPE_ALIAS_CANNOT_REFERENCE_ITSELF =
      CompileTimeErrorCode(
          'TYPE_ALIAS_CANNOT_REFERENCE_ITSELF',
          "Typedefs can't reference themselves directly or recursively via "
              "another typedef.");

  @Deprecated('Use ParserErrorCode.TYPE_PARAMETER_ON_CONSTRUCTOR')
  static const ParserErrorCode TYPE_PARAMETER_ON_CONSTRUCTOR =
      ParserErrorCode.TYPE_PARAMETER_ON_CONSTRUCTOR;

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a name that isn't defined is
  // used as an annotation.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the name `undefined`
  // isn't defined:
  //
  // ```dart
  // [!@undefined!]
  // void f() {}
  // ```
  //
  // #### Common fixes
  //
  // If the name is correct, but it isn’t declared yet, then declare the name as
  // a constant value:
  //
  // ```dart
  // const undefined = 'undefined';
  //
  // @undefined
  // void f() {}
  // ```
  //
  // If the name is wrong, replace the name with the name of a valid constant:
  //
  // ```dart
  // @deprecated
  // void f() {}
  // ```
  //
  // Otherwise, remove the annotation.
  static const CompileTimeErrorCode UNDEFINED_ANNOTATION = CompileTimeErrorCode(
      'UNDEFINED_ANNOTATION', "Undefined name '{0}' used as an annotation.",
      correction: "Try defining the name or importing it from another library.",
      hasPublishedDocs: true,
      isUnresolvedIdentifier: true);

  /**
   * Parameters:
   * 0: the name of the undefined class
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it encounters an identifier that
  // appears to be the name of a class but either isn't defined or isn't visible
  // in the scope in which it's being referenced.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `Piont` isn't defined:
  //
  // ```dart
  // class Point {}
  //
  // void f([!Piont!] p) {}
  // ```
  //
  // #### Common fixes
  //
  // If the identifier isn't defined, then either define it or replace it with
  // the name of a class that is defined. The example above can be corrected by
  // fixing the spelling of the class:
  //
  // ```dart
  // class Point {}
  //
  // void f(Point p) {}
  // ```
  //
  // If the class is defined but isn't visible, then you probably need to add an
  // import.
  static const CompileTimeErrorCode UNDEFINED_CLASS = CompileTimeErrorCode(
      'UNDEFINED_CLASS', "Undefined class '{0}'.",
      correction: "Try changing the name to the name of an existing class, or "
          "creating a class with the name '{0}'.",
      hasPublishedDocs: true,
      isUnresolvedIdentifier: true);

  /**
   * 7.6.1 Generative Constructors: Let <i>C</i> be the class in which the
   * superinitializer appears and let <i>S</i> be the superclass of <i>C</i>.
   * Let <i>k</i> be a generative constructor. It is a compile-time error if
   * class <i>S</i> does not declare a generative constructor named <i>S</i>
   * (respectively <i>S.id</i>)
   *
   * Parameters:
   * 0: the name of the superclass that does not define the invoked constructor
   * 1: the name of the constructor being invoked
   */
  static const CompileTimeErrorCode UNDEFINED_CONSTRUCTOR_IN_INITIALIZER =
      CompileTimeErrorCode('UNDEFINED_CONSTRUCTOR_IN_INITIALIZER',
          "The class '{0}' doesn't have a constructor named '{1}'.",
          correction: "Try defining a constructor named '{1}' in '{0}', or "
              "invoking a different constructor.");

  /**
   * 7.6.1 Generative Constructors: Let <i>C</i> be the class in which the
   * superinitializer appears and let <i>S</i> be the superclass of <i>C</i>.
   * Let <i>k</i> be a generative constructor. It is a compile-time error if
   * class <i>S</i> does not declare a generative constructor named <i>S</i>
   * (respectively <i>S.id</i>)
   *
   * Parameters:
   * 0: the name of the superclass that does not define the invoked constructor
   */
  static const CompileTimeErrorCode
      UNDEFINED_CONSTRUCTOR_IN_INITIALIZER_DEFAULT = CompileTimeErrorCode(
          'UNDEFINED_CONSTRUCTOR_IN_INITIALIZER_DEFAULT',
          "The class '{0}' doesn't have an unnamed constructor.",
          correction: "Try defining an unnamed constructor in '{0}', or "
              "invoking a different constructor.");

  /**
   * Parameters:
   * 0: the name of the getter that is undefined
   * 1: the name of the extension that was explicitly specified
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extension override is used to
  // invoke a getter, but the getter isn't defined by the specified extension.
  // The analyzer also produces this diagnostic when a static getter is
  // referenced but isn't defined by the specified extension.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the extension `E`
  // doesn't declare an instance getter named `b`:
  //
  // ```dart
  // extension E on String {
  //   String get a => 'a';
  // }
  //
  // extension F on String {
  //   String get b => 'b';
  // }
  //
  // void f() {
  //   E('c').[!b!];
  // }
  // ```
  //
  // The following code produces this diagnostic because the extension `E`
  // doesn't declare a static getter named `a`:
  //
  // ```dart
  // extension E on String {}
  //
  // var x = E.[!a!];
  // ```
  //
  // #### Common fixes
  //
  // If the name of the getter is incorrect, then change it to the name of an
  // existing getter:
  //
  // ```dart
  // extension E on String {
  //   String get a => 'a';
  // }
  //
  // extension F on String {
  //   String get b => 'b';
  // }
  //
  // void f() {
  //   E('c').a;
  // }
  // ```
  //
  // If the name of the getter is correct but the name of the extension is
  // wrong, then change the name of the extension to the correct name:
  //
  // ```dart
  // extension E on String {
  //   String get a => 'a';
  // }
  //
  // extension F on String {
  //   String get b => 'b';
  // }
  //
  // void f() {
  //   F('c').b;
  // }
  // ```
  //
  // If the name of the getter and extension are both correct, but the getter
  // isn't defined, then define the getter:
  //
  // ```dart
  // extension E on String {
  //   String get a => 'a';
  //   String get b => 'z';
  // }
  //
  // extension F on String {
  //   String get b => 'b';
  // }
  //
  // void f() {
  //   E('c').b;
  // }
  // ```
  static const CompileTimeErrorCode UNDEFINED_EXTENSION_GETTER =
      CompileTimeErrorCode('UNDEFINED_EXTENSION_GETTER',
          "The getter '{0}' isn't defined for the extension '{1}'.",
          correction:
              "Try correcting the name to the name of an existing getter, or "
              "defining a getter named '{0}'.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the method that is undefined
   * 1: the name of the extension that was explicitly specified
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extension override is used to
  // invoke a method, but the method isn't defined by the specified extension.
  // The analyzer also produces this diagnostic when a static method is
  // referenced but isn't defined by the specified extension.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the extension `E`
  // doesn't declare an instance method named `b`:
  //
  // ```dart
  // extension E on String {
  //   String a() => 'a';
  // }
  //
  // extension F on String {
  //   String b() => 'b';
  // }
  //
  // void f() {
  //   E('c').[!b!]();
  // }
  // ```
  //
  // The following code produces this diagnostic because the extension `E`
  // doesn't declare a static method named `a`:
  //
  // ```dart
  // extension E on String {}
  //
  // var x = E.[!a!]();
  // ```
  //
  // #### Common fixes
  //
  // If the name of the method is incorrect, then change it to the name of an
  // existing method:
  //
  // ```dart
  // extension E on String {
  //   String a() => 'a';
  // }
  //
  // extension F on String {
  //   String b() => 'b';
  // }
  //
  // void f() {
  //   E('c').a();
  // }
  // ```
  //
  // If the name of the method is correct, but the name of the extension is
  // wrong, then change the name of the extension to the correct name:
  //
  // ```dart
  // extension E on String {
  //   String a() => 'a';
  // }
  //
  // extension F on String {
  //   String b() => 'b';
  // }
  //
  // void f() {
  //   F('c').b();
  // }
  // ```
  //
  // If the name of the method and extension are both correct, but the method
  // isn't defined, then define the method:
  //
  // ```dart
  // extension E on String {
  //   String a() => 'a';
  //   String b() => 'z';
  // }
  //
  // extension F on String {
  //   String b() => 'b';
  // }
  //
  // void f() {
  //   E('c').b();
  // }
  // ```
  static const CompileTimeErrorCode UNDEFINED_EXTENSION_METHOD =
      CompileTimeErrorCode('UNDEFINED_EXTENSION_METHOD',
          "The method '{0}' isn't defined for the extension '{1}'.",
          correction:
              "Try correcting the name to the name of an existing method, or "
              "defining a method named '{0}'.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the operator that is undefined
   * 1: the name of the extension that was explicitly specified
   */
  static const CompileTimeErrorCode UNDEFINED_EXTENSION_OPERATOR =
      CompileTimeErrorCode('UNDEFINED_EXTENSION_OPERATOR',
          "The operator '{0}' isn't defined for the extension '{1}'.",
          correction: "Try defining the operator '{0}'.");

  /**
   * Parameters:
   * 0: the name of the setter that is undefined
   * 1: the name of the extension that was explicitly specified
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an extension override is used to
  // invoke a setter, but the setter isn't defined by the specified extension.
  // The analyzer also produces this diagnostic when a static setter is
  // referenced but isn't defined by the specified extension.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the extension `E`
  // doesn't declare an instance setter named `b`:
  //
  // ```dart
  // extension E on String {
  //   set a(String v) {}
  // }
  //
  // extension F on String {
  //   set b(String v) {}
  // }
  //
  // void f() {
  //   E('c').[!b!] = 'd';
  // }
  // ```
  //
  // The following code produces this diagnostic because the extension `E`
  // doesn't declare a static setter named `a`:
  //
  // ```dart
  // extension E on String {}
  //
  // void f() {
  //   E.[!a!] = 3;
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the name of the setter is incorrect, then change it to the name of an
  // existing setter:
  //
  // ```dart
  // extension E on String {
  //   set a(String v) {}
  // }
  //
  // extension F on String {
  //   set b(String v) {}
  // }
  //
  // void f() {
  //   E('c').a = 'd';
  // }
  // ```
  //
  // If the name of the setter is correct, but the name of the extension is
  // wrong, then change the name of the extension to the correct name:
  //
  // ```dart
  // extension E on String {
  //   set a(String v) {}
  // }
  //
  // extension F on String {
  //   set b(String v) {}
  // }
  //
  // void f() {
  //   F('c').b = 'd';
  // }
  // ```
  //
  // If the name of the setter and extension are both correct, but the setter
  // isn't defined, then define the setter:
  //
  // ```dart
  // extension E on String {
  //   set a(String v) {}
  //   set b(String v) {}
  // }
  //
  // extension F on String {
  //   set b(String v) {}
  // }
  //
  // void f() {
  //   E('c').b = 'd';
  // }
  // ```
  static const CompileTimeErrorCode UNDEFINED_EXTENSION_SETTER =
      CompileTimeErrorCode('UNDEFINED_EXTENSION_SETTER',
          "The setter '{0}' isn't defined for the extension '{1}'.",
          correction:
              "Try correcting the name to the name of an existing setter, or "
              "defining a setter named '{0}'.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the requested named parameter
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a method or function invocation
  // has a named argument, but the method or function being invoked doesn't
  // define a parameter with the same name.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `m` doesn't declare a
  // named parameter named `a`:
  //
  // ```dart
  // class C {
  //   m({int b}) {}
  // }
  //
  // void f(C c) {
  //   c.m([!a!]: 1);
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the argument name is mistyped, then replace it with the correct name.
  // The example above can be fixed by changing `a` to `b`:
  //
  // ```dart
  // class C {
  //   m({int b}) {}
  // }
  //
  // void f(C c) {
  //   c.m(b: 1);
  // }
  // ```
  //
  // If a subclass adds a parameter with the name in question, then cast the
  // target to the subclass:
  //
  // ```dart
  // class C {
  //   m({int b}) {}
  // }
  //
  // class D extends C {
  //   m({int a, int b}) {}
  // }
  //
  // void f(C c) {
  //   (c as D).m(a: 1);
  // }
  // ```
  //
  // If the parameter should be added to the function, then add it:
  //
  // ```dart
  // class C {
  //   m({int a, int b}) {}
  // }
  //
  // void f(C c) {
  //   c.m(a: 1);
  // }
  // ```
  static const CompileTimeErrorCode UNDEFINED_NAMED_PARAMETER =
      CompileTimeErrorCode('UNDEFINED_NAMED_PARAMETER',
          "The named parameter '{0}' isn't defined.",
          correction:
              "Try correcting the name to an existing named parameter's name, "
              "or defining a named parameter with the name '{0}'.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the defining type
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an undefined name is found, and
  // the name is the same as a static member of the extended type or one of its
  // superclasses.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `m` is a static member
  // of the extended type `C`:
  //
  // ```dart
  // class C {
  //   static void m() {}
  // }
  //
  // extension E on C {
  //   void f() {
  //     [!m!]();
  //   }
  // }
  // ```
  //
  // #### Common fixes
  //
  // If you're trying to reference a static member that's declared outside the
  // extension, then add the name of the class or extension before the reference
  // to the member:
  //
  // ```dart
  // class C {
  //   static void m() {}
  // }
  //
  // extension E on C {
  //   void f() {
  //     C.m();
  //   }
  // }
  // ```
  //
  // If you're referencing a member that isn't declared yet, add a declaration:
  //
  // ```dart
  // class C {
  //   static void m() {}
  // }
  //
  // extension E on C {
  //   void f() {
  //     m();
  //   }
  //
  //   void m() {}
  // }
  // ```
  static const CompileTimeErrorCode
      UNQUALIFIED_REFERENCE_TO_STATIC_MEMBER_OF_EXTENDED_TYPE =
      CompileTimeErrorCode(
          'UNQUALIFIED_REFERENCE_TO_STATIC_MEMBER_OF_EXTENDED_TYPE',
          "Static members from the extended type or one of its superclasses "
              "must be qualified by the name of the defining type.",
          correction: "Try adding '{0}.' before the name.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the URI pointing to a non-existent file
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an import, export, or part
  // directive is found where the URI refers to a file that doesn't exist.
  //
  // #### Example
  //
  // If the file `lib.dart` doesn't exist, the following code produces this
  // diagnostic:
  //
  // ```dart
  // import [!'lib.dart'!];
  // ```
  //
  // #### Common fixes
  //
  // If the URI was mistyped or invalid, then correct the URI.
  //
  // If the URI is correct, then create the file.
  static const CompileTimeErrorCode URI_DOES_NOT_EXIST = CompileTimeErrorCode(
      'URI_DOES_NOT_EXIST', "Target of URI doesn't exist: '{0}'.",
      correction: "Try creating the file referenced by the URI, or "
          "Try using a URI for a file that does exist.",
      hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the URI pointing to a non-existent file
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an import, export, or part
  // directive is found where the URI refers to a file that doesn't exist and
  // the name of the file ends with a pattern that's commonly produced by code
  // generators, such as one of the following:
  // - `.g.dart`
  // - `.pb.dart`
  // - `.pbenum.dart`
  // - `.pbserver.dart`
  // - `.pbjson.dart`
  // - `.template.dart`
  //
  // #### Example
  //
  // If the file `lib.g.dart` doesn't exist, the following code produces this
  // diagnostic:
  //
  // ```dart
  // import [!'lib.g.dart'!];
  // ```
  //
  // #### Common fixes
  //
  // If the file is a generated file, then run the generator that generates the
  // file.
  //
  // If the file isn't a generated file, then check the spelling of the URI or
  // create the file.
  static const CompileTimeErrorCode URI_HAS_NOT_BEEN_GENERATED =
      CompileTimeErrorCode('URI_HAS_NOT_BEEN_GENERATED',
          "Target of URI hasn't been generated: '{0}'.",
          correction: "Try running the generator that will generate the file "
              "referenced by the URI.",
          hasPublishedDocs: true);

  /**
   * 14.1 Imports: It is a compile-time error if <i>x</i> is not a compile-time
   * constant, or if <i>x</i> involves string interpolation.
   *
   * 14.3 Parts: It is a compile-time error if <i>s</i> is not a compile-time
   * constant, or if <i>s</i> involves string interpolation.
   *
   * 14.5 URIs: It is a compile-time error if the string literal <i>x</i> that
   * describes a URI is not a compile-time constant, or if <i>x</i> involves
   * string interpolation.
   */
  static const CompileTimeErrorCode URI_WITH_INTERPOLATION =
      CompileTimeErrorCode(
          'URI_WITH_INTERPOLATION', "URIs can't use string interpolation.");

  /**
   * Parameters:
   * 0: the name of the declared operator
   * 1: the number of parameters expected
   * 2: the number of parameters found in the operator declaration
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a declaration of an operator has
  // the wrong number of parameters.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the operator `+` must
  // have a single parameter corresponding to the right operand:
  //
  // ```dart
  // class C {
  //   int operator [!+!](a, b) => 0;
  // }
  // ```
  //
  // #### Common fixes
  //
  // Add or remove parameters to match the required number:
  //
  // ```dart
  // class C {
  //   int operator +(a) => 0;
  // }
  // ```
  // TODO(brianwilkerson) It would be good to add a link to the spec or some
  //  other documentation that lists the number of parameters for each operator,
  //  but I don't know what to link to.
  static const CompileTimeErrorCode WRONG_NUMBER_OF_PARAMETERS_FOR_OPERATOR =
      CompileTimeErrorCode(
          'WRONG_NUMBER_OF_PARAMETERS_FOR_OPERATOR',
          "Operator '{0}' should declare exactly {1} parameters, but {2} "
              "found.",
          hasPublishedDocs: true);

  /**
   * 7.1.1 Operators: It is a compile time error if the arity of the
   * user-declared operator - is not 0 or 1.
   *
   * Parameters:
   * 0: the number of parameters found in the operator declaration
   */
  static const CompileTimeErrorCode
      WRONG_NUMBER_OF_PARAMETERS_FOR_OPERATOR_MINUS = CompileTimeErrorCode(
          'WRONG_NUMBER_OF_PARAMETERS_FOR_OPERATOR_MINUS',
          "Operator '-' should declare 0 or 1 parameter, but {0} found.");

  /**
   * 7.3 Setters: It is a compile-time error if a setter's formal parameter list
   * does not include exactly one required formal parameter <i>p</i>.
   */
  static const CompileTimeErrorCode WRONG_NUMBER_OF_PARAMETERS_FOR_SETTER =
      CompileTimeErrorCode('WRONG_NUMBER_OF_PARAMETERS_FOR_SETTER',
          "Setters should declare exactly one required parameter.");

  /**
   * Let `C` be a generic class that declares a formal type parameter `X`, and
   * assume that `T` is a direct superinterface of `C`. It is a compile-time
   * error if `X` occurs contravariantly or invariantly in `T`.
   */
  static const CompileTimeErrorCode
      WRONG_TYPE_PARAMETER_VARIANCE_IN_SUPERINTERFACE = CompileTimeErrorCode(
    'WRONG_TYPE_PARAMETER_VARIANCE_IN_SUPERINTERFACE',
    "'{0}' can't be used contravariantly or invariantly in '{1}'.",
    correction: "Try not using class type parameters in types of formal "
        "parameters of function types, nor in explicitly contravariant or "
        "invariant superinterfaces.",
  );

  /**
   * Let `C` be a generic class that declares a formal type parameter `X`.
   *
   * If `X` is explicitly contravariant then it is a compile-time error for
   * `X` to occur in a non-contravariant position in a member signature in the
   * body of `C`, except when `X` is in a contravariant position in the type
   * annotation of a covariant formal parameter.
   *
   * If `X` is explicitly covariant then it is a compile-time error for
   * `X` to occur in a non-covariant position in a member signature in the
   * body of `C`, except when `X` is in a covariant position in the type
   * annotation of a covariant formal parameter.
   *
   * Parameters:
   * 0: the variance modifier defined for {0}
   * 1: the name of the type parameter
   * 2: the variance position that the type parameter {1} is in
   */
  static const CompileTimeErrorCode WRONG_TYPE_PARAMETER_VARIANCE_POSITION =
      CompileTimeErrorCode(
    'WRONG_TYPE_PARAMETER_VARIANCE_POSITION',
    "The '{0}' type parameter '{1}' can't be used in an '{2}' position.",
    correction: "Try removing the type parameter or change the explicit "
        "variance modifier declaration for the type parameter to another one of"
        " 'in', 'out', or 'inout'.",
  );

  /**
   * Let `C` be a generic class that declares a formal type parameter `X`, and
   * assume that `T` is a direct superinterface of `C`.
   *
   * It is a compile-time error if `X` is explicitly defined as a covariant or
   * 'in' type parameter and `X` occurs in a non-covariant position in `T`.
   * It is a compile-time error if `X` is explicitly defined as a contravariant
   * or 'out' type parameter and `X` occurs in a non-contravariant position in
   * `T`.
   *
   * Parameters:
   * 0: the name of the type parameter
   * 1: the variance modifier defined for {0}
   * 2: the variance position of the type parameter {0} in the
   *    superinterface {3}
   * 3: the name of the superinterface
   */
  static const CompileTimeErrorCode
      WRONG_EXPLICIT_TYPE_PARAMETER_VARIANCE_IN_SUPERINTERFACE =
      CompileTimeErrorCode(
    'WRONG_EXPLICIT_TYPE_PARAMETER_VARIANCE_IN_SUPERINTERFACE',
    "'{0}' is an '{1}' type parameter and can't be used in an '{2}' position in '{3}'.",
    correction: "Try using 'in' type parameters in 'in' positions and 'out' "
        "type parameters in 'out' positions in the superinterface.",
  );

  /**
   * ?? Yield: It is a compile-time error if a yield statement appears in a
   * function that is not a generator function.
   */
  static const CompileTimeErrorCode YIELD_EACH_IN_NON_GENERATOR =
      CompileTimeErrorCode(
          'YIELD_EACH_IN_NON_GENERATOR',
          "Yield-each statements must be in a generator function "
              "(one marked with either 'async*' or 'sync*').",
          correction:
              "Try adding 'async*' or 'sync*' to the enclosing function.");

  /**
   * ?? Yield: It is a compile-time error if a yield statement appears in a
   * function that is not a generator function.
   */
  static const CompileTimeErrorCode YIELD_IN_NON_GENERATOR =
      CompileTimeErrorCode(
          'YIELD_IN_NON_GENERATOR',
          "Yield statements must be in a generator function "
              "(one marked with either 'async*' or 'sync*').",
          correction:
              "Try adding 'async*' or 'sync*' to the enclosing function.");

  /**
   * Initialize a newly created error code to have the given [name]. The message
   * associated with the error will be created from the given [message]
   * template. The correction associated with the error will be created from the
   * given [correction] template.
   */
  const CompileTimeErrorCode(String name, String message,
      {String correction,
      bool hasPublishedDocs,
      bool isUnresolvedIdentifier = false})
      : super.temporary(name, message,
            correction: correction,
            hasPublishedDocs: hasPublishedDocs,
            isUnresolvedIdentifier: isUnresolvedIdentifier);

  @override
  ErrorSeverity get errorSeverity => ErrorType.COMPILE_TIME_ERROR.severity;

  @override
  ErrorType get type => ErrorType.COMPILE_TIME_ERROR;
}

class CompileTimeErrorCodeWithUniqueName extends CompileTimeErrorCode {
  @override
  final String uniqueName;

  const CompileTimeErrorCodeWithUniqueName(
      String name, this.uniqueName, String message,
      {String correction, bool hasPublishedDocs})
      : super(name, message,
            correction: correction, hasPublishedDocs: hasPublishedDocs);
}

/**
 * The error codes used for static type warnings. The convention for this class
 * is for the name of the error code to indicate the problem that caused the
 * error to be generated and for the error message to explain what is wrong and,
 * when appropriate, how the problem can be corrected.
 */
class StaticTypeWarningCode extends AnalyzerErrorCode {
  /**
   * 12.7 Lists: A fresh instance (7.6.1) <i>a</i>, of size <i>n</i>, whose
   * class implements the built-in class <i>List&lt;E></i> is allocated.
   *
   * Parameters:
   * 0: the number of provided type arguments
   */
  static const StaticTypeWarningCode EXPECTED_ONE_LIST_TYPE_ARGUMENTS =
      StaticTypeWarningCode(
          'EXPECTED_ONE_LIST_TYPE_ARGUMENTS',
          "List literals require exactly one type argument or none, "
              "but {0} found.",
          correction: "Try adjusting the number of type arguments.");

  /**
   * Parameters:
   * 0: the number of provided type arguments
   */
  static const StaticTypeWarningCode EXPECTED_ONE_SET_TYPE_ARGUMENTS =
      StaticTypeWarningCode(
          'EXPECTED_ONE_SET_TYPE_ARGUMENTS',
          "Set literals require exactly one type argument or none, "
              "but {0} found.",
          correction: "Try adjusting the number of type arguments.");

  /**
   * 12.8 Maps: A fresh instance (7.6.1) <i>m</i>, of size <i>n</i>, whose class
   * implements the built-in class <i>Map&lt;K, V></i> is allocated.
   *
   * Parameters:
   * 0: the number of provided type arguments
   */
  static const StaticTypeWarningCode EXPECTED_TWO_MAP_TYPE_ARGUMENTS =
      StaticTypeWarningCode(
          'EXPECTED_TWO_MAP_TYPE_ARGUMENTS',
          "Map literals require exactly two type arguments or none, "
              "but {0} found.",
          correction: "Try adjusting the number of type arguments.");

  /**
   * 9 Functions: It is a static warning if the declared return type of a
   * function marked async* may not be assigned to Stream.
   */
  static const StaticTypeWarningCode ILLEGAL_ASYNC_GENERATOR_RETURN_TYPE =
      StaticTypeWarningCode(
          'ILLEGAL_ASYNC_GENERATOR_RETURN_TYPE',
          "Functions marked 'async*' must have a return type assignable to "
              "'Stream'.",
          correction: "Try fixing the return type of the function, or "
              "removing the modifier 'async*' from the function body.");

  /**
   * 9 Functions: It is a static warning if the declared return type of a
   * function marked async may not be assigned to Future.
   */
  static const StaticTypeWarningCode ILLEGAL_ASYNC_RETURN_TYPE =
      StaticTypeWarningCode(
          'ILLEGAL_ASYNC_RETURN_TYPE',
          "Functions marked 'async' must have a return type assignable to "
              "'Future'.",
          correction: "Try fixing the return type of the function, or "
              "removing the modifier 'async' from the function body.");

  /**
   * 9 Functions: It is a static warning if the declared return type of a
   * function marked sync* may not be assigned to Iterable.
   */
  static const StaticTypeWarningCode ILLEGAL_SYNC_GENERATOR_RETURN_TYPE =
      StaticTypeWarningCode(
          'ILLEGAL_SYNC_GENERATOR_RETURN_TYPE',
          "Functions marked 'sync*' must have a return type assignable to "
              "'Iterable'.",
          correction: "Try fixing the return type of the function, or "
              "removing the modifier 'sync*' from the function body.");

  /**
   * 12.15.1 Ordinary Invocation: It is a static type warning if <i>T</i> does
   * not have an accessible (3.2) instance member named <i>m</i>.
   *
   * Parameters:
   * 0: the name of the static member
   * 1: the kind of the static member (field, getter, setter, or method)
   * 2: the name of the defining class
   *
   * See [UNQUALIFIED_REFERENCE_TO_NON_LOCAL_STATIC_MEMBER].
   */
  static const StaticTypeWarningCode INSTANCE_ACCESS_TO_STATIC_MEMBER =
      StaticTypeWarningCode('INSTANCE_ACCESS_TO_STATIC_MEMBER',
          "Static {1} '{0}' can't be accessed through an instance.",
          correction: "Try using the class '{2}' to access the {1}.");

  /**
   * Parameters:
   * 0: the name of the right hand side type
   * 1: the name of the left hand side type
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the static type of an expression
  // that is assigned to a variable isn't assignable to the type of the
  // variable.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the type of the
  // initializer (`int`) isn't assignable to the type of the variable
  // (`String`):
  //
  // ```dart
  // int i = 0;
  // String s = [!i!];
  // ```
  //
  // #### Common fixes
  //
  // If the value being assigned is always assignable at runtime, even though
  // the static types don't reflect that, then add an explicit cast.
  //
  // Otherwise, change the value being assigned so that it has the expected
  // type. In the previous example, this might look like:
  //
  // ```dart
  // int i = 0;
  // String s = i.toString();
  // ```
  //
  // If you can’t change the value, then change the type of the variable to be
  // compatible with the type of the value being assigned:
  //
  // ```dart
  // int i = 0;
  // int s = i;
  // ```
  static const StaticTypeWarningCode INVALID_ASSIGNMENT = StaticTypeWarningCode(
      'INVALID_ASSIGNMENT',
      "A value of type '{0}' can't be assigned to a variable of type "
          "'{1}'.",
      correction: "Try changing the type of the variable, or "
          "casting the right-hand type to '{1}'.",
      hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the identifier that is not a function type
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it finds a function invocation,
  // but the name of the function being invoked is defined to be something other
  // than a function.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `Binary` is the name of
  // a function type, not a function:
  //
  // ```dart
  // typedef Binary = int Function(int, int);
  //
  // int f() {
  //   return [!Binary!](1, 2);
  // }
  // ```
  //
  // #### Common fixes
  //
  // Replace the name with the name of a function.
  static const StaticTypeWarningCode INVOCATION_OF_NON_FUNCTION =
      StaticTypeWarningCode(
          'INVOCATION_OF_NON_FUNCTION', "'{0}' isn't a function.",
          // TODO(brianwilkerson) Split this error code so that we can provide
          // better error and correction messages.
          correction:
              "Try correcting the name to match an existing function, or "
              "define a method or function named '{0}'.",
          hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a function invocation is found,
  // but the name being referenced isn't the name of a function, or when the
  // expression computing the function doesn't compute a function.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` isn't a function:
  //
  // ```dart
  // int x = 0;
  //
  // int f() => x;
  //
  // var y = [!x!]();
  // ```
  //
  // The following code produces this diagnostic because `f()` doesn't return a
  // function:
  //
  // ```dart
  // int x = 0;
  //
  // int f() => x;
  //
  // var y = [!f()!]();
  // ```
  //
  // #### Common fixes
  //
  // If you need to invoke a function, then replace the code before the argument
  // list with the name of a function or with an expression that computes a
  // function:
  //
  // ```dart
  // int x = 0;
  //
  // int f() => x;
  //
  // var y = f();
  // ```
  static const StaticTypeWarningCode INVOCATION_OF_NON_FUNCTION_EXPRESSION =
      StaticTypeWarningCode(
          'INVOCATION_OF_NON_FUNCTION_EXPRESSION',
          "The expression doesn't evaluate to a function, so it can't be "
              "invoked.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a condition, such as an `if` or
  // `while` loop, doesn't have the static type `bool`.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` has the static type
  // `int`:
  //
  // ```dart
  // void f(int x) {
  //   if ([!x!]) {
  //     // ...
  //   }
  // }
  // ```
  //
  // #### Common fixes
  //
  // Change the condition so that it produces a Boolean value:
  //
  // ```dart
  // void f(int x) {
  //   if (x == 0) {
  //     // ...
  //   }
  // }
  // ```
  static const StaticTypeWarningCode NON_BOOL_CONDITION = StaticTypeWarningCode(
      'NON_BOOL_CONDITION', "Conditions must have a static type of 'bool'.",
      correction: "Try changing the condition.", hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the first expression in an
  // assert has a type other than `bool`.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the type of `p` is
  // `int`, but a `bool` is required:
  //
  // ```dart
  // void f(int p) {
  //   assert([!p!]);
  // }
  // ```
  //
  // #### Common fixes
  //
  // Change the expression so that it has the type `bool`:
  //
  // ```dart
  // void f(int p) {
  //   assert(p > 0);
  // }
  // ```
  static const StaticTypeWarningCode NON_BOOL_EXPRESSION =
      StaticTypeWarningCode('NON_BOOL_EXPRESSION',
          "The expression in an assert must be of type 'bool'.",
          correction: "Try changing the expression.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the operand of the unary
  // negation operator (`!`) doesn't have the type `bool`.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` is an `int` when it
  // must be a `bool`:
  //
  // ```dart
  // int x = 0;
  // bool y = ![!x!];
  // ```
  //
  // #### Common fixes
  //
  // Replace the operand with an expression that has the type `bool`:
  //
  // ```dart
  // int x = 0;
  // bool y = !(x > 0);
  // ```
  static const StaticTypeWarningCode NON_BOOL_NEGATION_EXPRESSION =
      StaticTypeWarningCode('NON_BOOL_NEGATION_EXPRESSION',
          "A negation operand must have a static type of 'bool'.",
          correction: "Try changing the operand to the '!' operator.");

  /**
   * Parameters:
   * 0: the lexeme of the logical operator
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when one of the operands of either
  // the `&&` or `||` operator doesn't have the type `bool`.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `a` isn't a Boolean
  // value:
  //
  // ```dart
  // int a = 3;
  // bool b = [!a!] || a > 1;
  // ```
  //
  // #### Common fixes
  //
  // Change the operand to a Boolean value:
  //
  // ```dart
  // int a = 3;
  // bool b = a == 0 || a > 1;
  // ```
  static const StaticTypeWarningCode NON_BOOL_OPERAND = StaticTypeWarningCode(
      'NON_BOOL_OPERAND',
      "The operands of the operator '{0}' must be assignable to 'bool'.");

  /**
   * Parameters:
   * 0: the name appearing where a type is expected
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an identifier that isn't a type
  // is used as a type argument.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` is a variable, not
  // a type:
  //
  // ```dart
  // var x = 0;
  // List<[!x!]> xList = [];
  // ```
  //
  // #### Common fixes
  //
  // Change the type argument to be a type:
  //
  // ```dart
  // var x = 0;
  // List<int> xList = [];
  // ```
  static const StaticTypeWarningCode NON_TYPE_AS_TYPE_ARGUMENT =
      StaticTypeWarningCode('NON_TYPE_AS_TYPE_ARGUMENT',
          "The name '{0}' isn't a type so it can't be used as a type argument.",
          correction: "Try correcting the name to an existing type, or "
              "defining a type named '{0}'.",
          hasPublishedDocs: true,
          isUnresolvedIdentifier: true);

  /**
   * Parameters:
   * 0: the return type as declared in the return statement
   * 1: the expected return type as defined by the method
   * 2: the name of the method
   */
  @Deprecated('Use either RETURN_OF_INVALID_TYPE_FROM_FUNCTION or '
      'RETURN_OF_INVALID_TYPE_FROM_METHOD')
  static const StaticTypeWarningCode RETURN_OF_INVALID_TYPE =
      StaticTypeWarningCode(
          'RETURN_OF_INVALID_TYPE',
          "The return type '{0}' isn't a '{1}', as defined by the method "
              "'{2}'.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the return type as declared in the return statement
   * 1: the expected return type as defined by the method
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the static type of a returned
  // expression isn't assignable to the return type that the closure is required
  // to have.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `f` is defined to be a
  // function that returns a `String`, but the closure assigned to it returns an
  // `int`:
  //
  // ```dart
  // String Function(String) f = (s) => [!3!];
  // ```
  //
  // #### Common fixes
  //
  // If the return type is correct, then replace the returned value with a value
  // of the correct type, possibly by converting the existing value:
  //
  // ```dart
  // String Function(String) f = (s) => 3.toString();
  // ```
  static const StaticTypeWarningCode RETURN_OF_INVALID_TYPE_FROM_CLOSURE =
      StaticTypeWarningCode(
          'RETURN_OF_INVALID_TYPE_FROM_CLOSURE',
          "The return type '{0}' isn't a '{1}', as required by the closure's "
              "context.");

  /**
   * Parameters:
   * 0: the return type as declared in the return statement
   * 1: the expected return type as defined by the method
   * 2: the name of the method
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a method or function returns a
  // value whose type isn't assignable to the declared return type.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `f` has a return type
  // of `String` but is returning an `int`:
  //
  // ```dart
  // String f() => [!3!];
  // ```
  //
  // #### Common fixes
  //
  // If the return type is correct, then replace the value being returned with a
  // value of the correct type, possibly by converting the existing value:
  //
  // ```dart
  // String f() => 3.toString();
  // ```
  //
  // If the value is correct, then change the return type to match:
  //
  // ```dart
  // int f() => 3;
  // ```
  static const StaticTypeWarningCode RETURN_OF_INVALID_TYPE_FROM_FUNCTION =
      StaticTypeWarningCodeWithUniqueName(
          'RETURN_OF_INVALID_TYPE',
          'StaticTypeWarningCode.RETURN_OF_INVALID_TYPE_FROM_FUNCTION',
          "A value of type '{0}' can't be returned from function '{2}' because "
              "it has a return type of '{1}'.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the return type as declared in the return statement
   * 1: the expected return type as defined by the method
   * 2: the name of the method
   */
  static const StaticTypeWarningCode RETURN_OF_INVALID_TYPE_FROM_METHOD =
      StaticTypeWarningCodeWithUniqueName(
          'RETURN_OF_INVALID_TYPE',
          'StaticTypeWarningCode.RETURN_OF_INVALID_TYPE_FROM_METHOD',
          "A value of type '{0}' can't be returned from method '{2}' because "
              "it has a return type of '{1}'.",
          hasPublishedDocs: true);

  /**
   * 10 Generics: It is a static type warning if a type parameter is a supertype
   * of its upper bound.
   *
   * Parameters:
   * 0: the name of the type parameter
   * 1: the name of the bounding type
   *
   * See [CompileTimeErrorCode.TYPE_ARGUMENT_NOT_MATCHING_BOUNDS].
   */
  static const StaticTypeWarningCode TYPE_PARAMETER_SUPERTYPE_OF_ITS_BOUND =
      StaticTypeWarningCode('TYPE_PARAMETER_SUPERTYPE_OF_ITS_BOUND',
          "'{0}' can't be a supertype of its upper bound.",
          correction: "Try using a type that is or is a subclass of '{1}'.");

  /**
   * 12.17 Getter Invocation: It is a static warning if there is no class
   * <i>C</i> in the enclosing lexical scope of <i>i</i>, or if <i>C</i> does
   * not declare, implicitly or explicitly, a getter named <i>m</i>.
   *
   * Parameters:
   * 0: the name of the enumeration constant that is not defined
   * 1: the name of the enumeration used to access the constant
   */
  static const StaticTypeWarningCode UNDEFINED_ENUM_CONSTANT =
      StaticTypeWarningCode('UNDEFINED_ENUM_CONSTANT',
          "There is no constant named '{0}' in '{1}'.",
          correction:
              "Try correcting the name to the name of an existing constant, or "
              "defining a constant named '{0}'.");

  /**
   * Parameters:
   * 0: the name of the method that is undefined
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it encounters an identifier that
  // appears to be the name of a function but either isn't defined or isn't
  // visible in the scope in which it's being referenced.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the name `emty` isn't
  // defined:
  //
  // ```dart
  // List<int> empty() => [];
  //
  // void main() {
  //   print([!emty!]());
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the identifier isn't defined, then either define it or replace it with
  // the name of a function that is defined. The example above can be corrected
  // by fixing the spelling of the function:
  //
  // ```dart
  // List<int> empty() => [];
  //
  // void main() {
  //   print(empty());
  // }
  // ```
  //
  // If the function is defined but isn't visible, then you probably need to add
  // an import or re-arrange your code to make the function visible.
  static const StaticTypeWarningCode UNDEFINED_FUNCTION = StaticTypeWarningCode(
      'UNDEFINED_FUNCTION', "The function '{0}' isn't defined.",
      correction: "Try importing the library that defines '{0}', "
          "correcting the name to the name of an existing function, or "
          "defining a function named '{0}'.",
      hasPublishedDocs: true,
      isUnresolvedIdentifier: true);

  /**
   * Parameters:
   * 0: the name of the getter
   * 1: the name of the enclosing type where the getter is being looked for
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it encounters an identifier that
  // appears to be the name of a getter but either isn't defined or isn't
  // visible in the scope in which it's being referenced.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `String` has no member
  // named `len`:
  //
  // ```dart
  // int f(String s) => s.[!len!];
  // ```
  //
  // #### Common fixes
  //
  // If the identifier isn't defined, then either define it or replace it with
  // the name of a getter that is defined. The example above can be corrected by
  // fixing the spelling of the getter:
  //
  // ```dart
  // int f(String s) => s.length;
  // ```
  static const StaticTypeWarningCode UNDEFINED_GETTER =
      // TODO(brianwilkerson) When the "target" is an enum, report
      //  UNDEFINED_ENUM_CONSTANT instead.
      StaticTypeWarningCode('UNDEFINED_GETTER',
          "The getter '{0}' isn't defined for the class '{1}'.",
          correction: "Try importing the library that defines '{0}', "
              "correcting the name to the name of an existing getter, or "
              "defining a getter or field named '{0}'.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the method that is undefined
   * 1: the resolved type name that the method lookup is happening on
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it encounters an identifier that
  // appears to be the name of a method but either isn't defined or isn't
  // visible in the scope in which it's being referenced.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the identifier
  // `removeMiddle` isn't defined:
  //
  // ```dart
  // int f(List<int> l) => l.[!removeMiddle!]();
  // ```
  //
  // #### Common fixes
  //
  // If the identifier isn't defined, then either define it or replace it with
  // the name of a method that is defined. The example above can be corrected by
  // fixing the spelling of the method:
  //
  // ```dart
  // int f(List<int> l) => l.removeLast();
  // ```
  static const StaticTypeWarningCode UNDEFINED_METHOD = StaticTypeWarningCode(
      'UNDEFINED_METHOD', "The method '{0}' isn't defined for the class '{1}'.",
      correction:
          "Try correcting the name to the name of an existing method, or "
          "defining a method named '{0}'.",
      hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the operator
   * 1: the name of the enclosing type where the operator is being looked for
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a user-definable operator is
  // invoked on an object for which the operator isn't defined.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the class `C` doesn't
  // define the operator `+`:
  //
  // ```dart
  // class C {}
  //
  // C f(C c) => c [!+!] 2;
  // ```
  //
  // #### Common fixes
  //
  // If the operator should be defined for the class, then define it:
  //
  // ```dart
  // class C {
  //   C operator +(int i) => this;
  // }
  //
  // C f(C c) => c + 2;
  // ```
  static const StaticTypeWarningCode UNDEFINED_OPERATOR = StaticTypeWarningCode(
      'UNDEFINED_OPERATOR',
      "The operator '{0}' isn't defined for the class '{1}'.",
      correction: "Try defining the operator '{0}'.",
      hasPublishedDocs: true);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a prefixed identifier is found
  // where the prefix is valid, but the identifier isn't declared in any of the
  // libraries imported using that prefix.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `dart:core` doesn't
  // define anything named `a`:
  //
  // ```dart
  // import 'dart:core' as p;
  //
  // void f() {
  //   p.[!a!];
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the library in which the name is declared isn't imported yet, add an
  // import for the library.
  //
  // If the name is wrong, then change it to one of the names that's declared in
  // the imported libraries.
  static const StaticTypeWarningCode UNDEFINED_PREFIXED_NAME =
      StaticTypeWarningCode(
          'UNDEFINED_PREFIXED_NAME',
          "The name '{0}' is being referenced through the prefix '{1}', but it "
              "isn't defined in any of the libraries imported using that "
              "prefix.",
          correction: "Try correcting the prefix or "
              "importing the library that defines '{0}'.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the setter
   * 1: the name of the enclosing type where the setter is being looked for
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it encounters an identifier that
  // appears to be the name of a setter but either isn't defined or isn't
  // visible in the scope in which the identifier is being referenced.
  //
  // #### Example
  //
  // The following code produces this diagnostic because there isn't a setter
  // named `z`:
  //
  // ```dart
  // class C {
  //   int x = 0;
  //   void m(int y) {
  //     this.[!z!] = y;
  //   }
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the identifier isn't defined, then either define it or replace it with
  // the name of a setter that is defined. The example above can be corrected by
  // fixing the spelling of the setter:
  //
  // ```dart
  // class C {
  //   int x = 0;
  //   void m(int y) {
  //     this.x = y;
  //   }
  // }
  // ```
  static const StaticTypeWarningCode UNDEFINED_SETTER = StaticTypeWarningCode(
      'UNDEFINED_SETTER', "The setter '{0}' isn't defined for the class '{1}'.",
      correction: "Try importing the library that defines '{0}', "
          "correcting the name to the name of an existing setter, or "
          "defining a setter or field named '{0}'.",
      hasPublishedDocs: true);

  /**
   * 12.17 Getter Invocation: Let <i>T</i> be the static type of <i>e</i>. It is
   * a static type warning if <i>T</i> does not have a getter named <i>m</i>.
   *
   * Parameters:
   * 0: the name of the getter
   * 1: the name of the enclosing type where the getter is being looked for
   */
  static const StaticTypeWarningCode UNDEFINED_SUPER_GETTER =
      StaticTypeWarningCode('UNDEFINED_SUPER_GETTER',
          "The getter '{0}' isn't defined in a superclass of '{1}'.",
          correction:
              "Try correcting the name to the name of an existing getter, or "
              "defining a getter or field named '{0}' in a superclass.");

  /**
   * Parameters:
   * 0: the name of the method that is undefined
   * 1: the resolved type name that the method lookup is happening on
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an inherited method is
  // referenced using `super`, but there’s no method with that name in the
  // superclass chain.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `Object` doesn't define
  // a member named `n`:
  //
  // ```dart
  // class C {
  //   void m() {
  //     super.[!n!]();
  //   }
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the inherited method you intend to invoke has a different name, then
  // make the name of the invoked method  match the inherited method.
  //
  // If the method you intend to invoke is defined in the same class, then
  // remove the `super.`.
  //
  // If not, then either add the method to one of the superclasses or remove the
  // invocation.
  static const StaticTypeWarningCode UNDEFINED_SUPER_METHOD =
      StaticTypeWarningCode('UNDEFINED_SUPER_METHOD',
          "The method '{0}' isn't defined in a superclass of '{1}'.",
          correction:
              "Try correcting the name to the name of an existing method, or "
              "defining a method named '{0}' in a superclass.",
          hasPublishedDocs: true);

  /**
   * 12.18 Assignment: Evaluation of an assignment of the form
   * <i>e<sub>1</sub></i>[<i>e<sub>2</sub></i>] = <i>e<sub>3</sub></i> is
   * equivalent to the evaluation of the expression (a, i, e){a.[]=(i, e);
   * return e;} (<i>e<sub>1</sub></i>, <i>e<sub>2</sub></i>,
   * <i>e<sub>2</sub></i>).
   *
   * 12.29 Assignable Expressions: An assignable expression of the form
   * <i>e<sub>1</sub></i>[<i>e<sub>2</sub></i>] is evaluated as a method
   * invocation of the operator method [] on <i>e<sub>1</sub></i> with argument
   * <i>e<sub>2</sub></i>.
   *
   * 12.15.1 Ordinary Invocation: Let <i>T</i> be the static type of <i>o</i>.
   * It is a static type warning if <i>T</i> does not have an accessible
   * instance member named <i>m</i>.
   *
   * Parameters:
   * 0: the name of the operator
   * 1: the name of the enclosing type where the operator is being looked for
   */
  static const StaticTypeWarningCode UNDEFINED_SUPER_OPERATOR =
      StaticTypeWarningCode('UNDEFINED_SUPER_OPERATOR',
          "The operator '{0}' isn't defined in a superclass of '{1}'.",
          correction: "Try defining the operator '{0}' in a superclass.");

  /**
   * 12.18 Assignment: Let <i>T</i> be the static type of <i>e<sub>1</sub></i>.
   * It is a static type warning if <i>T</i> does not have an accessible
   * instance setter named <i>v=</i>.
   *
   * Parameters:
   * 0: the name of the setter
   * 1: the name of the enclosing type where the setter is being looked for
   */
  static const StaticTypeWarningCode UNDEFINED_SUPER_SETTER =
      StaticTypeWarningCode('UNDEFINED_SUPER_SETTER',
          "The setter '{0}' isn't defined in a superclass of '{1}'.",
          correction:
              "Try correcting the name to the name of an existing setter, or "
              "defining a setter or field named '{0}' in a superclass.");

  /**
   * 12.15.1 Ordinary Invocation: It is a static type warning if <i>T</i> does
   * not have an accessible (3.2) instance member named <i>m</i>.
   *
   * This is a specialization of [INSTANCE_ACCESS_TO_STATIC_MEMBER] that is used
   * when we are able to find the name defined in a supertype. It exists to
   * provide a more informative error message.
   *
   * Parameters:
   * 0: the name of the defining type
   */
  static const StaticTypeWarningCode
      UNQUALIFIED_REFERENCE_TO_NON_LOCAL_STATIC_MEMBER = StaticTypeWarningCode(
          'UNQUALIFIED_REFERENCE_TO_NON_LOCAL_STATIC_MEMBER',
          "Static members from supertypes must be qualified by the name of the "
              "defining type.",
          correction: "Try adding '{0}.' before the name.");

  /**
   * Parameters:
   * 0: the name of the type being referenced (<i>G</i>)
   * 1: the number of type parameters that were declared
   * 2: the number of type arguments provided
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a type that has type parameters
  // is used and type arguments are provided, but the number of type arguments
  // isn't the same as the number of type parameters.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `C` has one type
  // parameter but two type arguments are provided:
  //
  // ```dart
  // class C<E> {}
  //
  // void f([!C<int, int>!] x) {}
  // ```
  //
  // #### Common fixes
  //
  // Add or remove type arguments, as necessary, to match the number of type
  // parameters defined for the type:
  //
  // ```dart
  // class C<E> {}
  //
  // void f(C<int> x) {}
  // ```
  static const StaticTypeWarningCode WRONG_NUMBER_OF_TYPE_ARGUMENTS =
      StaticTypeWarningCode(
          'WRONG_NUMBER_OF_TYPE_ARGUMENTS',
          "The type '{0}' is declared with {1} type parameters, "
              "but {2} type arguments were given.",
          correction: "Try adjusting the number of type arguments.",
          hasPublishedDocs: true);

  /**
   * It will be a static type warning if <i>m</i> is not a generic method with
   * exactly <i>n</i> type parameters.
   *
   * Parameters:
   * 0: the name of the class being instantiated
   * 1: the name of the constructor being invoked
   */
  static const StaticTypeWarningCode
      WRONG_NUMBER_OF_TYPE_ARGUMENTS_CONSTRUCTOR = StaticTypeWarningCode(
          'WRONG_NUMBER_OF_TYPE_ARGUMENTS_CONSTRUCTOR',
          "The constructor '{0}.{1}' doesn't have type parameters.",
          correction: "Try moving type arguments to after the type name.");

  /**
   * It will be a static type warning if <i>m</i> is not a generic method with
   * exactly <i>n</i> type parameters.
   *
   * Parameters:
   * 0: the name of the method being referenced (<i>G</i>)
   * 1: the number of type parameters that were declared
   * 2: the number of type arguments provided
   */
  static const StaticTypeWarningCode WRONG_NUMBER_OF_TYPE_ARGUMENTS_METHOD =
      StaticTypeWarningCode(
          'WRONG_NUMBER_OF_TYPE_ARGUMENTS_METHOD',
          "The method '{0}' is declared with {1} type parameters, "
              "but {2} type arguments were given.",
          correction: "Try adjusting the number of type arguments.");

  /**
   * 17.16.1 Yield: Let T be the static type of e [the expression to the right
   * of "yield"] and let f be the immediately enclosing function.  It is a
   * static type warning if either:
   *
   * - the body of f is marked async* and the type Stream<T> may not be
   *   assigned to the declared return type of f.
   *
   * - the body of f is marked sync* and the type Iterable<T> may not be
   *   assigned to the declared return type of f.
   *
   * 17.16.2 Yield-Each: Let T be the static type of e [the expression to the
   * right of "yield*"] and let f be the immediately enclosing function.  It is
   * a static type warning if T may not be assigned to the declared return type
   * of f.  If f is synchronous it is a static type warning if T may not be
   * assigned to Iterable.  If f is asynchronous it is a static type warning if
   * T may not be assigned to Stream.
   */
  static const StaticTypeWarningCode YIELD_OF_INVALID_TYPE =
      StaticTypeWarningCode(
          'YIELD_OF_INVALID_TYPE',
          "The type '{0}' implied by the 'yield' expression must be assignable "
              "to '{1}'.");

  /**
   * Parameters:
   * 0: The type of the iterable expression.
   * 1: The sequence type -- Iterable for `for` or Stream for `await for`.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the expression following `in` in
  // a for-in loop has a type that isn't a subclass of `Iterable`.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `m` is a `Map`, and
  // `Map` isn't a subclass of `Iterable`:
  //
  // ```dart
  // void f(Map<String, String> m) {
  //   for (String s in [!m!]) {
  //     print(s);
  //   }
  // }
  // ```
  //
  // #### Common fixes
  //
  // Replace the expression with one that produces an iterable value:
  //
  // ```dart
  // void f(Map<String, String> m) {
  //   for (String s in m.values) {
  //     print(s);
  //   }
  // }
  // ```
  static const StaticTypeWarningCode FOR_IN_OF_INVALID_TYPE =
      StaticTypeWarningCode('FOR_IN_OF_INVALID_TYPE',
          "The type '{0}' used in the 'for' loop must implement {1}.");

  /**
   * 17.6.2 For-in. It the iterable expression does not implement Iterable with
   * a type argument that can be assigned to the for-in variable's type, this
   * warning is reported.
   *
   * Parameters:
   * 0: The type of the iterable expression.
   * 1: The sequence type -- Iterable for `for` or Stream for `await for`.
   * 2: The loop variable type.
   */
  static const StaticTypeWarningCode FOR_IN_OF_INVALID_ELEMENT_TYPE =
      StaticTypeWarningCode(
          'FOR_IN_OF_INVALID_ELEMENT_TYPE',
          "The type '{0}' used in the 'for' loop must implement {1} with a "
              "type argument that can be assigned to '{2}'.");

  /**
   * Initialize a newly created error code to have the given [name]. The message
   * associated with the error will be created from the given [message]
   * template. The correction associated with the error will be created from the
   * given [correction] template.
   */
  const StaticTypeWarningCode(String name, String message,
      {String correction,
      bool hasPublishedDocs,
      bool isUnresolvedIdentifier = false})
      : super.temporary(name, message,
            correction: correction,
            hasPublishedDocs: hasPublishedDocs,
            isUnresolvedIdentifier: isUnresolvedIdentifier);

  @override
  ErrorSeverity get errorSeverity => ErrorSeverity.ERROR;

  @override
  ErrorType get type => ErrorType.STATIC_TYPE_WARNING;
}

class StaticTypeWarningCodeWithUniqueName extends StaticTypeWarningCode {
  @override
  final String uniqueName;

  const StaticTypeWarningCodeWithUniqueName(
      String name, this.uniqueName, String message,
      {String correction, bool hasPublishedDocs})
      : super(name, message,
            correction: correction, hasPublishedDocs: hasPublishedDocs);
}

/**
 * The error codes used for static warnings. The convention for this class is
 * for the name of the error code to indicate the problem that caused the error
 * to be generated and for the error message to explain what is wrong and, when
 * appropriate, how the problem can be corrected.
 */
class StaticWarningCode extends AnalyzerErrorCode {
  /**
   * Parameters:
   * 0: the name of the ambiguous type
   * 1: the name of the first library that the type is found
   * 2: the name of the second library that the type is found
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a name is referenced that is
  // declared in two or more imported libraries.
  //
  // #### Example
  //
  // Given a library (`a.dart`) that defines a class (`C` in this example):
  //
  // ```dart
  // %uri="lib/a.dart"
  // class A {}
  // class C {}
  // ```
  //
  // And a library (`b.dart`) that defines a different class with the same name:
  //
  // ```dart
  // %uri="lib/b.dart"
  // class B {}
  // class C {}
  // ```
  //
  // The following code produces this diagnostic:
  //
  // ```dart
  // import 'a.dart';
  // import 'b.dart';
  //
  // void f([!C!] c1, [!C!] c2) {}
  // ```
  //
  // #### Common fixes
  //
  // If any of the libraries aren't needed, then remove the import directives
  // for them:
  //
  // ```dart
  // import 'a.dart';
  //
  // void f(C c1, C c2) {}
  // ```
  //
  // If the name is still defined by more than one library, then add a `hide`
  // clause to the import directives for all except one library:
  //
  // ```dart
  // import 'a.dart' hide C;
  // import 'b.dart';
  //
  // void f(C c1, C c2) {}
  // ```
  //
  // If you must be able to reference more than one of these types, then add a
  // prefix to each of the import directives, and qualify the references with
  // the appropriate prefix:
  //
  // ```dart
  // import 'a.dart' as a;
  // import 'b.dart' as b;
  //
  // void f(a.C c1, b.C c2) {}
  // ```
  static const StaticWarningCode AMBIGUOUS_IMPORT = StaticWarningCode(
      'AMBIGUOUS_IMPORT', "The name '{0}' is defined in the libraries {1}.",
      correction: "Try using 'as prefix' for one of the import directives, or "
          "hiding the name from all but one of the imports.",
      hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the actual argument type
   * 1: the name of the expected type
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the static type of an argument
  // can't be assigned to the static type of the corresponding parameter.
  //
  // #### Example
  //
  // The following code produces this diagnostic because a `num` can't be
  // assigned to a `String`:
  //
  // ```dart
  // String f(String x) => x;
  // String g(num y) => f([!y!]);
  // ```
  //
  // #### Common fixes
  //
  // If possible, rewrite the code so that the static type is assignable. In the
  // example above you might be able to change the type of the parameter `y`:
  //
  // ```dart
  // String f(String x) => x;
  // String g(String y) => f(y);
  // ```
  //
  // If that fix isn't possible, then add code to handle the case where the
  // argument value isn't the required type. One approach is to coerce other
  // types to the required type:
  //
  // ```dart
  // String f(String x) => x;
  // String g(num y) => f(y.toString());
  // ```
  //
  // Another approach is to add explicit type tests and fallback code:
  //
  // ```dart
  // String f(String x) => x;
  // String g(num y) => f(y is String ? y : '');
  // ```
  //
  // If you believe that the runtime type of the argument will always be the
  // same as the static type of the parameter, and you're willing to risk having
  // an exception thrown at runtime if you're wrong, then add an explicit cast:
  //
  // ```dart
  // String f(String x) => x;
  // String g(num y) => f(y as String);
  // ```
  static const StaticWarningCode ARGUMENT_TYPE_NOT_ASSIGNABLE =
      StaticWarningCode(
          'ARGUMENT_TYPE_NOT_ASSIGNABLE',
          "The argument type '{0}' can't be assigned to the parameter type "
              "'{1}'.",
          hasPublishedDocs: true);

  /**
   * 5 Variables: Attempting to assign to a final variable elsewhere will cause
   * a NoSuchMethodError to be thrown, because no setter is defined for it. The
   * assignment will also give rise to a static warning for the same reason.
   *
   * A constant variable is always implicitly final.
   */
  static const StaticWarningCode ASSIGNMENT_TO_CONST = StaticWarningCode(
      'ASSIGNMENT_TO_CONST', "Constant variables can't be assigned a value.",
      correction: "Try removing the assignment, or "
          "remove the modifier 'const' from the variable.");

  /**
   * Parameters:
   * 0: the name of the final variable
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it finds an invocation of a
  // setter, but there's no setter because the field with the same name was
  // declared to be `final` or `const`.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `v` is final:
  //
  // ```dart
  // class C {
  //   final v = 0;
  // }
  //
  // f(C c) {
  //   c.[!v!] = 1;
  // }
  // ```
  //
  // #### Common fixes
  //
  // If you need to be able to set the value of the field, then remove the
  // modifier `final` from the field:
  //
  // ```dart
  // class C {
  //   int v = 0;
  // }
  //
  // f(C c) {
  //   c.v = 1;
  // }
  // ```
  static const StaticWarningCode ASSIGNMENT_TO_FINAL = StaticWarningCode(
      'ASSIGNMENT_TO_FINAL',
      "'{0}' can't be used as a setter because it's final.",
      correction: "Try finding a different setter, or making '{0}' non-final.");

  /**
   * 5 Variables: Attempting to assign to a final variable elsewhere will cause
   * a NoSuchMethodError to be thrown, because no setter is defined for it. The
   * assignment will also give rise to a static warning for the same reason.
   */
  static const StaticWarningCode ASSIGNMENT_TO_FINAL_LOCAL = StaticWarningCode(
      'ASSIGNMENT_TO_FINAL_LOCAL',
      "'{0}', a final variable, can only be set once.",
      correction: "Try making '{0}' non-final.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a reference to a setter is
  // found; there is no setter defined for the type; but there is a getter
  // defined with the same name.
  //
  // #### Example
  //
  // The following code produces this diagnostic because there is no setter
  // named `x` in `C`, but there is a getter named `x`:
  //
  // ```dart
  // class C {
  //   int get x => 0;
  //   set y(int p) {}
  // }
  //
  // void f(C c) {
  //   c.[!x!] = 1;
  // }
  // ```
  //
  // #### Common fixes
  //
  // If you want to invoke an existing setter, then correct the name:
  //
  // ```dart
  // class C {
  //   int get x => 0;
  //   set y(int p) {}
  // }
  //
  // void f(C c) {
  //   c.y = 1;
  // }
  // ```
  //
  // If you want to invoke the setter but it just doesn't exist yet, then
  // declare it:
  //
  // ```dart
  // class C {
  //   int get x => 0;
  //   set x(int p) {}
  //   set y(int p) {}
  // }
  //
  // void f(C c) {
  //   c.x = 1;
  // }
  // ```
  static const StaticWarningCode ASSIGNMENT_TO_FINAL_NO_SETTER =
      StaticWarningCode('ASSIGNMENT_TO_FINAL_NO_SETTER',
          "There isn’t a setter named '{0}' in class '{1}'.",
          correction:
              "Try correcting the name to reference an existing setter, or "
              "declare the setter.",
          hasPublishedDocs: true);

  /**
   * 12.18 Assignment: It is as static warning if an assignment of the form
   * <i>v = e</i> occurs inside a top level or static function (be it function,
   * method, getter, or setter) or variable initializer and there is neither a
   * local variable declaration with name <i>v</i> nor setter declaration with
   * name <i>v=</i> in the lexical scope enclosing the assignment.
   */
  static const StaticWarningCode ASSIGNMENT_TO_FUNCTION = StaticWarningCode(
      'ASSIGNMENT_TO_FUNCTION', "Functions can't be assigned a value.");

  /**
   * 12.18 Assignment: Let <i>T</i> be the static type of <i>e<sub>1</sub></i>
   * It is a static type warning if <i>T</i> does not have an accessible
   * instance setter named <i>v=</i>.
   */
  static const StaticWarningCode ASSIGNMENT_TO_METHOD = StaticWarningCode(
      'ASSIGNMENT_TO_METHOD', "Methods can't be assigned a value.");

  /**
   * 12.18 Assignment: It is as static warning if an assignment of the form
   * <i>v = e</i> occurs inside a top level or static function (be it function,
   * method, getter, or setter) or variable initializer and there is neither a
   * local variable declaration with name <i>v</i> nor setter declaration with
   * name <i>v=</i> in the lexical scope enclosing the assignment.
   */
  static const StaticWarningCode ASSIGNMENT_TO_TYPE = StaticWarningCode(
      'ASSIGNMENT_TO_TYPE', "Types can't be assigned a value.");

  /**
   * 13.9 Switch: It is a static warning if the last statement of the statement
   * sequence <i>s<sub>k</sub></i> is not a break, continue, rethrow, return
   * or throw statement.
   */
  static const StaticWarningCode CASE_BLOCK_NOT_TERMINATED = StaticWarningCode(
      'CASE_BLOCK_NOT_TERMINATED',
      "The last statement of the 'case' should be 'break', 'continue', "
          "'rethrow', 'return' or 'throw'.",
      correction: "Try adding one of the required statements.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the name following the `as` in a
  // cast expression is defined to be something other than a type.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` is a variable, not
  // a type:
  //
  // ```dart
  // num x = 0;
  // int y = x as [!x!];
  // ```
  //
  // #### Common fixes
  //
  // Replace the name with the name of a type:
  //
  // ```dart
  // num x = 0;
  // int y = x as int;
  // ```
  static const StaticWarningCode CAST_TO_NON_TYPE = StaticWarningCode(
      'CAST_TO_NON_TYPE',
      "The name '{0}' isn't a type, so it can't be used in an 'as' expression.",
      correction: "Try changing the name to the name of an existing type, or "
          "creating a type with the name '{0}'.",
      hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the abstract method
   * 1: the name of the enclosing class
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a member of a concrete class is
  // found that doesn't have a concrete implementation. Concrete classes aren't
  // allowed to contain abstract members.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `m` is an abstract
  // method but `C` isn't an abstract class:
  //
  // ```dart
  // class C {
  //   [!void m();!]
  // }
  // ```
  //
  // #### Common fixes
  //
  // If it's valid to create instances of the class, provide an implementation
  // for the member:
  //
  // ```dart
  // class C {
  //   void m() {}
  // }
  // ```
  //
  // If it isn't valid to create instances of the class, mark the class as being
  // abstract:
  //
  // ```dart
  // abstract class C {
  //   void m();
  // }
  // ```
  static const StaticWarningCode CONCRETE_CLASS_WITH_ABSTRACT_MEMBER =
      StaticWarningCode('CONCRETE_CLASS_WITH_ABSTRACT_MEMBER',
          "'{0}' must have a method body because '{1}' isn't abstract.",
          correction: "Try making '{1}' abstract, or adding a body to '{0}'.",
          hasPublishedDocs: true);

  @Deprecated('Use StaticWarningCode.INSTANTIATE_ABSTRACT_CLASS')
  static const StaticWarningCode CONST_WITH_ABSTRACT_CLASS =
      INSTANTIATE_ABSTRACT_CLASS;

  /**
   * 14.2 Exports: It is a static warning to export two different libraries with
   * the same name.
   *
   * Parameters:
   * 0: the uri pointing to a first library
   * 1: the uri pointing to a second library
   * 2:e the shared name of the exported libraries
   */
  static const StaticWarningCode EXPORT_DUPLICATED_LIBRARY_NAMED =
      StaticWarningCode(
          'EXPORT_DUPLICATED_LIBRARY_NAMED',
          "The exported libraries '{0}' and '{1}' can't have the same name "
              "'{2}'.",
          correction:
              "Try adding a hide clause to one of the export directives.");

  @Deprecated('Use CompileTimeErrorCode.EXTRA_POSITIONAL_ARGUMENTS')
  static const CompileTimeErrorCode EXTRA_POSITIONAL_ARGUMENTS =
      CompileTimeErrorCode.EXTRA_POSITIONAL_ARGUMENTS;

  @Deprecated(
      'Use CompileTimeErrorCode.EXTRA_POSITIONAL_ARGUMENTS_COULD_BE_NAMED')
  static const CompileTimeErrorCode EXTRA_POSITIONAL_ARGUMENTS_COULD_BE_NAMED =
      CompileTimeErrorCode.EXTRA_POSITIONAL_ARGUMENTS_COULD_BE_NAMED;

  /**
   * 5. Variables: It is a static warning if a final instance variable that has
   * been initialized at its point of declaration is also initialized in a
   * constructor.
   */
  static const StaticWarningCode
      FIELD_INITIALIZED_IN_INITIALIZER_AND_DECLARATION = StaticWarningCode(
          'FIELD_INITIALIZED_IN_INITIALIZER_AND_DECLARATION',
          "Fields can't be initialized in the constructor if they are final "
              "and have already been initialized at their declaration.",
          correction: "Try removing one of the initializations.");

  /**
   * 5. Variables: It is a static warning if a final instance variable that has
   * been initialized at its point of declaration is also initialized in a
   * constructor.
   *
   * Parameters:
   * 0: the name of the field in question
   */
  static const StaticWarningCode
      FINAL_INITIALIZED_IN_DECLARATION_AND_CONSTRUCTOR = StaticWarningCode(
          'FINAL_INITIALIZED_IN_DECLARATION_AND_CONSTRUCTOR',
          "'{0}' is final and was given a value when it was declared, "
              "so it can't be set to a new value.",
          correction: "Try removing one of the initializations.");

  /**
   * 7.6.1 Generative Constructors: Execution of an initializer of the form
   * <b>this</b>.<i>v</i> = <i>e</i> proceeds as follows: First, the expression
   * <i>e</i> is evaluated to an object <i>o</i>. Then, the instance variable
   * <i>v</i> of the object denoted by this is bound to <i>o</i>.
   *
   * 12.14.2 Binding Actuals to Formals: Let <i>T<sub>i</sub></i> be the static
   * type of <i>a<sub>i</sub></i>, let <i>S<sub>i</sub></i> be the type of
   * <i>p<sub>i</sub>, 1 &lt;= i &lt;= n+k</i> and let <i>S<sub>q</sub></i> be
   * the type of the named parameter <i>q</i> of <i>f</i>. It is a static
   * warning if <i>T<sub>j</sub></i> may not be assigned to <i>S<sub>j</sub>, 1
   * &lt;= j &lt;= m</i>.
   *
   * Parameters:
   * 0: the name of the type of the initializer expression
   * 1: the name of the type of the field
   */
  static const StaticWarningCode FIELD_INITIALIZER_NOT_ASSIGNABLE =
      StaticWarningCode(
          'FIELD_INITIALIZER_NOT_ASSIGNABLE',
          "The initializer type '{0}' can't be assigned to the field type "
              "'{1}'.");

  /**
   * 7.6.1 Generative Constructors: An initializing formal has the form
   * <i>this.id</i>. It is a static warning if the static type of <i>id</i> is
   * not assignable to <i>T<sub>id</sub></i>.
   *
   * Parameters:
   * 0: the name of the type of the field formal parameter
   * 1: the name of the type of the field
   */
  static const StaticWarningCode FIELD_INITIALIZING_FORMAL_NOT_ASSIGNABLE =
      StaticWarningCode('FIELD_INITIALIZING_FORMAL_NOT_ASSIGNABLE',
          "The parameter type '{0}' is incompatible with the field type '{1}'.",
          correction: "Try changing or removing the parameter's type, or "
              "changing the field's type.");

  /**
   * Parameters:
   * 0: the name of the uninitialized final variable
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a final field or variable isn't
  // initialized.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` doesn't have an
  // initializer:
  //
  // ```dart
  // final [!x!];
  // ```
  //
  // #### Common fixes
  //
  // For variables and static fields, you can add an initializer:
  //
  // ```dart
  // final x = 0;
  // ```
  //
  // For instance fields, you can add an initializer as shown in the previous
  // example, or you can initialize the field in every constructor. You can
  // initialize the field by using a field formal parameter:
  //
  // ```dart
  // class C {
  //   final int x;
  //   C(this.x);
  // }
  // ```
  //
  // You can also initialize the field by using an initializer in the
  // constructor:
  //
  // ```dart
  // class C {
  //   final int x;
  //   C(int y) : x = y * 2;
  // }
  // ```
  static const StaticWarningCode FINAL_NOT_INITIALIZED = StaticWarningCode(
      'FINAL_NOT_INITIALIZED', "The final variable '{0}' must be initialized.",
      // TODO(brianwilkerson) Split this error code so that we can suggest
      // initializing fields in constructors (FINAL_FIELD_NOT_INITIALIZED
      // and FINAL_VARIABLE_NOT_INITIALIZED).
      correction: "Try initializing the variable.",
      hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the uninitialized final variable
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a class defines one or more
  // final instance fields without initializers and has at least one constructor
  // that doesn't initialize those fields. All final instance fields must be
  // initialized when the instance is created, either by the field's initializer
  // or by the constructor.
  //
  // #### Example
  //
  // The following code produces this diagnostic:
  //
  // ```dart
  // class C {
  //   final String value;
  //
  //   [!C!]();
  // }
  // ```
  //
  // #### Common fixes
  //
  // If the value should be passed in to the constructor directly, then use a
  // field formal parameter to initialize the field `value`:
  //
  // ```dart
  // class C {
  //   final String value;
  //
  //   C(this.value);
  // }
  // ```
  //
  // If the value should be computed indirectly from a value provided by the
  // caller, then add a parameter and include an initializer:
  //
  // ```dart
  // class C {
  //   final String value;
  //
  //   C(Object o) : value = o.toString();
  // }
  // ```
  //
  // If the value of the field doesn't depend on values that can be passed to
  // the constructor, then add an initializer for the field as part of the field
  // declaration:
  //
  // ```dart
  // class C {
  //   final String value = '';
  //
  //   C();
  // }
  // ```
  //
  // If the value of the field doesn't depend on values that can be passed to
  // the constructor but different constructors need to initialize it to
  // different values, then add an initializer for the field in the initializer
  // list:
  //
  // ```dart
  // class C {
  //   final String value;
  //
  //   C() : value = '';
  //
  //   C.named() : value = 'c';
  // }
  // ```
  //
  // However, if the value is the same for all instances, then consider using a
  // static field instead of an instance field:
  //
  // ```dart
  // class C {
  //   static const String value = '';
  //
  //   C();
  // }
  // ```
  static const StaticWarningCode FINAL_NOT_INITIALIZED_CONSTRUCTOR_1 =
      StaticWarningCodeWithUniqueName(
          'FINAL_NOT_INITIALIZED_CONSTRUCTOR',
          'StaticWarningCode.FINAL_NOT_INITIALIZED_CONSTRUCTOR_1',
          "All final variables must be initialized, but '{0}' is not.",
          correction: "Try adding an initializer for the field.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the uninitialized final variable
   * 1: the name of the uninitialized final variable
   */
  static const StaticWarningCode FINAL_NOT_INITIALIZED_CONSTRUCTOR_2 =
      StaticWarningCodeWithUniqueName(
          'FINAL_NOT_INITIALIZED_CONSTRUCTOR',
          'StaticWarningCode.FINAL_NOT_INITIALIZED_CONSTRUCTOR_2',
          "All final variables must be initialized, but '{0}' and '{1}' are "
              "not.",
          correction: "Try adding initializers for the fields.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the uninitialized final variable
   * 1: the name of the uninitialized final variable
   * 2: the number of additional not initialized variables that aren't listed
   */
  static const StaticWarningCode FINAL_NOT_INITIALIZED_CONSTRUCTOR_3_PLUS =
      StaticWarningCodeWithUniqueName(
          'FINAL_NOT_INITIALIZED_CONSTRUCTOR',
          'StaticWarningCode.FINAL_NOT_INITIALIZED_CONSTRUCTOR_3',
          "All final variables must be initialized, but '{0}', '{1}', and {2} "
              "others are not.",
          correction: "Try adding initializers for the fields.",
          hasPublishedDocs: true);

  /**
   * 14.1 Imports: It is a static warning to import two different libraries with
   * the same name.
   *
   * Parameters:
   * 0: the uri pointing to a first library
   * 1: the uri pointing to a second library
   * 2: the shared name of the imported libraries
   */
  static const StaticWarningCode IMPORT_DUPLICATED_LIBRARY_NAMED =
      StaticWarningCode(
          'IMPORT_DUPLICATED_LIBRARY_NAMED',
          "The imported libraries '{0}' and '{1}' can't have the same name "
              "'{2}'.",
          correction: "Try adding a hide clause to one of the imports.");

  @Deprecated('Use CompileTimeErrorCode.IMPORT_OF_NON_LIBRARY')
  static const CompileTimeErrorCode IMPORT_OF_NON_LIBRARY =
      CompileTimeErrorCode.IMPORT_OF_NON_LIBRARY;

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it finds a constructor
  // invocation and the constructor is declared in an abstract class. Even
  // though you can't create an instance of an abstract class, abstract classes
  // can declare constructors that can be invoked by subclasses.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `C` is an abstract
  // class:
  //
  // ```dart
  // abstract class C {}
  //
  // var c = new [!C!]();
  // ```
  //
  // #### Common fixes
  //
  // If there's a concrete subclass of the abstract class that can be used, then
  // create an instance of the concrete subclass.
  static const StaticWarningCode INSTANTIATE_ABSTRACT_CLASS = StaticWarningCode(
      'INSTANTIATE_ABSTRACT_CLASS', "Abstract classes can't be instantiated.",
      correction: "Try creating an instance of a concrete subtype.");

  /**
   * 7.1 Instance Methods: It is a static warning if an instance method
   * <i>m1</i> overrides an instance member <i>m2</i>, the signature of
   * <i>m2</i> explicitly specifies a default value for a formal parameter
   * <i>p</i> and the signature of <i>m1</i> specifies a different default value
   * for <i>p</i>.
   */
  static const StaticWarningCode
      INVALID_OVERRIDE_DIFFERENT_DEFAULT_VALUES_NAMED = StaticWarningCode(
          'INVALID_OVERRIDE_DIFFERENT_DEFAULT_VALUES_NAMED',
          "Parameters can't override default values, this method overrides "
              "'{0}.{1}' where '{2}' has a different value.",
          correction: "Try using the same default value in both methods.",
          errorSeverity: ErrorSeverity.WARNING);

  /**
   * 7.1 Instance Methods: It is a static warning if an instance method
   * <i>m1</i> overrides an instance member <i>m2</i>, the signature of
   * <i>m2</i> explicitly specifies a default value for a formal parameter
   * <i>p</i> and the signature of <i>m1</i> specifies a different default value
   * for <i>p</i>.
   */
  static const StaticWarningCode
      INVALID_OVERRIDE_DIFFERENT_DEFAULT_VALUES_POSITIONAL = StaticWarningCode(
          'INVALID_OVERRIDE_DIFFERENT_DEFAULT_VALUES_POSITIONAL',
          "Parameters can't override default values, this method overrides "
              "'{0}.{1}' where this positional parameter has a different "
              "value.",
          correction: "Try using the same default value in both methods.",
          errorSeverity: ErrorSeverity.WARNING);

  /**
   * Parameters:
   * 0: the actual type of the list element
   * 1: the expected type of the list element
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the type of an element in a list
  // literal isn't assignable to the element type of the list.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `2.5` is a double, and
  // the list can hold only integers:
  //
  // ```dart
  // List<int> x = [1, [!2.5!], 3];
  // ```
  //
  // #### Common fixes
  //
  // If you intended to add a different object to the list, then replace the
  // element with an expression that computes the intended object:
  //
  // ```dart
  // List<int> x = [1, 2, 3];
  // ```
  //
  // If the object shouldn't be in the list, then remove the element:
  //
  // ```dart
  // List<int> x = [1, 3];
  // ```
  //
  // If the object being computed is correct, then widen the element type of the
  // list to allow all of the different types of objects it needs to contain:
  //
  // ```dart
  // List<num> x = [1, 2.5, 3];
  // ```
  static const StaticWarningCode LIST_ELEMENT_TYPE_NOT_ASSIGNABLE =
      StaticWarningCode('LIST_ELEMENT_TYPE_NOT_ASSIGNABLE',
          "The element type '{0}' can't be assigned to the list type '{1}'.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the type of the expression being used as a key
   * 1: the type of keys declared for the map
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a key of a key-value pair in a
  // map literal has a type that isn't assignable to the key type of the map.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `2` is an `int`, but
  // the keys of the map are required to be `String`s:
  //
  // ```dart
  // var m = <String, String>{[!2!] : 'a'};
  // ```
  //
  // #### Common fixes
  //
  // If the type of the map is correct, then change the key to have the correct
  // type:
  //
  // ```dart
  // var m = <String, String>{'2' : 'a'};
  // ```
  //
  // If the type of the key is correct, then change the key type of the map:
  //
  // ```dart
  // var m = <int, String>{2 : 'a'};
  // ```
  static const StaticWarningCode MAP_KEY_TYPE_NOT_ASSIGNABLE =
      StaticWarningCode(
          'MAP_KEY_TYPE_NOT_ASSIGNABLE',
          "The element type '{0}' can't be assigned to the map key type "
              "'{1}'.");

  /**
   * Parameters:
   * 0: the type of the expression being used as a value
   * 1: the type of values declared for the map
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a value of a key-value pair in a
  // map literal has a type that isn't assignable to the the value type of the
  // map.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `2` is an `int`, but/
  // the values of the map are required to be `String`s:
  //
  // ```dart
  // var m = <String, String>{'a' : [!2!]};
  // ```
  //
  // #### Common fixes
  //
  // If the type of the map is correct, then change the value to have the
  // correct type:
  //
  // ```dart
  // var m = <String, String>{'a' : '2'};
  // ```
  //
  // If the type of the value is correct, then change the value type of the map:
  //
  // ```dart
  // var m = <String, int>{'a' : 2};
  // ```
  static const StaticWarningCode MAP_VALUE_TYPE_NOT_ASSIGNABLE =
      StaticWarningCode(
          'MAP_VALUE_TYPE_NOT_ASSIGNABLE',
          "The element type '{0}' can't be assigned to the map value type "
              "'{1}'.");

  /**
   * 10.3 Setters: It is a compile-time error if a class has a setter named
   * `v=` with argument type `T` and a getter named `v` with return type `S`,
   * and `S` may not be assigned to `T`.
   *
   * Parameters:
   * 0: the name of the getter
   * 1: the type of the getter
   * 2: the type of the setter
   * 3: the name of the setter
   */
  static const StaticWarningCode MISMATCHED_GETTER_AND_SETTER_TYPES =
      StaticWarningCode(
          'MISMATCHED_GETTER_AND_SETTER_TYPES',
          "The return type of getter '{0}' is '{1}' which isn't assignable "
              "to the type '{2}' of its setter '{3}'.",
          correction: "Try changing the types so that they are compatible.");

  /**
   * Parameters:
   * 0: the name of the constant that is missing
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a switch statement for an enum
  // doesn't include an option for one of the values in the enumeration.
  //
  // Note that `null` is always a possible value for an enum and therefore also
  // must be handled.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the enum constant `e2`
  // isn't handled:
  //
  // ```dart
  // enum E { e1, e2 }
  //
  // void f(E e) {
  //   [!switch (e)!] {
  //     case E.e1:
  //       break;
  //   }
  // }
  // ```
  //
  // #### Common fixes
  //
  // If there's special handling for the missing values, then add a case clause
  // for each of the missing values:
  //
  // ```dart
  // enum E { e1, e2 }
  //
  // void f(E e) {
  //   switch (e) {
  //     case E.e1:
  //       break;
  //     case E.e2:
  //       break;
  //   }
  // }
  // ```
  //
  // If the missing values should be handled the same way, then add a default
  // clause:
  //
  // ```dart
  // enum E { e1, e2 }
  //
  // void f(E e) {
  //   switch (e) {
  //     case E.e1:
  //       break;
  //     default:
  //       break;
  //   }
  // }
  // ```
  // TODO(brianwilkerson) This documentation will need to be updated when NNBD
  //  ships.
  static const StaticWarningCode MISSING_ENUM_CONSTANT_IN_SWITCH =
      StaticWarningCode(
          'MISSING_ENUM_CONSTANT_IN_SWITCH', "Missing case clause for '{0}'.",
          correction: "Try adding a case clause for the missing constant, or "
              "adding a default clause.");

  @Deprecated('No longer an error in the spec and no longer generated')
  static const StaticWarningCode MIXED_RETURN_TYPES = StaticWarningCode(
      'MIXED_RETURN_TYPES',
      "Functions can't include return statements both with and without values.",
      correction: "Try making all the return statements consistent "
          "(either include a value or not).");

  @Deprecated('Use StaticWarningCode.INSTANTIATE_ABSTRACT_CLASS')
  static const StaticWarningCode NEW_WITH_ABSTRACT_CLASS =
      INSTANTIATE_ABSTRACT_CLASS;

  /**
   * Parameters:
   * 0: the name of the type being referenced (<i>S</i>)
   * 1: the number of type parameters that were declared
   * 2: the number of type arguments provided
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a constructor is invoked and the
  // number of type arguments doesn't match the number of type parameters
  // declared for the class.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `C` declares one type
  // parameter, but two type arguments are given:
  //
  // ```dart
  // class C<E> {}
  //
  // var c = [!C<int, int>!]();
  // ```
  //
  // #### Common fixes
  //
  // Change the number of type arguments to match the number of type parameters
  // declared for the class:
  //
  // ```dart
  // class C<E> {}
  //
  // var c = C<int>();
  // ```
  static const StaticWarningCode NEW_WITH_INVALID_TYPE_PARAMETERS =
      StaticWarningCode(
          'NEW_WITH_INVALID_TYPE_PARAMETERS',
          "The type '{0}' is declared with {1} type arguments, but {2} type "
              "arguments were given.",
          correction: "Try adjusting the number of type arguments.");

  /**
   * 12.11.1 New: It is a static warning if <i>T</i> is not a class accessible
   * in the current scope, optionally followed by type arguments.
   *
   * Parameters:
   * 0: the name of the non-type element
   */
  static const StaticWarningCode NEW_WITH_NON_TYPE = StaticWarningCode(
      'NEW_WITH_NON_TYPE', "The name '{0}' isn't a class.",
      correction: "Try correcting the name to match an existing class.");

  /**
   * 12.11.1 New: If <i>T</i> is a class or parameterized type accessible in the
   * current scope then:
   * 1. If <i>e</i> is of the form <i>new T.id(a<sub>1</sub>, &hellip;,
   *    a<sub>n</sub>, x<sub>n+1</sub>: a<sub>n+1</sub>, &hellip;,
   *    x<sub>n+k</sub>: a<sub>n+k</sub>)</i> it is a static warning if
   *    <i>T.id</i> is not the name of a constructor declared by the type
   *    <i>T</i>.
   * If <i>e</i> of the form <i>new T(a<sub>1</sub>, &hellip;, a<sub>n</sub>,
   * x<sub>n+1</sub>: a<sub>n+1</sub>, &hellip;, x<sub>n+k</sub>:
   * a<sub>n+kM/sub>)</i> it is a static warning if the type <i>T</i> does not
   * declare a constructor with the same name as the declaration of <i>T</i>.
   */
  static const StaticWarningCode NEW_WITH_UNDEFINED_CONSTRUCTOR =
      StaticWarningCode('NEW_WITH_UNDEFINED_CONSTRUCTOR',
          "The class '{0}' doesn't have a constructor named '{1}'.",
          correction: "Try invoking a different constructor, or "
              "define a constructor named '{1}'.");

  /**
   * Parameters:
   * 0: the name of the class being instantiated
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when an unnamed constructor is
  // invoked on a class that defines named constructors but the class doesn’t
  // have an unnamed constructor.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `A` doesn't define an
  // unnamed constructor:
  //
  // ```dart
  // class A {
  //   A.a();
  // }
  //
  // A f() => [!A!]();
  // ```
  //
  // #### Common fixes
  //
  // If one of the named constructors does what you need, then use it:
  //
  // ```dart
  // class A {
  //   A.a();
  // }
  //
  // A f() => A.a();
  // ```
  //
  // If none of the named constructors does what you need, and you're able to
  // add an unnamed constructor, then add the constructor:
  //
  // ```dart
  // class A {
  //   A();
  //   A.a();
  // }
  //
  // A f() => A();
  // ```
  static const StaticWarningCode NEW_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT =
      StaticWarningCode('NEW_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT',
          "The class '{0}' doesn't have a default constructor.",
          correction:
              "Try using one of the named constructors defined in '{0}'.");

  /**
   * Parameters:
   * 0: the name of the first member
   * 1: the name of the second member
   * 2: the name of the third member
   * 3: the name of the fourth member
   * 4: the number of additional missing members that aren't listed
   */
  static const StaticWarningCode
      NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER_FIVE_PLUS =
      StaticWarningCodeWithUniqueName(
          'NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER',
          'StaticWarningCode.NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER_FIVE_PLUS',
          "Missing concrete implementations of '{0}', '{1}', '{2}', '{3}', and "
              "{4} more.",
          correction: "Try implementing the missing methods, or make the class "
              "abstract.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the first member
   * 1: the name of the second member
   * 2: the name of the third member
   * 3: the name of the fourth member
   */
  static const StaticWarningCode
      NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER_FOUR =
      StaticWarningCodeWithUniqueName(
          'NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER',
          'StaticWarningCode.NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER_FOUR',
          "Missing concrete implementations of '{0}', '{1}', '{2}', and '{3}'.",
          correction: "Try implementing the missing methods, or make the class "
              "abstract.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the member
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a concrete class inherits one or
  // more abstract members, and doesn't provide or inherit an implementation for
  // at least one of those abstract members.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the class `B` doesn't
  // have a concrete implementation of `m`:
  //
  // ```dart
  // abstract class A {
  //   void m();
  // }
  //
  // class [!B!] extends A {}
  // ```
  //
  // #### Common fixes
  //
  // If the subclass can provide a concrete implementation for some or all of
  // the abstract inherited members, then add the concrete implementations:
  //
  // ```dart
  // abstract class A {
  //   void m();
  // }
  //
  // class B extends A {
  //   void m() {}
  // }
  // ```
  //
  // If there is a mixin that provides an implementation of the inherited
  // methods, then apply the mixin to the subclass:
  //
  // ```dart
  // abstract class A {
  //   void m();
  // }
  //
  // class B extends A with M {}
  //
  // mixin M {
  //   void m() {}
  // }
  // ```
  //
  // If the subclass can't provide a concrete implementation for all of the
  // abstract inherited members, then mark the subclass as being abstract:
  //
  // ```dart
  // abstract class A {
  //   void m();
  // }
  //
  // abstract class B extends A {}
  // ```
  static const StaticWarningCode
      NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER_ONE =
      StaticWarningCodeWithUniqueName(
          'NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER',
          'StaticWarningCode.NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER_ONE',
          "Missing concrete implementation of '{0}'.",
          correction: "Try implementing the missing method, or make the class "
              "abstract.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the first member
   * 1: the name of the second member
   * 2: the name of the third member
   */
  static const StaticWarningCode
      NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER_THREE =
      StaticWarningCodeWithUniqueName(
          'NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER',
          'StaticWarningCode.NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER_THREE',
          "Missing concrete implementations of '{0}', '{1}', and '{2}'.",
          correction: "Try implementing the missing methods, or make the class "
              "abstract.",
          hasPublishedDocs: true);

  /**
   * Parameters:
   * 0: the name of the first member
   * 1: the name of the second member
   */
  static const StaticWarningCode
      NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER_TWO =
      StaticWarningCodeWithUniqueName(
          'NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER',
          'StaticWarningCode.NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER_TWO',
          "Missing concrete implementations of '{0}' and '{1}'.",
          correction: "Try implementing the missing methods, or make the class "
              "abstract.",
          hasPublishedDocs: true);

  /**
   * 13.11 Try: An on-catch clause of the form <i>on T catch (p<sub>1</sub>,
   * p<sub>2</sub>) s</i> or <i>on T s</i> matches an object <i>o</i> if the
   * type of <i>o</i> is a subtype of <i>T</i>. It is a static warning if
   * <i>T</i> does not denote a type available in the lexical scope of the
   * catch clause.
   *
   * Parameters:
   * 0: the name of the non-type element
   */
  static const StaticWarningCode NON_TYPE_IN_CATCH_CLAUSE = StaticWarningCode(
      'NON_TYPE_IN_CATCH_CLAUSE',
      "The name '{0}' isn't a type and can't be used in an on-catch "
          "clause.",
      correction: "Try correcting the name to match an existing class.");

  /**
   * 7.1.1 Operators: It is a static warning if the return type of the
   * user-declared operator []= is explicitly declared and not void.
   */
  static const StaticWarningCode NON_VOID_RETURN_FOR_OPERATOR =
      StaticWarningCode('NON_VOID_RETURN_FOR_OPERATOR',
          "The return type of the operator []= must be 'void'.",
          correction: "Try changing the return type to 'void'.");

  /**
   * 7.3 Setters: It is a static warning if a setter declares a return type
   * other than void.
   */
  static const StaticWarningCode NON_VOID_RETURN_FOR_SETTER = StaticWarningCode(
      'NON_VOID_RETURN_FOR_SETTER',
      "The return type of the setter must be 'void' or absent.",
      correction: "Try removing the return type, or "
          "define a method rather than a setter.");

  /**
   * Parameters:
   * 0: the name that is not a type
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a name is used as a type but
  // declared to be something other than a type.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `f` is a function:
  //
  // ```dart
  // f() {}
  // g([!f!] v) {}
  // ```
  //
  // #### Common fixes
  //
  // Replace the name with the name of a type.
  static const StaticWarningCode NOT_A_TYPE = StaticWarningCode(
      'NOT_A_TYPE', "{0} isn't a type.",
      correction: "Try correcting the name to match an existing type.",
      hasPublishedDocs: true);

  @Deprecated('Use CompileTimeErrorCode.NOT_ENOUGH_POSITIONAL_ARGUMENTS')
  static const CompileTimeErrorCode NOT_ENOUGH_REQUIRED_ARGUMENTS =
      CompileTimeErrorCode.NOT_ENOUGH_POSITIONAL_ARGUMENTS;

  /**
   * 14.3 Parts: It is a static warning if the referenced part declaration
   * <i>p</i> names a library other than the current library as the library to
   * which <i>p</i> belongs.
   *
   * Parameters:
   * 0: the name of expected library name
   * 1: the non-matching actual library name from the "part of" declaration
   */
  static const StaticWarningCode PART_OF_DIFFERENT_LIBRARY = StaticWarningCode(
      'PART_OF_DIFFERENT_LIBRARY',
      "Expected this library to be part of '{0}', not '{1}'.",
      correction: "Try including a different part, or changing the name of "
          "the library in the part's part-of directive.");

  /**
   * 7.6.2 Factories: It is a static warning if the function type of <i>k'</i>
   * is not a subtype of the type of <i>k</i>.
   *
   * Parameters:
   * 0: the name of the redirected constructor
   * 1: the name of the redirecting constructor
   */
  static const StaticWarningCode REDIRECT_TO_INVALID_FUNCTION_TYPE =
      StaticWarningCode(
          'REDIRECT_TO_INVALID_FUNCTION_TYPE',
          "The redirected constructor '{0}' has incompatible parameters with "
              "'{1}'.",
          correction: "Try redirecting to a different constructor, or directly "
              "invoking the desired constructor rather than redirecting to "
              "it.");

  /**
   * 7.6.2 Factories: It is a static warning if the function type of <i>k'</i>
   * is not a subtype of the type of <i>k</i>.
   *
   * Parameters:
   * 0: the name of the redirected constructor's return type
   * 1: the name of the redirecting constructor's return type
   */
  static const StaticWarningCode REDIRECT_TO_INVALID_RETURN_TYPE =
      StaticWarningCode(
          'REDIRECT_TO_INVALID_RETURN_TYPE',
          "The return type '{0}' of the redirected constructor isn't "
              "assignable to '{1}'.",
          correction: "Try redirecting to a different constructor, or directly "
              "invoking the desired constructor rather than redirecting to "
              "it.");

  @Deprecated('Use CompileTimeErrorCode.REDIRECT_TO_MISSING_CONSTRUCTOR')
  static const CompileTimeErrorCode REDIRECT_TO_MISSING_CONSTRUCTOR =
      CompileTimeErrorCode.REDIRECT_TO_MISSING_CONSTRUCTOR;

  @Deprecated('Use CompileTimeErrorCode.REDIRECT_TO_NON_CLASS')
  static const CompileTimeErrorCode REDIRECT_TO_NON_CLASS =
      CompileTimeErrorCode.REDIRECT_TO_NON_CLASS;

  /**
   * 13.12 Return: Let <i>f</i> be the function immediately enclosing a return
   * statement of the form <i>return;</i> It is a static warning if both of the
   * following conditions hold:
   * * <i>f</i> is not a generative constructor.
   * * The return type of <i>f</i> may not be assigned to void.
   */
  static const StaticWarningCode RETURN_WITHOUT_VALUE = StaticWarningCode(
      'RETURN_WITHOUT_VALUE', "Missing return value after 'return'.");

  /**
   * Parameters:
   * 0: the actual type of the set element
   * 1: the expected type of the set element
   */
  static const StaticWarningCode SET_ELEMENT_TYPE_NOT_ASSIGNABLE =
      StaticWarningCode('SET_ELEMENT_TYPE_NOT_ASSIGNABLE',
          "The element type '{0}' can't be assigned to the set type '{1}'.");

  /**
   * Parameters:
   * 0: the name of the instance member
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when a class name is used to access
  // an instance field. Instance fields don't exist on a class; they exist only
  // on an instance of the class.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `x` is an instance
  // field:
  //
  // ```dart
  // class C {
  //   static int a;
  //
  //   int b;
  // }
  //
  // int f() => C.[!b!];
  // ```
  //
  // #### Common fixes
  //
  // If you intend to access a static field, then change the name of the field
  // to an existing static field:
  //
  // ```dart
  // class C {
  //   static int a;
  //
  //   int b;
  // }
  //
  // int f() => C.a;
  // ```
  //
  // If you intend to access the instance field, then use an instance of the
  // class to access the field:
  //
  // ```dart
  // class C {
  //   static int a;
  //
  //   int b;
  // }
  //
  // int f(C c) => c.b;
  // ```
  static const StaticWarningCode STATIC_ACCESS_TO_INSTANCE_MEMBER =
      StaticWarningCode('STATIC_ACCESS_TO_INSTANCE_MEMBER',
          "Instance member '{0}' can't be accessed using static access.");

  /**
   * 13.9 Switch: It is a static warning if the type of <i>e</i> may not be
   * assigned to the type of <i>e<sub>k</sub></i>.
   */
  static const StaticWarningCode SWITCH_EXPRESSION_NOT_ASSIGNABLE =
      StaticWarningCode(
          'SWITCH_EXPRESSION_NOT_ASSIGNABLE',
          "Type '{0}' of the switch expression isn't assignable to "
              "the type '{1}' of case expressions.");

  /**
   * 15.1 Static Types: It is a static warning to use a deferred type in a type
   * annotation.
   *
   * Parameters:
   * 0: the name of the type that is deferred and being used in a type
   *    annotation
   */
  static const StaticWarningCode TYPE_ANNOTATION_DEFERRED_CLASS =
      StaticWarningCode(
          'TYPE_ANNOTATION_DEFERRED_CLASS',
          "The deferred type '{0}' can't be used in a declaration, cast or "
              "type test.",
          correction: "Try using a different type, or "
              "changing the import to not be deferred.");

  /**
   * 12.31 Type Test: It is a static warning if <i>T</i> does not denote a type
   * available in the current lexical scope.
   */
  static const StaticWarningCode TYPE_TEST_WITH_NON_TYPE = StaticWarningCode(
      'TYPE_TEST_WITH_NON_TYPE',
      "The name '{0}' isn't a type and can't be used in an 'is' "
          "expression.",
      correction: "Try correcting the name to match an existing type.");

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when the name following the `is` in a
  // type test expression isn't defined.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the name `Srting` isn't
  // defined:
  //
  // ```dart
  // void f(Object o) {
  //   if (o is [!Srting!]) {
  //     // ...
  //   }
  // }
  // ```
  //
  // #### Common fixes
  //
  // Replace the name with the name of a type:
  //
  // ```dart
  // void f(Object o) {
  //   if (o is String) {
  //     // ...
  //   }
  // }
  // ```
  static const StaticWarningCode TYPE_TEST_WITH_UNDEFINED_NAME =
      StaticWarningCode(
          'TYPE_TEST_WITH_UNDEFINED_NAME',
          "The name '{0}' isn't defined, so it can't be used in an 'is' "
              "expression.",
          correction:
              "Try changing the name to the name of an existing type, or "
              "creating a type with the name '{0}'.",
          hasPublishedDocs: true);

  /**
   * 10 Generics: However, a type parameter is considered to be a malformed type
   * when referenced by a static member.
   *
   * 15.1 Static Types: Any use of a malformed type gives rise to a static
   * warning. A malformed type is then interpreted as dynamic by the static type
   * checker and the runtime.
   */
  static const StaticWarningCode TYPE_PARAMETER_REFERENCED_BY_STATIC =
      StaticWarningCode('TYPE_PARAMETER_REFERENCED_BY_STATIC',
          "Static members can't reference type parameters of the class.",
          correction: "Try removing the reference to the type parameter, or "
              "making the member an instance member.");

  @Deprecated('Use CompileTimeErrorCode.UNDEFINED_CLASS')
  static const CompileTimeErrorCode UNDEFINED_CLASS =
      CompileTimeErrorCode.UNDEFINED_CLASS;

  /**
   * Same as [CompileTimeErrorCode.UNDEFINED_CLASS], but to catch using
   * "boolean" instead of "bool".
   */
  static const StaticWarningCode UNDEFINED_CLASS_BOOLEAN = StaticWarningCode(
      'UNDEFINED_CLASS_BOOLEAN', "Undefined class 'boolean'.",
      correction: "Try using the type 'bool'.");

  /**
   * Parameters:
   * 0: the name of the identifier
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it encounters an identifier that
  // either isn't defined or isn't visible in the scope in which it's being
  // referenced.
  //
  // #### Example
  //
  // The following code produces this diagnostic because the name `rihgt` isn't
  // defined:
  //
  // ```dart
  // int min(int left, int right) => left <= [!rihgt!] ? left : right;
  // ```
  //
  // #### Common fixes
  //
  // If the identifier isn't defined, then either define it or replace it with
  // an identifier that is defined. The example above can be corrected by
  // fixing the spelling of the variable:
  //
  // ```dart
  // int min(int left, int right) => left <= right ? left : right;
  // ```
  //
  // If the identifier is defined but isn't visible, then you probably need to
  // add an import or re-arrange your code to make the identifier visible.
  static const StaticWarningCode UNDEFINED_IDENTIFIER =
      StaticWarningCode('UNDEFINED_IDENTIFIER', "Undefined name '{0}'.",
          correction: "Try correcting the name to one that is defined, or "
              "defining the name.",
          hasPublishedDocs: true,
          isUnresolvedIdentifier: true);

  /**
   * If the identifier is 'await', be helpful about it.
   */
  static const StaticWarningCode UNDEFINED_IDENTIFIER_AWAIT = StaticWarningCode(
      'UNDEFINED_IDENTIFIER_AWAIT',
      "Undefined name 'await' in function body not marked with 'async'.",
      correction: "Try correcting the name to one that is defined, "
          "defining the name, or "
          "adding 'async' to the enclosing function body.");

  @Deprecated('Use CompileTimeErrorCode.UNDEFINED_NAMED_PARAMETER')
  static const CompileTimeErrorCode UNDEFINED_NAMED_PARAMETER =
      CompileTimeErrorCode.UNDEFINED_NAMED_PARAMETER;

  /**
   * For the purposes of experimenting with potential non-null type semantics.
   *
   * Parameters: none
   */
  static const StaticWarningCode UNCHECKED_USE_OF_NULLABLE_VALUE =
      StaticWarningCode(
          'UNCHECKED_USE_OF_NULLABLE_VALUE',
          "The expression is nullable and must be null-checked before it can "
              "be used.",
          correction:
              "Try checking that the value isn't null before using it.");

  /**
   * When the '!' operator is used on a value that we know to be non-null,
   * it is unnecessary.
   */
  static const StaticWarningCode UNNECESSARY_NON_NULL_ASSERTION =
      StaticWarningCode(
          'UNNECESSARY_NON_NULL_ASSERTION',
          "The '!' will have no effect because the target expression cannot be"
              " null.",
          correction: "Try removing the '!' operator here.",
          errorSeverity: ErrorSeverity.WARNING);

  /**
   * When the '...?' operator is used on a value that we know to be non-null,
   * it is unnecessary.
   */
  static const StaticWarningCode UNNECESSARY_NULL_AWARE_SPREAD =
      StaticWarningCode(
          'UNNECESSARY_NULL_AWARE_SPREAD',
          "The target expression can't be null, so it isn't necessary to use "
              "the null-aware spread operator '...?'.",
          correction: "Try replacing the '...?' with a '...' in the spread.",
          errorSeverity: ErrorSeverity.WARNING);

  /**
   * For the purposes of experimenting with potential non-null type semantics.
   *
   * Whereas [UNCHECKED_USE_OF_NULLABLE] refers to using a value of type T? as
   * if it were a T, this refers to using a value of type [Null] itself. These
   * occur at many of the same times ([Null] is a potentially nullable type) but
   * it indicates a different type of programmer error and has different
   * corrections.
   *
   * Parameters: none
   */
  static const StaticWarningCode INVALID_USE_OF_NULL_VALUE = StaticWarningCode(
      'INVALID_USE_OF_NULL_VALUE',
      "This expression is invalid as it will always be null.",
      correction:
          "Try changing the type, or casting, to a more useful type like "
          "dynamic.");

  /**
   * It is an error to call a method or getter on an expression of type `Never`,
   * or to invoke it as if it were a function.
   *
   * Go out of our way to provide a *little* more information here because many
   * dart users probably have never heard of the type Never. Be careful however
   * of providing too much information or it only becomes more confusing. Hard
   * balance to strike.
   *
   * Parameters: none
   */
  static const StaticWarningCode INVALID_USE_OF_NEVER_VALUE = StaticWarningCode(
      'INVALID_USE_OF_NEVER_VALUE',
      'This expression is invalid because its target is of type Never and'
          ' will never complete with a value',
      correction: 'Try checking for throw expressions or type errors in the'
          ' target expression');

  /**
   * When the '?.' operator is used on a target that we know to be non-null,
   * it is unnecessary.
   */
  static const StaticWarningCode UNNECESSARY_NULL_AWARE_CALL =
      StaticWarningCode('UNNECESSARY_NULL_AWARE_CALL',
          "The target expression can't be null, and so '?.' isn't necessary.",
          correction: "Try replacing the '?.' with a '.' in the invocation.",
          errorSeverity: ErrorSeverity.WARNING);

  /**
   * No parameters.
   */
  // #### Description
  //
  // The analyzer produces this diagnostic when it finds an expression whose
  // type is `void`, and the expression is used in a place where a value is
  // expected, such as before a member access or on the right-hand side of an
  // assignment.
  //
  // #### Example
  //
  // The following code produces this diagnostic because `f` doesn't produce an
  // object on which `toString` can be invoked:
  //
  // ```dart
  // void f() {}
  //
  // void g() {
  //   [!f()!].toString();
  // }
  // ```
  //
  // #### Common fixes
  //
  // Either rewrite the code so that the expression has a value or rewrite the
  // code so that it doesn't depend on the value.
  static const StaticWarningCode USE_OF_VOID_RESULT = StaticWarningCode(
      'USE_OF_VOID_RESULT',
      "This expression has a type of 'void' so its value can't be used.",
      correction:
          "Try checking to see if you're using the correct API; there might "
          "be a function or call that returns void you didn't expect. Also "
          "check type parameters and variables which might also be void.");

  @override
  final ErrorSeverity errorSeverity;

  /**
   * Initialize a newly created error code to have the given [name]. The message
   * associated with the error will be created from the given [message]
   * template. The correction associated with the error will be created from the
   * given [correction] template.
   */
  const StaticWarningCode(String name, String message,
      {String correction,
      this.errorSeverity = ErrorSeverity.ERROR,
      bool hasPublishedDocs,
      bool isUnresolvedIdentifier = false})
      : super.temporary(name, message,
            correction: correction,
            hasPublishedDocs: hasPublishedDocs,
            isUnresolvedIdentifier: isUnresolvedIdentifier);

  @override
  ErrorType get type => ErrorType.STATIC_WARNING;
}

class StaticWarningCodeWithUniqueName extends StaticWarningCode {
  @override
  final String uniqueName;

  const StaticWarningCodeWithUniqueName(
      String name, this.uniqueName, String message,
      {String correction, bool hasPublishedDocs})
      : super(name, message,
            correction: correction, hasPublishedDocs: hasPublishedDocs);
}

/**
 * This class has Strong Mode specific error codes.
 *
 * "Strong Mode" was the prototype for Dart 2's sound type system. Many of these
 * errors became part of Dart 2. Some of them are optional flags, used for
 * stricter checking.
 *
 * These error codes tend to use the same message across different severity
 * levels, so they are grouped for clarity.
 */
class StrongModeCode extends ErrorCode {
  static const String _implicitCastMessage =
      "Unsafe implicit cast from '{0}' to '{1}'. "
      "This usually indicates that type information was lost and resulted in "
      "'dynamic' and/or a place that will have a failure at runtime.";

  static const String _implicitCastCorrection =
      "Try adding an explicit cast to '{1}' or improving the type of '{0}'.";

  /**
   * This is appended to the end of an error message about implicit dynamic.
   *
   * The idea is to make sure the user is aware that this error message is the
   * result of turning on a particular option, and they are free to turn it
   * back off.
   */
  static const String _implicitDynamicCorrection =
      "Try adding an explicit type like 'dynamic', or "
      "enable implicit-dynamic in your analysis options file.";

  static const String _inferredTypeMessage = "'{0}' has inferred type '{1}'.";

  static const StrongModeCode DOWN_CAST_COMPOSITE = StrongModeCode(
      ErrorType.HINT, 'DOWN_CAST_COMPOSITE', _implicitCastMessage,
      correction: _implicitCastCorrection);

  static const StrongModeCode DOWN_CAST_IMPLICIT = StrongModeCode(
      ErrorType.HINT, 'DOWN_CAST_IMPLICIT', _implicitCastMessage,
      correction: _implicitCastCorrection);

  static const StrongModeCode DOWN_CAST_IMPLICIT_ASSIGN = StrongModeCode(
      ErrorType.HINT, 'DOWN_CAST_IMPLICIT_ASSIGN', _implicitCastMessage,
      correction: _implicitCastCorrection);

  static const StrongModeCode DYNAMIC_CAST = StrongModeCode(
      ErrorType.HINT, 'DYNAMIC_CAST', _implicitCastMessage,
      correction: _implicitCastCorrection);

  static const StrongModeCode ASSIGNMENT_CAST = StrongModeCode(
      ErrorType.HINT, 'ASSIGNMENT_CAST', _implicitCastMessage,
      correction: _implicitCastCorrection);

  static const StrongModeCode INVALID_PARAMETER_DECLARATION = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'INVALID_PARAMETER_DECLARATION',
      "Type check failed: '{0}' isn't of type '{1}'.");

  static const StrongModeCode COULD_NOT_INFER = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'COULD_NOT_INFER',
      "Couldn't infer type parameter '{0}'.{1}");

  static const StrongModeCode INFERRED_TYPE =
      StrongModeCode(ErrorType.HINT, 'INFERRED_TYPE', _inferredTypeMessage);

  static const StrongModeCode INFERRED_TYPE_LITERAL = StrongModeCode(
      ErrorType.HINT, 'INFERRED_TYPE_LITERAL', _inferredTypeMessage);

  static const StrongModeCode INFERRED_TYPE_ALLOCATION = StrongModeCode(
      ErrorType.HINT, 'INFERRED_TYPE_ALLOCATION', _inferredTypeMessage);

  static const StrongModeCode INFERRED_TYPE_CLOSURE = StrongModeCode(
      ErrorType.HINT, 'INFERRED_TYPE_CLOSURE', _inferredTypeMessage);

  static const StrongModeCode INVALID_CAST_LITERAL = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'INVALID_CAST_LITERAL',
      "The literal '{0}' with type '{1}' isn't of expected type '{2}'.");

  static const StrongModeCode INVALID_CAST_LITERAL_LIST = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'INVALID_CAST_LITERAL_LIST',
      "The list literal type '{0}' isn't of expected type '{1}'. The list's "
          "type can be changed with an explicit generic type argument or by "
          "changing the element types.");

  static const StrongModeCode INVALID_CAST_LITERAL_MAP = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'INVALID_CAST_LITERAL_MAP',
      "The map literal type '{0}' isn't of expected type '{1}'. The maps's "
          "type can be changed with an explicit generic type arguments or by "
          "changing the key and value types.");

  static const StrongModeCode INVALID_CAST_LITERAL_SET = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'INVALID_CAST_LITERAL_SET',
      "The set literal type '{0}' isn't of expected type '{1}'. The set's "
          "type can be changed with an explicit generic type argument or by "
          "changing the element types.");

  static const StrongModeCode INVALID_CAST_FUNCTION_EXPR = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'INVALID_CAST_FUNCTION_EXPR',
      "The function expression type '{0}' isn't of type '{1}'. "
          "This means its parameter or return type doesn't match what is "
          "expected. Consider changing parameter type(s) or the returned "
          "type(s).");

  static const StrongModeCode INVALID_CAST_NEW_EXPR = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'INVALID_CAST_NEW_EXPR',
      "The constructor returns type '{0}' that isn't of expected type '{1}'.");

  static const StrongModeCode INVALID_CAST_METHOD = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'INVALID_CAST_METHOD',
      "The method tear-off '{0}' has type '{1}' that isn't of expected type "
          "'{2}'. This means its parameter or return type doesn't match what "
          "is expected.");

  static const StrongModeCode INVALID_CAST_FUNCTION = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'INVALID_CAST_FUNCTION',
      "The function '{0}' has type '{1}' that isn't of expected type "
          "'{2}'. This means its parameter or return type doesn't match what "
          "is expected.");

  static const StrongModeCode INVALID_SUPER_INVOCATION = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'INVALID_SUPER_INVOCATION',
      "The super call must be last in an initializer "
          "list (see https://goo.gl/EY6hDP): '{0}'.");

  static const StrongModeCode NON_GROUND_TYPE_CHECK_INFO = StrongModeCode(
      ErrorType.HINT,
      'NON_GROUND_TYPE_CHECK_INFO',
      "Runtime check on non-ground type '{0}' may throw StrongModeError.");

  static const StrongModeCode DYNAMIC_INVOKE = StrongModeCode(
      ErrorType.HINT, 'DYNAMIC_INVOKE', "'{0}' requires a dynamic invoke.");

  static const StrongModeCode IMPLICIT_DYNAMIC_PARAMETER = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'IMPLICIT_DYNAMIC_PARAMETER',
      "Missing parameter type for '{0}'.",
      correction: _implicitDynamicCorrection);

  static const StrongModeCode IMPLICIT_DYNAMIC_RETURN = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'IMPLICIT_DYNAMIC_RETURN',
      "Missing return type for '{0}'.",
      correction: _implicitDynamicCorrection);

  static const StrongModeCode IMPLICIT_DYNAMIC_VARIABLE = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'IMPLICIT_DYNAMIC_VARIABLE',
      "Missing variable type for '{0}'.",
      correction: _implicitDynamicCorrection);

  static const StrongModeCode IMPLICIT_DYNAMIC_FIELD = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'IMPLICIT_DYNAMIC_FIELD',
      "Missing field type for '{0}'.",
      correction: _implicitDynamicCorrection);

  static const StrongModeCode IMPLICIT_DYNAMIC_TYPE = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'IMPLICIT_DYNAMIC_TYPE',
      "Missing type arguments for generic type '{0}'.",
      correction: _implicitDynamicCorrection);

  static const StrongModeCode IMPLICIT_DYNAMIC_LIST_LITERAL = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'IMPLICIT_DYNAMIC_LIST_LITERAL',
      "Missing type argument for list literal.",
      correction: _implicitDynamicCorrection);

  static const StrongModeCode IMPLICIT_DYNAMIC_MAP_LITERAL = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'IMPLICIT_DYNAMIC_MAP_LITERAL',
      "Missing type arguments for map literal.",
      correction: _implicitDynamicCorrection);

  static const StrongModeCode IMPLICIT_DYNAMIC_FUNCTION = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'IMPLICIT_DYNAMIC_FUNCTION',
      "Missing type arguments for generic function '{0}<{1}>'.",
      correction: _implicitDynamicCorrection);

  static const StrongModeCode IMPLICIT_DYNAMIC_METHOD = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'IMPLICIT_DYNAMIC_METHOD',
      "Missing type arguments for generic method '{0}<{1}>'.",
      correction: _implicitDynamicCorrection);

  static const StrongModeCode IMPLICIT_DYNAMIC_INVOKE = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'IMPLICIT_DYNAMIC_INVOKE',
      "Missing type arguments for calling generic function type '{0}'.",
      correction: _implicitDynamicCorrection);

  static const StrongModeCode NOT_INSTANTIATED_BOUND = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'NOT_INSTANTIATED_BOUND',
      "Type parameter bound types must be instantiated.",
      correction: "Try adding type arguments.");

  /*
   * TODO(brianwilkerson) Make the TOP_LEVEL_ error codes be errors rather than
   * hints and then clean up the function _errorSeverity in
   * test/src/task/strong/strong_test_helper.dart.
   */
  /* TODO(leafp) Delete most of these.
   */
  static const StrongModeCode TOP_LEVEL_CYCLE = StrongModeCode(
      ErrorType.COMPILE_TIME_ERROR,
      'TOP_LEVEL_CYCLE',
      "The type of '{0}' can't be inferred because it depends on itself "
          "through the cycle: {1}.",
      correction:
          "Try adding an explicit type to one or more of the variables in the "
          "cycle in order to break the cycle.");

  static const StrongModeCode TOP_LEVEL_FUNCTION_LITERAL_BLOCK = StrongModeCode(
      ErrorType.HINT,
      'TOP_LEVEL_FUNCTION_LITERAL_BLOCK',
      "The type of the function literal can't be inferred because the "
          "literal has a block as its body.",
      correction: "Try adding an explicit type to the variable.");

  static const StrongModeCode TOP_LEVEL_IDENTIFIER_NO_TYPE = StrongModeCode(
      ErrorType.HINT,
      'TOP_LEVEL_IDENTIFIER_NO_TYPE',
      "The type of '{0}' can't be inferred because the type of '{1}' "
          "couldn't be inferred.",
      correction:
          "Try adding an explicit type to either the variable '{0}' or the "
          "variable '{1}'.");

  static const StrongModeCode TOP_LEVEL_INSTANCE_GETTER = StrongModeCode(
      ErrorType.STATIC_WARNING,
      'TOP_LEVEL_INSTANCE_GETTER',
      "The type of '{0}' can't be inferred because it refers to an instance "
          "getter, '{1}', which has an implicit type.",
      correction: "Add an explicit type for either '{0}' or '{1}'.");

  static const StrongModeCode TOP_LEVEL_INSTANCE_METHOD = StrongModeCode(
      ErrorType.STATIC_WARNING,
      'TOP_LEVEL_INSTANCE_METHOD',
      "The type of '{0}' can't be inferred because it refers to an instance "
          "method, '{1}', which has an implicit type.",
      correction: "Add an explicit type for either '{0}' or '{1}'.");

  @override
  final ErrorType type;

  /**
   * Initialize a newly created error code to have the given [type] and [name].
   *
   * The message associated with the error will be created from the given
   * [message] template. The correction associated with the error will be
   * created from the optional [correction] template.
   */
  const StrongModeCode(ErrorType type, String name, String message,
      {String correction, bool hasPublishedDocs})
      : type = type,
        super.temporary(name, message,
            correction: correction,
            hasPublishedDocs: hasPublishedDocs ?? false);

  @override
  ErrorSeverity get errorSeverity => type.severity;
}
