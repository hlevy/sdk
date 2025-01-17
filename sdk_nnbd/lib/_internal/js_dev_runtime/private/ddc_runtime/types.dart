// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library defines the representation of runtime types.
part of dart._runtime;

/// Sets the mode of the runtime subtype checks.
///
/// Changing the mode after any calls to dart.isSubtype() is not supported.
void strictSubtypeChecks(bool flag) {
  JS('', 'dart.__strictSubtypeChecks = #', flag);
}

final metadata = JS('', 'Symbol("metadata")');

/// Types in dart are represented internally at runtime as follows.
///
///   - Normal nominal types, produced from classes, are represented
///     at runtime by the JS class of which they are an instance.
///     If the type is the result of instantiating a generic class,
///     then the "classes" module manages the association between the
///     instantiated class and the original class declaration
///     and the type arguments with which it was instantiated.  This
///     association can be queried via the "classes" module".
///
///   - All other types are represented as instances of class [DartType],
///     defined in this module.
///     - Dynamic, Void, and Bottom are singleton instances of sentinel
///       classes.
///     - Function types are instances of subclasses of AbstractFunctionType.
///
/// Function types are represented in one of two ways:
///   - As an instance of FunctionType.  These are eagerly computed.
///   - As an instance of TypeDef.  The TypeDef representation lazily
///     computes an instance of FunctionType, and delegates to that instance.
///
/// These above "runtime types" are what is used for implementing DDC's
/// internal type checks. These objects are distinct from the objects exposed
/// to user code by class literals and calling `Object.runtimeType`. In DDC,
/// the latter are represented by instances of WrappedType which contain a
/// real runtime type internally. This ensures that the returned object only
/// exposes the API that Type defines:
///
///     get String name;
///     String toString();
///
/// These "runtime types" have methods for performing type checks. The methods
/// have the following JavaScript names which are designed to not collide with
/// static methods, which are also placed 'on' the class constructor function.
///
///     T.is(o): Implements 'o is T'.
///     T.as(o): Implements 'o as T'.
///     T._check(o): Implements the type assertion of 'T x = o;'
///
/// By convention, we used named JavaScript functions for these methods with the
/// name 'is_X', 'as_X' and 'check_X' for various X to indicate the type or the
/// implementation strategy for the test (e.g 'is_String', 'is_G' for generic
/// types, etc.)
// TODO(jmesserly): we shouldn't implement Type here. It should be moved down
// to AbstractFunctionType.
class DartType implements Type {
  String get name => this.toString();

  // TODO(jmesserly): these should never be reached, can be make them abstract?
  @notNull
  @JSExportName('is')
  bool is_T(object) => instanceOf(object, this);

  @JSExportName('as')
  as_T(object) => cast(object, this, false);

  @JSExportName('_check')
  check_T(object) => cast(object, this, true);
}

class DynamicType extends DartType {
  toString() => 'dynamic';

  @JSExportName('is')
  bool is_T(object) => true;

  @JSExportName('as')
  as_T(object) => object;

  @JSExportName('_check')
  check_T(object) => object;
}

@notNull
bool _isJsObject(obj) => JS('!', '# === #', getReifiedType(obj), jsobject);

/// Asserts that [f] is a native JS functions and returns it if so.
/// This function should be used to ensure that a function is a native
/// JS functions in contexts that expect that.
F assertInterop<F extends Function>(F f) {
  // TODO(vsm): Throw a more specific error if this fails.
  assert(_isJsObject(f));
  return f;
}

bool isDartFunction(obj) =>
    JS<bool>('!', '# instanceof Function', obj) &&
    JS<bool>('!', '#[#] != null', obj, _runtimeType);

/// The Dart type that represents a JavaScript class(/constructor) type.
///
/// The JavaScript type may not exist, either because it's not loaded yet, or
/// because it's not available (such as with mocks). To handle this gracefully,
/// we disable type checks for in these cases, and allow any JS object to work
/// as if it were an instance of this JS type.
class LazyJSType extends DartType {
  Function()? _getRawJSTypeFn;
  @notNull
  final String _dartName;
  Object? _rawJSType;

  LazyJSType(this._getRawJSTypeFn, this._dartName);

  toString() {
    var raw = _getRawJSType();
    return raw != null ? typeName(raw) : "JSObject<$_dartName>";
  }

  Object? _getRawJSType() {
    var raw = _rawJSType;
    if (raw != null) return raw;

    // Try to evaluate the JS type. If this fails for any reason, we'll try
    // again next time.
    // TODO(jmesserly): is it worth trying again? It may create unnecessary
    // overhead, especially if exceptions are being thrown. Also it means the
    // behavior of a given type check can change later on.
    try {
      raw = _getRawJSTypeFn!();
    } catch (e) {}

    if (raw == null) {
      _warn('Cannot find native JavaScript type ($_dartName) for type check');
    } else {
      _rawJSType = raw;
      _getRawJSTypeFn = null; // Free the function that computes the JS type.
    }
    return raw;
  }

  Object rawJSTypeForCheck() => _getRawJSType() ?? jsobject;

  @notNull
  bool isRawJSType(obj) {
    var raw = _getRawJSType();
    if (raw != null) return JS('!', '# instanceof #', obj, raw);
    return _isJsObject(obj);
  }

  @notNull
  @JSExportName('is')
  bool is_T(obj) => isRawJSType(obj) || instanceOf(obj, this);

  @JSExportName('as')
  as_T(obj) => obj == null || is_T(obj) ? obj : castError(obj, this, false);

  @JSExportName('_check')
  check_T(obj) => obj == null || is_T(obj) ? obj : castError(obj, this, true);
}

/// An anonymous JS type
///
/// For the purposes of subtype checks, these match any JS type.
class AnonymousJSType extends DartType {
  final String _dartName;
  AnonymousJSType(this._dartName);
  toString() => _dartName;

  @JSExportName('is')
  bool is_T(obj) => _isJsObject(obj) || instanceOf(obj, this);

  @JSExportName('as')
  as_T(obj) => obj == null || _isJsObject(obj) ? obj : cast(obj, this, false);

  @JSExportName('_check')
  check_T(obj) => obj == null || _isJsObject(obj) ? obj : cast(obj, this, true);
}

void _warn(arg) {
  JS('void', 'console.warn(#)', arg);
}

var _lazyJSTypes = JS('', 'new Map()');
var _anonymousJSTypes = JS('', 'new Map()');

lazyJSType(Function() getJSTypeCallback, String name) {
  var ret = JS('', '#.get(#)', _lazyJSTypes, name);
  if (ret == null) {
    ret = LazyJSType(getJSTypeCallback, name);
    JS('', '#.set(#, #)', _lazyJSTypes, name, ret);
  }
  return ret;
}

anonymousJSType(String name) {
  var ret = JS('', '#.get(#)', _anonymousJSTypes, name);
  if (ret == null) {
    ret = AnonymousJSType(name);
    JS('', '#.set(#, #)', _anonymousJSTypes, name, ret);
  }
  return ret;
}

/// A javascript Symbol used to store a canonical version of T? on T.
final _cachedNullable = JS('', 'Symbol("cachedNullable")');

/// A javascript Symbol used to store a canonical version of T* on T.
final _cachedLegacy = JS('', 'Symbol("cachedLegacy")');

/// Returns a nullable (question, ?) version of [type].
///
/// The resulting type returned in a normalized form based on the rules from the
/// normalization doc: https://github.com/dart-lang/language/pull/456
// TODO(nshahan): Update after the normalization doc PR lands.
@notNull
Object nullable(type) {
  if (_isNullable(type) || _isTop(type) || _isNullType(type)) return type;
  if (type == never_) return unwrapType(Null);
  if (_isLegacy(type)) type = type.type;

  // Check if a nullable version of this type has already been created.
  if (JS<bool>('!', '#.hasOwnProperty(#)', type, _cachedNullable)) {
    return JS<NullableType>('!', '#[#]', type, _cachedNullable);
  }
  // Cache a canonical nullable version of this type on this type.
  var cachedType = NullableType(type);
  JS('', '#[#] = #', type, _cachedNullable, cachedType);
  return cachedType;
}

/// Returns a legacy (star, *) version of [type].
///
/// The resulting type returned in a normalized form based on the rules from the
/// normalization doc: https://github.com/dart-lang/language/pull/456
// TODO(nshahan): Update after the normalization doc PR lands.
@notNull
DartType legacy(type) {
  // TODO(nshahan) Maybe normailize never*,  Null*.
  if (_isLegacy(type) || _isNullable(type) || _isTop(type)) return type;

  // Check if a legacy version of this type has already been created.
  if (JS<bool>('!', '#.hasOwnProperty(#)', type, _cachedLegacy)) {
    return JS<NullableType>('!', '#[#]', type, _cachedLegacy);
  }
  // Cache a canonical legacy version of this type on this type.
  var cachedType = LegacyType(type);
  JS('', '#[#] = #', type, _cachedLegacy, cachedType);
  return cachedType;
}

/// A wrapper to identify a nullable (question, ?) type of the form [type]?.
class NullableType extends DartType {
  final Type type;

  NullableType(this.type)
      : assert(type is! NullableType),
        assert(type is! LegacyType);

  @override
  String get name => '$type?';

  @override
  String toString() => name;
}

/// A wrapper to identify a legacy (star, *) type of the form [type]*.
class LegacyType extends DartType {
  final Type type;

  LegacyType(this.type)
      : assert(type is! LegacyType),
        assert(type is! NullableType);

  @override
  String get name => '$type*';

  @override
  String toString() => name;
}

// TODO(nshahan) Add override optimizations for is, as and _check?
class NeverType extends DartType {
  @override
  toString() => 'Never';
}

@JSExportName('Never')
final never_ = NeverType();

@JSExportName('dynamic')
final _dynamic = DynamicType();

class VoidType extends DartType {
  toString() => 'void';
}

@JSExportName('void')
final void_ = VoidType();

// TODO(nshahan): Cleanup and consolidate NeverType, BottomType, bottom, never_.
class BottomType extends DartType {
  toString() => 'bottom';
}

final bottom = never_;

class JSObjectType extends DartType {
  toString() => 'NativeJavaScriptObject';
}

final jsobject = JSObjectType();

/// Dev Compiler's implementation of Type, wrapping its internal [_type].
class _Type extends Type {
  /// The internal type representation, either a [DartType] or class constructor
  /// function.
  // TODO(jmesserly): introduce InterfaceType so we don't have to special case
  // classes
  @notNull
  final Object _type;

  _Type(this._type);

  toString() => typeName(_type);

  Type get runtimeType => Type;
}

/// Given an internal runtime type object, wraps it in a `_Type` object
/// that implements the dart:core Type interface.
Type wrapType(type) {
  // If we've already wrapped this type once, use the previous wrapper. This
  // way, multiple references to the same type return an identical Type.
  if (JS('!', '#.hasOwnProperty(#)', type, _typeObject)) {
    return JS('', '#[#]', type, _typeObject);
  }
  var result = _Type(type);
  JS('', '#[#] = #', type, _typeObject, result);
  return result;
}

/// The symbol used to store the cached `Type` object associated with a class.
final _typeObject = JS('', 'Symbol("typeObject")');

/// Given a WrappedType, return the internal runtime type object.
Object unwrapType(Type obj) => JS<_Type>('', '#', obj)._type;

// Marker class for generic functions, typedefs, and non-generic functions.
abstract class AbstractFunctionType extends DartType {}

/// Memo table for named argument groups. A named argument packet
/// {name1 : type1, ..., namen : typen} corresponds to the path
/// n, name1, type1, ...., namen, typen.  The element of the map
/// reached via this path (if any) is the canonical representative
/// for this packet.
final _fnTypeNamedArgMap = JS('', 'new Map()');

/// Memo table for positional argument groups. A positional argument
/// packet [type1, ..., typen] (required or optional) corresponds to
/// the path n, type1, ...., typen.  The element reached via
/// this path (if any) is the canonical representative for this
/// packet. Note that required and optional parameters packages
/// may have the same canonical representation.
final _fnTypeArrayArgMap = JS('', 'new Map()');

/// Memo table for function types. The index path consists of the
/// path length - 1, the returnType, the canonical positional argument
/// packet, and if present, the canonical optional or named argument
/// packet.  A level of indirection could be avoided here if desired.
final _fnTypeTypeMap = JS('', 'new Map()');

/// Memo table for small function types with no optional or named
/// arguments and less than a fixed n (currently 3) number of
/// required arguments.  Indexing into this table by the number
/// of required arguments yields a map which is indexed by the
/// argument types themselves.  The element reached via this
/// index path (if present) is the canonical function type.
final List _fnTypeSmallMap = JS('', '[new Map(), new Map(), new Map()]');

@NoReifyGeneric()
T _memoizeArray<T>(map, arr, T create()) => JS('', '''(() => {
  let len = $arr.length;
  $map = $_lookupNonTerminal($map, len);
  for (var i = 0; i < len-1; ++i) {
    $map = $_lookupNonTerminal($map, $arr[i]);
  }
  let result = $map.get($arr[len-1]);
  if (result !== void 0) return result;
  $map.set($arr[len-1], result = $create());
  return result;
})()''');

List _canonicalizeArray(List array, map) =>
    _memoizeArray(map, array, () => array);

// TODO(leafp): This only canonicalizes of the names are
// emitted in a consistent order.
_canonicalizeNamed(named, map) => JS('', '''(() => {
  let key = [];
  let names = $getOwnPropertyNames($named);
  for (var i = 0; i < names.length; ++i) {
    let name = names[i];
    let type = $named[name];
    key.push(name);
    key.push(type);
  }
  return $_memoizeArray($map, key, () => $named);
})()''');

// TODO(leafp): This handles some low hanging fruit, but
// really we should make all of this faster, and also
// handle more cases here.
FunctionType _createSmall(returnType, List required) => JS('', '''(() => {
  let count = $required.length;
  let map = $_fnTypeSmallMap[count];
  for (var i = 0; i < count; ++i) {
    map = $_lookupNonTerminal(map, $required[i]);
 }
 let result = map.get($returnType);
 if (result !== void 0) return result;
 result = ${new FunctionType(returnType, required, [], JS('', '{}'), JS('', '{}'))};
 map.set($returnType, result);
 return result;
})()''');

class FunctionType extends AbstractFunctionType {
  final Type returnType;
  List args;
  List optionals;
  // Named arguments native JS Object of the form { namedArgName: namedArgType }
  final named;
  final requiredNamed;
  // TODO(vsm): This is just parameter metadata for now.
  // Suspected but not confirmed: Only used by mirrors for pageloader2 support.
  // The metadata is represented as a list of JS arrays, one for each argument
  // that contains the annotations for that argument or an empty array if there
  // are no annotations.
  List metadata = [];
  String? _stringValue;

  /// Construct a function type.
  ///
  /// We eagerly normalize the argument types to avoid having to deal with this
  /// logic in multiple places.
  ///
  /// This code does best effort canonicalization.  It does not guarantee that
  /// all instances will share.
  ///
  /// Note: Generic function subtype checks assume types have been canonicalized
  /// when testing if type bounds are equal.
  static FunctionType create(
      returnType, List args, optionalArgs, requiredNamedArgs) {
    // Note that if optionalArgs is ever passed as an empty array or an empty
    // map, we can end up with semantically identical function types that don't
    // canonicalize to the same object since we won't fall into this fast path.
    var noOptionalArgs = optionalArgs == null && requiredNamedArgs == null;
    if (noOptionalArgs && JS<bool>('!', '#.length < 3', args)) {
      return _createSmall(returnType, args);
    }
    args = _canonicalizeArray(args, _fnTypeArrayArgMap);
    var keys = [];
    FunctionType Function() create;
    if (noOptionalArgs) {
      keys = [returnType, args];
      create =
          () => FunctionType(returnType, args, [], JS('', '{}'), JS('', '{}'));
    } else if (JS('!', '# instanceof Array', optionalArgs)) {
      var optionals =
          _canonicalizeArray(JS('', '#', optionalArgs), _fnTypeArrayArgMap);
      keys = [returnType, args, optionals];
      create = () =>
          FunctionType(returnType, args, optionals, JS('', '{}'), JS('', '{}'));
    } else {
      var named = _canonicalizeNamed(optionalArgs, _fnTypeNamedArgMap);
      var requiredNamed =
          _canonicalizeNamed(requiredNamedArgs, _fnTypeNamedArgMap);
      keys = [returnType, args, named, requiredNamed];
      create = () => FunctionType(returnType, args, [], named, requiredNamed);
    }
    return _memoizeArray(_fnTypeTypeMap, keys, create);
  }

  /// Returns the function arguments.
  ///
  /// If an argument is provided with annotations (encoded as a JS array where
  /// the first element is the argument, and the rest are annotations) the
  /// annotations are extracted and saved in [metadata].
  List _process(List array) {
    var result = [];
    for (var i = 0; JS<bool>('!', '# < #.length', i, array); ++i) {
      var arg = JS('', '#[#]', array, i);
      if (JS('!', '# instanceof Array', arg)) {
        JS('', '#.push(#.slice(1))', metadata, arg);
        JS('', '#.push(#[0])', result, arg);
      } else {
        JS('', '#.push([])', metadata);
        JS('', '#.push(#)', result, arg);
      }
    }
    return result;
  }

  FunctionType(this.returnType, this.args, this.optionals, this.named,
      this.requiredNamed) {
    this.args = _process(this.args);
    this.optionals = _process(this.optionals);
    // TODO(vsm): Named arguments were never used by pageloader2 so they were
    // never processed here.
  }

  toString() => name;

  int get requiredParameterCount => args.length;
  int get positionalParameterCount => args.length + optionals.length;

  getPositionalParameter(int i) {
    int n = args.length;
    return i < n ? args[i] : optionals[i + n];
  }

  /// Maps argument names to their canonicalized type.
  Map<String, Object> _createNameMap(List<String> names) {
    var result = <String, Object>{};
    // TODO: Remove this sort if ordering can be conserved.
    JS('', '#.sort()', names);
    for (var i = 0; JS<bool>('!', '# < #.length', i, names); ++i) {
      String name = JS('!', '#[#]', names, i);
      result[name] = JS('', '#[#]', named, name);
    }
    return result;
  }

  /// Maps optional named parameter names to their canonicalized type.
  Map<String, Object> getNamedParameters() =>
      _createNameMap(getOwnPropertyNames(named).toList());

  /// Maps required named parameter names to their canonicalized type.
  Map<String, Object> getRequiredNamedParameters() =>
      _createNameMap(getOwnPropertyNames(requiredNamed).toList());

  get name {
    if (_stringValue != null) return _stringValue!;
    var buffer = '(';
    for (var i = 0; JS<bool>('!', '# < #.length', i, args); ++i) {
      if (i > 0) {
        buffer += ', ';
      }
      buffer += typeName(JS('', '#[#]', args, i));
    }
    if (JS('!', '#.length > 0', optionals)) {
      if (JS('!', '#.length > 0', args)) buffer += ', ';
      buffer += '[';
      for (var i = 0; JS<bool>('!', '# < #.length', i, optionals); ++i) {
        if (i > 0) {
          buffer += ', ';
        }
        buffer += typeName(JS('', '#[#]', optionals, i));
      }
      buffer += ']';
    } else if (JS('!', 'Object.keys(#).length > 0 || Object.keys(#).length > 0',
        named, requiredNamed)) {
      if (JS('!', '#.length > 0', args)) buffer += ', ';
      buffer += '{';
      var names = getOwnPropertyNames(named);
      JS('', '#.sort()', names);
      for (var i = 0; JS<bool>('!', '# < #.length', i, names); i++) {
        if (i > 0) {
          buffer += ', ';
        }
        var typeNameString = typeName(JS('', '#[#[#]]', named, names, i));
        buffer += '$typeNameString ${JS('', '#[#]', names, i)}';
      }
      if (JS('!', '#.length > 0', names)) buffer += ', ';
      names = getOwnPropertyNames(requiredNamed);
      JS('', '#.sort()', names);
      for (var i = 0; JS<bool>('!', '# < #.length', i, names); i++) {
        if (i > 0) {
          buffer += ', ';
        }
        var typeNameString =
            typeName(JS('', '#[#[#]]', requiredNamed, names, i));
        buffer += 'required $typeNameString ${JS('', '#[#]', names, i)}';
      }
      buffer += '}';
    }
    var returnTypeName = typeName(returnType);
    buffer += ') => $returnTypeName';
    _stringValue = buffer;
    return buffer;
  }

  @JSExportName('is')
  bool is_T(obj) {
    if (JS('!', 'typeof # == "function"', obj)) {
      var actual = JS('', '#[#]', obj, _runtimeType);
      // If there's no actual type, it's a JS function.
      // Allow them to subtype all Dart function types.
      return actual == null || isSubtypeOf(actual, this);
    }
    return false;
  }

  @JSExportName('as')
  as_T(obj, [@notNull bool isImplicit = false]) {
    if (obj == null) return obj;
    if (JS('!', 'typeof # == "function"', obj)) {
      var actual = JS('', '#[#]', obj, _runtimeType);
      // If there's no actual type, it's a JS function.
      // Allow them to subtype all Dart function types.
      if (actual == null || isSubtypeOf(actual, this)) {
        return obj;
      }
    }
    return castError(obj, this, isImplicit);
  }

  @JSExportName('_check')
  check_T(obj) => as_T(obj, true);
}

/// A type variable, used by [GenericFunctionType] to represent a type formal.
class TypeVariable extends DartType {
  final String name;

  TypeVariable(this.name);

  toString() => name;
}

class Variance {
  static const int unrelated = 0;
  static const int covariant = 1;
  static const int contravariant = 2;
  static const int invariant = 3;
}

class GenericFunctionType extends AbstractFunctionType {
  final _instantiateTypeParts;
  final int formalCount;
  final _instantiateTypeBounds;
  final List<TypeVariable> _typeFormals;

  GenericFunctionType(instantiateTypeParts, this._instantiateTypeBounds)
      : _instantiateTypeParts = instantiateTypeParts,
        formalCount = JS('!', '#.length', instantiateTypeParts),
        _typeFormals = _typeFormalsFromFunction(instantiateTypeParts);

  List<TypeVariable> get typeFormals => _typeFormals;

  /// `true` if there are bounds on any of the generic type parameters.
  get hasTypeBounds => _instantiateTypeBounds != null;

  /// Checks that [typeArgs] satisfies the upper bounds of the [typeFormals],
  /// and throws a [TypeError] if they do not.
  void checkBounds(List typeArgs) {
    // If we don't have explicit type parameter bounds, the bounds default to
    // a top type, so there's nothing to check here.
    if (!hasTypeBounds) return;

    var bounds = instantiateTypeBounds(typeArgs);
    var typeFormals = this.typeFormals;
    for (var i = 0; i < typeArgs.length; i++) {
      checkTypeBound(typeArgs[i], bounds[i], typeFormals[i].name);
    }
  }

  FunctionType instantiate(typeArgs) {
    var parts = JS('', '#.apply(null, #)', _instantiateTypeParts, typeArgs);
    return FunctionType.create(JS('', '#[0]', parts), JS('', '#[1]', parts),
        JS('', '#[2]', parts), JS('', '#[3]', parts));
  }

  List instantiateTypeBounds(List typeArgs) {
    if (!hasTypeBounds) {
      // The Dart 1 spec says omitted type parameters have an upper bound of
      // Object. However Dart 2 uses `dynamic` for the purpose of instantiate to
      // bounds, so we use that here.
      return List.filled(formalCount, _dynamic);
    }
    // Bounds can be recursive or depend on other type parameters, so we need to
    // apply type arguments and return the resulting bounds.
    return JS('List', '#.apply(null, #)', _instantiateTypeBounds, typeArgs);
  }

  toString() {
    String s = "<";
    var typeFormals = this.typeFormals;
    var typeBounds = instantiateTypeBounds(typeFormals);
    for (int i = 0, n = typeFormals.length; i < n; i++) {
      if (i != 0) s += ", ";
      s += JS<String>('!', '#[#].name', typeFormals, i);
      var bound = typeBounds[i];
      if (JS('!', '# !== # && # !== #', bound, dynamic, bound, Object)) {
        s += " extends $bound";
      }
    }
    s += ">" + instantiate(typeFormals).toString();
    return s;
  }

  /// Given a [DartType] [type], if [type] is an uninstantiated
  /// parameterized type then instantiate the parameters to their
  /// bounds and return those type arguments.
  ///
  /// See the issue for the algorithm description:
  /// <https://github.com/dart-lang/sdk/issues/27526#issuecomment-260021397>
  List instantiateDefaultBounds() {
    var typeFormals = this.typeFormals;

    // All type formals
    var all = HashMap<Object, int>.identity();
    // ground types, by index.
    //
    // For each index, this will be a ground type for the corresponding type
    // formal if known, or it will be the original TypeVariable if we are still
    // solving for it. This array is passed to `instantiateToBounds` as we are
    // progressively solving for type variables.
    var defaults = List<Object?>(typeFormals.length);
    // not ground
    var partials = Map<TypeVariable, Object>.identity();

    var typeBounds = this.instantiateTypeBounds(typeFormals);
    for (var i = 0; i < typeFormals.length; i++) {
      var typeFormal = typeFormals[i];
      var bound = typeBounds[i];
      all[typeFormal] = i;
      if (identical(bound, _dynamic)) {
        defaults[i] = bound;
      } else {
        defaults[i] = typeFormal;
        partials[typeFormal] = bound;
      }
    }

    bool hasFreeFormal(t) {
      if (partials.containsKey(t)) return true;
      // Generic classes and typedefs.
      var typeArgs = getGenericArgs(t);
      if (typeArgs != null) return typeArgs.any(hasFreeFormal);
      if (t is GenericFunctionType) {
        return hasFreeFormal(t.instantiate(t.typeFormals));
      }
      if (t is FunctionType) {
        return hasFreeFormal(t.returnType) || t.args.any(hasFreeFormal);
      }
      return false;
    }

    var hasProgress = true;
    while (hasProgress) {
      hasProgress = false;
      for (var typeFormal in partials.keys) {
        var partialBound = partials[typeFormal]!;
        if (!hasFreeFormal(partialBound)) {
          int index = all[typeFormal]!;
          defaults[index] = instantiateTypeBounds(defaults)[index];
          partials.remove(typeFormal);
          hasProgress = true;
          break;
        }
      }
    }

    // If we stopped making progress, and not all types are ground,
    // then the whole type is malbounded and an error should be reported
    // if errors are requested, and a partially completed type should
    // be returned.
    if (partials.isNotEmpty) {
      throwTypeError('Instantiate to bounds failed for type with '
          'recursive generic bounds: ${typeName(this)}. '
          'Try passing explicit type arguments.');
    }
    return defaults;
  }

  @notNull
  @JSExportName('is')
  bool is_T(obj) {
    if (JS('!', 'typeof # == "function"', obj)) {
      var actual = JS('', '#[#]', obj, _runtimeType);
      return actual != null && isSubtypeOf(actual, this);
    }
    return false;
  }

  @JSExportName('as')
  as_T(obj) {
    if (obj == null || is_T(obj)) return obj;
    return castError(obj, this, false);
  }

  @JSExportName('_check')
  check_T(obj) {
    if (obj == null || is_T(obj)) return obj;
    return castError(obj, this, true);
  }
}

List<TypeVariable> _typeFormalsFromFunction(Object? typeConstructor) {
  // Extract parameter names from the function parameters.
  //
  // This is not robust in general for user-defined JS functions, but it
  // should handle the functions generated by our compiler.
  //
  // TODO(jmesserly): names of TypeVariables are only used for display
  // purposes, such as when an error happens or if someone calls
  // `Type.toString()`. So we could recover them lazily rather than eagerly.
  // Alternatively we could synthesize new names.
  String str = JS('!', '#.toString()', typeConstructor);
  var hasParens = str[0] == '(';
  var end = str.indexOf(hasParens ? ')' : '=>');
  if (hasParens) {
    return str
        .substring(1, end)
        .split(',')
        .map((n) => TypeVariable(n.trim()))
        .toList();
  } else {
    return [TypeVariable(str.substring(0, end).trim())];
  }
}

/// Create a function type.
FunctionType fnType(returnType, List args,
        [@undefined optional, @undefined requiredNamed]) =>
    FunctionType.create(returnType, args, optional, requiredNamed);

/// Creates a generic function type from [instantiateFn] and [typeBounds].
///
/// A function type consists of two things:
/// * An instantiate function that takes type arguments and returns the
///   function signature in the form of a two element list. The first element
///   is the return type. The second element is a list of the argument types.
/// * A function that returns a list of upper bound constraints for each of
///   the type formals.
///
/// Both functions accept the type parameters, allowing us to substitute values.
/// The upper bound constraints can be omitted if all of the type parameters use
/// the default upper bound.
///
/// For example given the type <T extends Iterable<T>>(T) -> T, we can declare
/// this type with `gFnType(T => [T, [T]], T => [Iterable$(T)])`.
gFnType(instantiateFn, typeBounds) =>
    GenericFunctionType(instantiateFn, typeBounds);

/// TODO(vsm): Remove when mirrors is deprecated.
/// This is a temporary workaround to support dart:mirrors, which doesn't
/// understand generic methods.
getFunctionTypeMirror(AbstractFunctionType type) {
  if (type is GenericFunctionType) {
    var typeArgs = List.filled(type.formalCount, dynamic);
    return type.instantiate(typeArgs);
  }
  return type;
}

/// Whether the given JS constructor [obj] is a Dart class type.
@notNull
bool isType(obj) => JS('', '#[#] === #', obj, _runtimeType, Type);

void checkTypeBound(
    @notNull Object type, @notNull Object bound, @notNull String name) {
  if (!isSubtypeOf(type, bound)) {
    throwTypeError('type `$type` does not extend `$bound` of `$name`.');
  }
}

@notNull
String typeName(type) => JS('', '''(() => {
  if ($type === void 0) return "undefined type";
  if ($type === null) return "null type";
  // Non-instance types
  if ($type instanceof $DartType) {
    return $type.toString();
  }

  // Instance types
  let tag = $type[$_runtimeType];
  if (tag === $Type) {
    let name = $type.name;
    let args = ${getGenericArgs(type)};
    if (args == null) return name;

    if (${getGenericClass(type)} == ${getGenericClass(JSArray)}) name = 'List';

    let result = name;
    result += '<';
    for (let i = 0; i < args.length; ++i) {
      if (i > 0) result += ', ';
      result += $typeName(args[i]);
    }
    result += '>';
    return result;
  }
  if (tag) return "Not a type: " + tag.name;
  return "JSObject<" + $type.name + ">";
})()''');

/// Returns true if [ft1] <: [ft2].
_isFunctionSubtype(ft1, ft2, bool strictMode) => JS('', '''(() => {
  let ret1 = $ft1.returnType;
  let ret2 = $ft2.returnType;

  let args1 = $ft1.args;
  let args2 = $ft2.args;

  if (args1.length > args2.length) {
    return false;
  }

  for (let i = 0; i < args1.length; ++i) {
    if (!$_isSubtype(args2[i], args1[i], strictMode)) {
      return false;
    }
  }

  let optionals1 = $ft1.optionals;
  let optionals2 = $ft2.optionals;

  if (args1.length + optionals1.length < args2.length + optionals2.length) {
    return false;
  }

  let j = 0;
  for (let i = args1.length; i < args2.length; ++i, ++j) {
    if (!$_isSubtype(args2[i], optionals1[j], strictMode)) {
      return false;
    }
  }

  for (let i = 0; i < optionals2.length; ++i, ++j) {
    if (!$_isSubtype(optionals2[i], optionals1[j], strictMode)) {
      return false;
    }
  }

  // Named parameter invariants:
  // 1) All named params in the superclass are named params in the subclass.
  // 2) All required named params in the subclass are required named params
  //    in the superclass.
  let named1 = $ft1.named;
  let requiredNamed1 = $ft1.requiredNamed;
  let named2 = $ft2.named;
  let requiredNamed2 = $ft2.requiredNamed;

  let names = $getOwnPropertyNames(requiredNamed1);
  for (let i = 0; i < names.length; ++i) {
    let name = names[i];
    let n2 = requiredNamed2[name];
    if (n2 === void 0) {
      return false;
    }
  }
  names = $getOwnPropertyNames(named2);
  for (let i = 0; i < names.length; ++i) {
    let name = names[i];
    let n1 = named1[name];
    let n2 = named2[name];
    if (n1 === void 0) {
      return false;
    }
    if (!$_isSubtype(n2, n1, strictMode)) {
      return false;
    }
  }
  names = $getOwnPropertyNames(requiredNamed2);
  for (let i = 0; i < names.length; ++i) {
    let name = names[i];
    let n1 = named1[name] || requiredNamed1[name];
    let n2 = requiredNamed2[name];
    if (n1 === void 0) {
      return false;
    }
    if (!$_isSubtype(n2, n1)) {
      return false;
    }
  }

  return $_isSubtype(ret1, ret2, strictMode);
})()''');

/// Returns true if [t1] <: [t2].
@notNull
bool isSubtypeOf(Object t1, Object t2) {
  // TODO(jmesserly): we've optimized `is`/`as`/implicit type checks, so they're
  // dispatched on the type. Can we optimize the subtype relation too?
  Object map;
  if (JS('!', '!#.hasOwnProperty(#)', t1, _subtypeCache)) {
    JS('', '#[#] = #', t1, _subtypeCache, map = JS<Object>('!', 'new Map()'));
    _cacheMaps.add(map);
  } else {
    map = JS<Object>('!', '#[#]', t1, _subtypeCache);
    bool result = JS('', '#.get(#)', map, t2);
    if (JS('!', '# !== void 0', result)) return result;
  }
  var validSubtype = _isSubtype(t1, t2, true);

  if (!validSubtype && !JS<bool>('!', 'dart.__strictSubtypeChecks')) {
    validSubtype = _isSubtype(t1, t2, false);
    if (validSubtype) {
      // TODO(nshahan) Need more information to be helpful here.
      // File and line number that caused the subtype check?
      // Possibly break into debuger?
      _warn("$t1 is not a subtype of $t2.\n"
          "This will be a runtime failure when strict mode is enabled.");
    }
  }
  JS('', '#.set(#, #)', map, t2, validSubtype);
  return validSubtype;
}

final _subtypeCache = JS('', 'Symbol("_subtypeCache")');

@notNull
bool _isBottom(type, strictMode) =>
    JS('!', '# == # || (!# && #)', type, bottom, strictMode, _isNullType(type));

// TODO(nshahan): Add support for strict/weak mode.
@notNull
bool _isTop(type) {
  // TODO(nshahan): Handle Object* in a way that ensures
  // instanceOf(null, Object*) returns true.
  if (_isFutureOr(type)) return _isTop(JS('', '#[0]', getGenericArgs(type)));
  if (_isNullable(type)) return (JS('!', '# == #', type.type, Object));

  return JS('!', '# == # || # == #', type, dynamic, type, void_);
}

/// Returns `true` if [type] represents a nullable (question, ?) type.
@notNull
bool _isNullable(Type type) => JS<bool>('!', '$type instanceof $NullableType');

/// Returns `true` if [type] represents a legacy (star, *) type.
@notNull
bool _isLegacy(Type type) => JS<bool>('!', '$type instanceof $LegacyType');

/// Returns `true` if [type] is the [Null] type.
@notNull
bool _isNullType(Object type) => identical(type, unwrapType(Null));

@notNull
bool _isFutureOr(type) =>
    identical(getGenericClass(type), getGenericClass(FutureOr));

bool _isSubtype(t1, t2, bool strictMode) => JS('bool', '''(() => {
  if (!$strictMode) {
    // Strip nullable types when performing check in weak mode.
    // TODO(nshahan) Investigate stripping off legacy types as well.
    if (${_isNullable(t1)}) {
      t1 = t1.type;
    }
    if (${_isNullable(t2)}) {
      t2 = t2.type;
    }
  }
  if ($t1 === $t2) {
    return true;
  }

  // Trivially true, "Right Top" or "Left Bottom".
  if (${_isTop(t2)} || ${_isBottom(t1, strictMode)}) {
    return true;
  }

  // "Left Top".
  if ($t1 == $dynamic || $t1 == $void_) {
    return $_isSubtype($nullable($Object), $t2, $strictMode);
  }

  // "Right Object".
  if ($t2 == $Object) {
    // TODO(nshahan) Need to handle type variables.
    // https://github.com/dart-lang/sdk/issues/38816
    if (${_isFutureOr(t1)}) {
      let t1TypeArg = ${getGenericArgs(t1)}[0];
      return $_isSubtype(t1TypeArg, $Object, $strictMode);
    }

    if (${_isLegacy(t1)}) {
      return $_isSubtype(t1.type, t2, $strictMode);
    }

    if (${_isNullType(t1)} || ${_isNullable(t1)}) {
      // Checks for t1 is dynamic or void already performed in "Left Top" test.
      return false;
    }
    return true;
  }

  // "Left Null".
  if ($t1 == $Null) {
    // TODO(nshahan) Need to handle type variables.
    // https://github.com/dart-lang/sdk/issues/38816
    if (${_isFutureOr(t2)}) {
      let t2TypeArg = ${getGenericArgs(t2)}[0];
      return $_isSubtype($Null, t2TypeArg, $strictMode);
    }

    return $t2 == $Null || ${_isLegacy(t2)} || ${_isNullable(t2)};
  }

  // "Left Legacy".
  if (${_isLegacy(t1)}) {
    return $_isSubtype(t1.type, t2, $strictMode);
  }

  // "Right Legacy".
  if (${_isLegacy(t2)}) {
    return $_isSubtype(t1, $nullable(t2.type), $strictMode);
  }

  // Handle FutureOr<T> union type.
  if (${_isFutureOr(t1)}) {
    let t1TypeArg = ${getGenericArgs(t1)}[0];
    if (${_isFutureOr(t2)}) {
      let t2TypeArg = ${getGenericArgs(t2)}[0];
      // FutureOr<A> <: FutureOr<B> iff A <: B
      // TODO(nshahan): Proven to not actually be true and needs cleanup.
      // https://github.com/dart-lang/sdk/issues/38818
      return $_isSubtype(t1TypeArg, t2TypeArg, $strictMode);
    }

    // given t1 is Future<A> | A, then:
    // (Future<A> | A) <: t2 iff Future<A> <: t2 and A <: t2.
    let t1Future = ${getGenericClass(Future)}(t1TypeArg);
    // Known to handle the case FutureOr<Null> <: Future<Null>.
    return $_isSubtype(t1Future, $t2, $strictMode) && $_isSubtype(t1TypeArg, $t2, $strictMode);
  }

  // "Left Nullable".
  if (${_isNullable(t1)}) {
    // TODO(nshahan) Need to handle type variables.
    // https://github.com/dart-lang/sdk/issues/38816
    return $_isSubtype(t1.type, t2, $strictMode) && $_isSubtype($Null, t2, $strictMode);
  }

  if ($_isFutureOr($t2)) {
    // given t2 is Future<A> | A, then:
    // t1 <: (Future<A> | A) iff t1 <: Future<A> or t1 <: A
    let t2TypeArg = ${getGenericArgs(t2)}[0];
    let t2Future = ${getGenericClass(Future)}(t2TypeArg);
    // TODO(nshahan) Need to handle type variables on the left.
    // https://github.com/dart-lang/sdk/issues/38816
    return $_isSubtype($t1, t2Future, $strictMode) || $_isSubtype($t1, t2TypeArg, $strictMode);
  }

  // "Right Nullable".
  if (${_isNullable(t2)}) {
    // TODO(nshahan) Need to handle type variables.
    // https://github.com/dart-lang/sdk/issues/38816
    return $_isSubtype(t1, t2.type, $strictMode) || $_isSubtype(t1, $Null, $strictMode);
  }

  // "Traditional" name-based subtype check.  Avoid passing
  // function types to the class subtype checks, since we don't
  // currently distinguish between generic typedefs and classes.
  if (!($t2 instanceof $AbstractFunctionType)) {
    // t2 is an interface type.

    if ($t1 instanceof $AbstractFunctionType) {
      // Function types are only subtypes of interface types `Function` (and top
      // types, handled already above).
      return $t2 === $Function;
    }

    // All JS types are subtypes of anonymous JS types.
    if ($t1 === $jsobject && $t2 instanceof $AnonymousJSType) {
      return true;
    }

    // Compare two interface types.
    return ${_isInterfaceSubtype(t1, t2, strictMode)};
  }

  // Function subtyping.
  if (!($t1 instanceof $AbstractFunctionType)) {
    return false;
  }

  // Handle generic functions.
  if ($t1 instanceof $GenericFunctionType) {
    if (!($t2 instanceof $GenericFunctionType)) {
      return false;
    }

    // Given generic functions g1 and g2, g1 <: g2 iff:
    //
    //     g1<TFresh> <: g2<TFresh>
    //
    // where TFresh is a list of fresh type variables that both g1 and g2 will
    // be instantiated with.
    let formalCount = $t1.formalCount;
    if (formalCount !== $t2.formalCount) {
      return false;
    }

    // Using either function's type formals will work as long as they're both
    // instantiated with the same ones. The instantiate operation is guaranteed
    // to avoid capture because it does not depend on its TypeVariable objects,
    // rather it uses JS function parameters to ensure correct binding.
    let fresh = $t2.typeFormals;

    // Without type bounds all will instantiate to dynamic. Only need to check
    // further if at least one of the functions has type bounds.
    if ($t1.hasTypeBounds || $t2.hasTypeBounds) {
      // Check the bounds of the type parameters of g1 and g2.
      // given a type parameter `T1 extends U1` from g1, and a type parameter
      // `T2 extends U2` from g2, we must ensure that:
      //
      //      U2 == U1
      //
      // (Note there is no variance in the type bounds of type parameters of
      // generic functions).
      let t1Bounds = $t1.instantiateTypeBounds(fresh);
      let t2Bounds = $t2.instantiateTypeBounds(fresh);
      for (let i = 0; i < formalCount; i++) {
        if (t2Bounds[i] != t1Bounds[i]) {
          return false;
        }
      }
    }

    $t1 = $t1.instantiate(fresh);
    $t2 = $t2.instantiate(fresh);
  } else if ($t2 instanceof $GenericFunctionType) {
    return false;
  }

  // Handle non-generic functions.
  return ${_isFunctionSubtype(t1, t2, strictMode)};
})()''');

bool _isInterfaceSubtype(t1, t2, strictMode) => JS('', '''(() => {
  // If we have lazy JS types, unwrap them.  This will effectively
  // reduce to a prototype check below.
  if ($t1 instanceof $LazyJSType) $t1 = $t1.rawJSTypeForCheck();
  if ($t2 instanceof $LazyJSType) $t2 = $t2.rawJSTypeForCheck();

  if ($t1 === $t2) {
    return true;
  }
  if ($t1 === $Object) {
    return false;
  }

  // Classes cannot subtype `Function` or vice versa.
  if ($t1 === $Function || $t2 === $Function) {
    return false;
  }

  // If t1 is a JS Object, we may not hit core.Object.
  if ($t1 == null) {
    return $t2 == $Object || $t2 == $dynamic;
  }

  // Check if t1 and t2 have the same raw type.  If so, check covariance on
  // type parameters.
  let raw1 = $getGenericClass($t1);
  let raw2 = $getGenericClass($t2);
  if (raw1 != null && raw1 == raw2) {
    let typeArguments1 = $getGenericArgs($t1);
    let typeArguments2 = $getGenericArgs($t2);
    if (typeArguments1.length != typeArguments2.length) {
      $assertFailed();
    }
    let variances = $getGenericArgVariances($t1);
    for (let i = 0; i < typeArguments1.length; ++i) {
      // When using implicit variance, variances will be undefined and
      // considered covariant.
      if (variances === void 0 || variances[i] == ${Variance.covariant}) {
        if (!$_isSubtype(typeArguments1[i], typeArguments2[i], $strictMode)) {
          return false;
        }
      } else if (variances[i] == ${Variance.contravariant}) {
        if (!$_isSubtype(typeArguments2[i], typeArguments1[i], $strictMode)) {
          return false;
        }
      } else if (variances[i] == ${Variance.invariant}) {
        if (!$_isSubtype(typeArguments1[i], typeArguments2[i], $strictMode) ||
            !$_isSubtype(typeArguments2[i], typeArguments1[i], $strictMode)) {
          return false;
        }
      }
    }
    return true;
  }

  if ($_isInterfaceSubtype(t1.__proto__, $t2, $strictMode)) {
    return true;
  }

  // Check mixin.
  let m1 = $getMixin($t1);
  if (m1 != null && $_isInterfaceSubtype(m1, $t2, $strictMode)) {
    return true;
  }

  // Check interfaces.
  let getInterfaces = $getImplements($t1);
  if (getInterfaces) {
    for (let i1 of getInterfaces()) {
      if ($_isInterfaceSubtype(i1, $t2, $strictMode)) {
        return true;
      }
    }
  }
  return false;
})()''');

Object extractTypeArguments<T>(T instance, Function f) {
  if (instance == null) {
    throw ArgumentError('Cannot extract type of null instance.');
  }
  var type = unwrapType(T);
  if (type is AbstractFunctionType || _isFutureOr(type)) {
    throw ArgumentError('Cannot extract from non-class type ($type).');
  }
  var typeArguments = getGenericArgs(type);
  if (typeArguments!.isEmpty) {
    throw ArgumentError('Cannot extract from non-generic type ($type).');
  }
  var supertype = _getMatchingSupertype(getReifiedType(instance), type);
  // The signature of this method guarantees that instance is a T, so we
  // should have a valid non-empty list at this point.
  assert(supertype != null);
  var typeArgs = getGenericArgs(supertype);
  assert(typeArgs != null && typeArgs.isNotEmpty);
  return dgcall(f, typeArgs, []);
}

/// Infers type variables based on a series of [trySubtypeMatch] calls, followed
/// by [getInferredTypes] to return the type.
class _TypeInferrer {
  final Map<TypeVariable, TypeConstraint> _typeVariables;

  /// Creates a [TypeConstraintGatherer] which is prepared to gather type
  /// constraints for the given type parameters.
  _TypeInferrer(Iterable<TypeVariable> typeVariables)
      : _typeVariables = Map.fromIterables(
            typeVariables, typeVariables.map((_) => TypeConstraint()));

  /// Returns the inferred types based on the current constraints.
  List<Object>? getInferredTypes() {
    var result = List<Object>();
    for (var constraint in _typeVariables.values) {
      // Prefer the known bound, if any.
      if (constraint.lower != null) {
        result.add(constraint.lower!);
      } else if (constraint.upper != null) {
        result.add(constraint.upper!);
      } else {
        return null;
      }
    }
    return result;
  }

  /// Tries to match [subtype] against [supertype].
  ///
  /// If the match succeeds, the resulting type constraints are recorded for
  /// later use by [computeConstraints].  If the match fails, the set of type
  /// constraints is unchanged.
  bool trySubtypeMatch(Object subtype, Object supertype) =>
      _isSubtypeMatch(subtype, supertype);

  void _constrainLower(TypeVariable parameter, Object lower) {
    _typeVariables[parameter]!._constrainLower(lower);
  }

  void _constrainUpper(TypeVariable parameter, Object upper) {
    _typeVariables[parameter]!._constrainUpper(upper);
  }

  bool _isFunctionSubtypeMatch(FunctionType subtype, FunctionType supertype) {
    // A function type `(M0,..., Mn, [M{n+1}, ..., Mm]) -> R0` is a subtype
    // match for a function type `(N0,..., Nk, [N{k+1}, ..., Nr]) -> R1` with
    // respect to `L` under constraints `C0 + ... + Cr + C`
    // - If `R0` is a subtype match for a type `R1` with respect to `L` under
    //   constraints `C`:
    // - If `n <= k` and `r <= m`.
    // - And for `i` in `0...r`, `Ni` is a subtype match for `Mi` with respect
    //   to `L` under constraints `Ci`.
    // Function types with named parameters are treated analogously to the
    // positional parameter case above.
    // A generic function type `<T0 extends B0, ..., Tn extends Bn>F0` is a
    // subtype match for a generic function type `<S0 extends B0, ..., Sn
    // extends Bn>F1` with respect to `L` under constraints `Cl`:
    // - If `F0[Z0/T0, ..., Zn/Tn]` is a subtype match for `F0[Z0/S0, ...,
    //   Zn/Sn]` with respect to `L` under constraints `C`, where each `Zi` is a
    //   fresh type variable with bound `Bi`.
    // - And `Cl` is `C` with each constraint replaced with its closure with
    //   respect to `[Z0, ..., Zn]`.
    if (subtype.requiredParameterCount > supertype.requiredParameterCount) {
      return false;
    }
    if (subtype.positionalParameterCount < supertype.positionalParameterCount) {
      return false;
    }
    // Test the return types.
    if (supertype.returnType is! VoidType &&
        !_isSubtypeMatch(subtype.returnType, supertype.returnType)) {
      return false;
    }

    // Test the parameter types.
    for (int i = 0, n = supertype.positionalParameterCount; i < n; ++i) {
      if (!_isSubtypeMatch(supertype.getPositionalParameter(i),
          subtype.getPositionalParameter(i))) {
        return false;
      }
    }

    // Named parameter invariants:
    // 1) All named params in the superclass are named params in the subclass.
    // 2) All required named params in the subclass are required named params
    //    in the superclass.
    var supertypeNamed = supertype.getNamedParameters();
    var supertypeRequiredNamed = supertype.getRequiredNamedParameters();
    var subtypeNamed = supertype.getNamedParameters();
    var subtypeRequiredNamed = supertype.getRequiredNamedParameters();
    for (var name in subtypeRequiredNamed.keys) {
      var supertypeParamType = supertypeRequiredNamed[name];
      if (supertypeParamType == null) return false;
    }
    for (var name in supertypeNamed.keys) {
      var subtypeParamType = subtypeNamed[name];
      if (subtypeParamType == null) return false;
      if (!_isSubtypeMatch(supertypeNamed[name]!, subtypeParamType)) {
        return false;
      }
    }
    for (var name in supertypeRequiredNamed.keys) {
      var subtypeParamType = subtypeRequiredNamed[name] ?? subtypeNamed[name];
      if (!_isSubtypeMatch(supertypeRequiredNamed[name]!, subtypeParamType)) {
        return false;
      }
    }
    return true;
  }

  bool _isInterfaceSubtypeMatch(Object subtype, Object supertype) {
    // A type `P<M0, ..., Mk>` is a subtype match for `P<N0, ..., Nk>` with
    // respect to `L` under constraints `C0 + ... + Ck`:
    // - If `Mi` is a subtype match for `Ni` with respect to `L` under
    //   constraints `Ci`.
    // A type `P<M0, ..., Mk>` is a subtype match for `Q<N0, ..., Nj>` with
    // respect to `L` under constraints `C`:
    // - If `R<B0, ..., Bj>` is the superclass of `P<M0, ..., Mk>` and `R<B0,
    //   ..., Bj>` is a subtype match for `Q<N0, ..., Nj>` with respect to `L`
    //   under constraints `C`.
    // - Or `R<B0, ..., Bj>` is one of the interfaces implemented by `P<M0, ...,
    //   Mk>` (considered in lexical order) and `R<B0, ..., Bj>` is a subtype
    //   match for `Q<N0, ..., Nj>` with respect to `L` under constraints `C`.
    // - Or `R<B0, ..., Bj>` is a mixin into `P<M0, ..., Mk>` (considered in
    //   lexical order) and `R<B0, ..., Bj>` is a subtype match for `Q<N0, ...,
    //   Nj>` with respect to `L` under constraints `C`.

    // Note that since kernel requires that no class may only appear in the set
    // of supertypes of a given type more than once, the order of the checks
    // above is irrelevant; we just need to find the matched superclass,
    // substitute, and then iterate through type variables.
    var matchingSupertype = _getMatchingSupertype(subtype, supertype);
    if (matchingSupertype == null) return false;

    var matchingTypeArgs = getGenericArgs(matchingSupertype)!;
    var supertypeTypeArgs = getGenericArgs(supertype)!;
    for (int i = 0; i < supertypeTypeArgs.length; i++) {
      if (!_isSubtypeMatch(matchingTypeArgs[i], supertypeTypeArgs[i])) {
        return false;
      }
    }
    return true;
  }

  /// Attempts to match [subtype] as a subtype of [supertype], gathering any
  /// constraints discovered in the process.
  ///
  /// If a set of constraints was found, `true` is returned and the caller
  /// may proceed to call [computeConstraints].  Otherwise, `false` is returned.
  ///
  /// In the case where `false` is returned, some bogus constraints may have
  /// been added to [_protoConstraints].  It is the caller's responsibility to
  /// discard them if necessary.
  bool _isSubtypeMatch(Object subtype, Object supertype) {
    // A type variable `T` in `L` is a subtype match for any type schema `Q`:
    // - Under constraint `T <: Q`.
    if (subtype is TypeVariable && _typeVariables.containsKey(subtype)) {
      _constrainUpper(subtype, supertype);
      return true;
    }
    // A type schema `Q` is a subtype match for a type variable `T` in `L`:
    // - Under constraint `Q <: T`.
    if (supertype is TypeVariable && _typeVariables.containsKey(supertype)) {
      _constrainLower(supertype, subtype);
      return true;
    }
    // Any two equal types `P` and `Q` are subtype matches under no constraints.
    // Note: to avoid making the algorithm quadratic, we just check for
    // identical().  If P and Q are equal but not identical, recursing through
    // the types will give the proper result.
    if (identical(subtype, supertype)) return true;
    // Any type `P` is a subtype match for `dynamic`, `Object`, or `void` under
    // no constraints.
    if (_isTop(supertype)) return true;
    // `Null` is a subtype match for any type `Q` under no constraints.
    // Note that nullable types will change this.
    if (_isNullType(subtype)) return true;

    // Handle FutureOr<T> union type.
    if (_isFutureOr(subtype)) {
      var subtypeArg = getGenericArgs(subtype)![0];
      if (_isFutureOr(supertype)) {
        // `FutureOr<P>` is a subtype match for `FutureOr<Q>` with respect to `L`
        // under constraints `C`:
        // - If `P` is a subtype match for `Q` with respect to `L` under constraints
        //   `C`.
        var supertypeArg = getGenericArgs(supertype)![0];
        return _isSubtypeMatch(subtypeArg, supertypeArg);
      }

      // `FutureOr<P>` is a subtype match for `Q` with respect to `L` under
      // constraints `C0 + C1`:
      // - If `Future<P>` is a subtype match for `Q` with respect to `L` under
      //   constraints `C0`.
      // - And `P` is a subtype match for `Q` with respect to `L` under
      //   constraints `C1`.
      var subtypeFuture =
          JS<Object>('!', '#(#)', getGenericClass(Future), subtypeArg);
      return _isSubtypeMatch(subtypeFuture, supertype) &&
          _isSubtypeMatch(subtypeArg!, supertype);
    }

    if (_isFutureOr(supertype)) {
      // `P` is a subtype match for `FutureOr<Q>` with respect to `L` under
      // constraints `C`:
      // - If `P` is a subtype match for `Future<Q>` with respect to `L` under
      //   constraints `C`.
      // - Or `P` is not a subtype match for `Future<Q>` with respect to `L` under
      //   constraints `C`
      //   - And `P` is a subtype match for `Q` with respect to `L` under
      //     constraints `C`
      var supertypeArg = getGenericArgs(supertype)![0];
      var supertypeFuture =
          JS<Object>('!', '#(#)', getGenericClass(Future), supertypeArg);
      return _isSubtypeMatch(subtype, supertypeFuture) ||
          _isSubtypeMatch(subtype, supertypeArg);
    }

    // A type variable `T` not in `L` with bound `P` is a subtype match for the
    // same type variable `T` with bound `Q` with respect to `L` under
    // constraints `C`:
    // - If `P` is a subtype match for `Q` with respect to `L` under constraints
    //   `C`.
    if (subtype is TypeVariable) {
      return supertype is TypeVariable && identical(subtype, supertype);
    }
    if (subtype is GenericFunctionType) {
      if (supertype is GenericFunctionType) {
        // Given generic functions g1 and g2, g1 <: g2 iff:
        //
        //     g1<TFresh> <: g2<TFresh>
        //
        // where TFresh is a list of fresh type variables that both g1 and g2 will
        // be instantiated with.
        var formalCount = subtype.formalCount;
        if (formalCount != supertype.formalCount) return false;

        // Using either function's type formals will work as long as they're
        // both instantiated with the same ones. The instantiate operation is
        // guaranteed to avoid capture because it does not depend on its
        // TypeVariable objects, rather it uses JS function parameters to ensure
        // correct binding.
        var fresh = supertype.typeFormals;

        // Check the bounds of the type parameters of g1 and g2.
        // given a type parameter `T1 extends U1` from g1, and a type parameter
        // `T2 extends U2` from g2, we must ensure that:
        //
        //      U2 <: U1
        //
        // (Note the reversal of direction -- type formal bounds are
        // contravariant, similar to the function's formal parameter types).
        //
        var t1Bounds = subtype.instantiateTypeBounds(fresh);
        var t2Bounds = supertype.instantiateTypeBounds(fresh);
        // TODO(jmesserly): we could optimize for the common case of no bounds.
        for (var i = 0; i < formalCount; i++) {
          if (!_isSubtypeMatch(t2Bounds[i], t1Bounds[i])) {
            return false;
          }
        }
        return _isFunctionSubtypeMatch(
            subtype.instantiate(fresh), supertype.instantiate(fresh));
      } else {
        return false;
      }
    } else if (supertype is GenericFunctionType) {
      return false;
    }

    // A type `P` is a subtype match for `Function` with respect to `L` under no
    // constraints:
    // - If `P` implements a call method.
    // - Or if `P` is a function type.
    // TODO(paulberry): implement this case.
    // A type `P` is a subtype match for a type `Q` with respect to `L` under
    // constraints `C`:
    // - If `P` is an interface type which implements a call method of type `F`,
    //   and `F` is a subtype match for a type `Q` with respect to `L` under
    //   constraints `C`.
    // TODO(paulberry): implement this case.
    if (subtype is FunctionType) {
      if (supertype is! FunctionType) {
        if (identical(supertype, unwrapType(Function)) ||
            identical(supertype, unwrapType(Object))) {
          return true;
        } else {
          return false;
        }
      }
      if (supertype is FunctionType) {
        return _isFunctionSubtypeMatch(subtype, supertype);
      }
    }
    return _isInterfaceSubtypeMatch(subtype, supertype);
  }

  bool _isTop(Object type) =>
      identical(type, _dynamic) ||
      identical(type, void_) ||
      identical(type, unwrapType(Object));
}

/// A constraint on a type parameter that we're inferring.
class TypeConstraint {
  /// The lower bound of the type being constrained.  This bound must be a
  /// subtype of the type being constrained.
  Object? lower;

  /// The upper bound of the type being constrained.  The type being constrained
  /// must be a subtype of this bound.
  Object? upper;

  void _constrainLower(Object type) {
    var _lower = lower;
    if (_lower != null) {
      if (isSubtypeOf(_lower, type)) {
        // nothing to do, existing lower bound is lower than the new one.
        return;
      }
      if (!isSubtypeOf(type, _lower)) {
        // Neither bound is lower and we don't have GLB, so use bottom type.
        type = unwrapType(Null);
      }
    }
    lower = type;
  }

  void _constrainUpper(Object type) {
    var _upper = upper;
    if (_upper != null) {
      if (isSubtypeOf(type, _upper)) {
        // nothing to do, existing upper bound is higher than the new one.
        return;
      }
      if (!isSubtypeOf(_upper, type)) {
        // Neither bound is higher and we don't have LUB, so use top type.
        type = unwrapType(Object);
      }
    }
    upper = type;
  }

  String toString() => '${typeName(lower)} <: <type> <: ${typeName(upper)}';
}

/// Finds a supertype of [subtype] that matches the class [supertype], but may
/// contain different generic type arguments.
Object? _getMatchingSupertype(Object? subtype, Object supertype) {
  if (identical(subtype, supertype)) return supertype;
  if (subtype == null || subtype == unwrapType(Object)) return null;

  var subclass = getGenericClass(subtype);
  var superclass = getGenericClass(supertype);
  if (subclass != null && identical(subclass, superclass)) {
    return subtype; // matching supertype found!
  }

  var result = _getMatchingSupertype(JS('', '#.__proto__', subtype), supertype);
  if (result != null) return result;

  // Check mixin.
  var mixin = getMixin(subtype);
  if (mixin != null) {
    result = _getMatchingSupertype(mixin, supertype);
    if (result != null) return result;
  }

  // Check interfaces.
  var getInterfaces = getImplements(subtype);
  if (getInterfaces != null) {
    for (var iface in getInterfaces()!) {
      result = _getMatchingSupertype(iface, supertype);
      if (result != null) return result;
    }
  }

  return null;
}
