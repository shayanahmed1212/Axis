// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_validation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskValidation {

 bool get isValid; List<String>? get errors;
/// Create a copy of TaskValidation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskValidationCopyWith<TaskValidation> get copyWith => _$TaskValidationCopyWithImpl<TaskValidation>(this as TaskValidation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskValidation&&(identical(other.isValid, isValid) || other.isValid == isValid)&&const DeepCollectionEquality().equals(other.errors, errors));
}


@override
int get hashCode => Object.hash(runtimeType,isValid,const DeepCollectionEquality().hash(errors));

@override
String toString() {
  return 'TaskValidation(isValid: $isValid, errors: $errors)';
}


}

/// @nodoc
abstract mixin class $TaskValidationCopyWith<$Res>  {
  factory $TaskValidationCopyWith(TaskValidation value, $Res Function(TaskValidation) _then) = _$TaskValidationCopyWithImpl;
@useResult
$Res call({
 bool isValid, List<String>? errors
});




}
/// @nodoc
class _$TaskValidationCopyWithImpl<$Res>
    implements $TaskValidationCopyWith<$Res> {
  _$TaskValidationCopyWithImpl(this._self, this._then);

  final TaskValidation _self;
  final $Res Function(TaskValidation) _then;

/// Create a copy of TaskValidation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isValid = null,Object? errors = freezed,}) {
  return _then(_self.copyWith(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,errors: freezed == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskValidation].
extension TaskValidationPatterns on TaskValidation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskValidation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskValidation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskValidation value)  $default,){
final _that = this;
switch (_that) {
case _TaskValidation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskValidation value)?  $default,){
final _that = this;
switch (_that) {
case _TaskValidation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isValid,  List<String>? errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskValidation() when $default != null:
return $default(_that.isValid,_that.errors);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isValid,  List<String>? errors)  $default,) {final _that = this;
switch (_that) {
case _TaskValidation():
return $default(_that.isValid,_that.errors);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isValid,  List<String>? errors)?  $default,) {final _that = this;
switch (_that) {
case _TaskValidation() when $default != null:
return $default(_that.isValid,_that.errors);case _:
  return null;

}
}

}

/// @nodoc


class _TaskValidation extends TaskValidation {
  const _TaskValidation({required this.isValid, final  List<String>? errors}): _errors = errors,super._();
  

@override final  bool isValid;
 final  List<String>? _errors;
@override List<String>? get errors {
  final value = _errors;
  if (value == null) return null;
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of TaskValidation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskValidationCopyWith<_TaskValidation> get copyWith => __$TaskValidationCopyWithImpl<_TaskValidation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskValidation&&(identical(other.isValid, isValid) || other.isValid == isValid)&&const DeepCollectionEquality().equals(other._errors, _errors));
}


@override
int get hashCode => Object.hash(runtimeType,isValid,const DeepCollectionEquality().hash(_errors));

@override
String toString() {
  return 'TaskValidation(isValid: $isValid, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$TaskValidationCopyWith<$Res> implements $TaskValidationCopyWith<$Res> {
  factory _$TaskValidationCopyWith(_TaskValidation value, $Res Function(_TaskValidation) _then) = __$TaskValidationCopyWithImpl;
@override @useResult
$Res call({
 bool isValid, List<String>? errors
});




}
/// @nodoc
class __$TaskValidationCopyWithImpl<$Res>
    implements _$TaskValidationCopyWith<$Res> {
  __$TaskValidationCopyWithImpl(this._self, this._then);

  final _TaskValidation _self;
  final $Res Function(_TaskValidation) _then;

/// Create a copy of TaskValidation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isValid = null,Object? errors = freezed,}) {
  return _then(_TaskValidation(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,errors: freezed == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
