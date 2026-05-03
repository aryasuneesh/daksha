// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inference_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InferenceRequest {

 String get prompt; int get maxTokens; double get temperature; String? get grammarBnf;// optional GBNF grammar for constrained output
 String? get imagePath;
/// Create a copy of InferenceRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InferenceRequestCopyWith<InferenceRequest> get copyWith => _$InferenceRequestCopyWithImpl<InferenceRequest>(this as InferenceRequest, _$identity);

  /// Serializes this InferenceRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InferenceRequest&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.maxTokens, maxTokens) || other.maxTokens == maxTokens)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.grammarBnf, grammarBnf) || other.grammarBnf == grammarBnf)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,maxTokens,temperature,grammarBnf,imagePath);

@override
String toString() {
  return 'InferenceRequest(prompt: $prompt, maxTokens: $maxTokens, temperature: $temperature, grammarBnf: $grammarBnf, imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class $InferenceRequestCopyWith<$Res>  {
  factory $InferenceRequestCopyWith(InferenceRequest value, $Res Function(InferenceRequest) _then) = _$InferenceRequestCopyWithImpl;
@useResult
$Res call({
 String prompt, int maxTokens, double temperature, String? grammarBnf, String? imagePath
});




}
/// @nodoc
class _$InferenceRequestCopyWithImpl<$Res>
    implements $InferenceRequestCopyWith<$Res> {
  _$InferenceRequestCopyWithImpl(this._self, this._then);

  final InferenceRequest _self;
  final $Res Function(InferenceRequest) _then;

/// Create a copy of InferenceRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prompt = null,Object? maxTokens = null,Object? temperature = null,Object? grammarBnf = freezed,Object? imagePath = freezed,}) {
  return _then(_self.copyWith(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,maxTokens: null == maxTokens ? _self.maxTokens : maxTokens // ignore: cast_nullable_to_non_nullable
as int,temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,grammarBnf: freezed == grammarBnf ? _self.grammarBnf : grammarBnf // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InferenceRequest].
extension InferenceRequestPatterns on InferenceRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InferenceRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InferenceRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InferenceRequest value)  $default,){
final _that = this;
switch (_that) {
case _InferenceRequest():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InferenceRequest value)?  $default,){
final _that = this;
switch (_that) {
case _InferenceRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String prompt,  int maxTokens,  double temperature,  String? grammarBnf,  String? imagePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InferenceRequest() when $default != null:
return $default(_that.prompt,_that.maxTokens,_that.temperature,_that.grammarBnf,_that.imagePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String prompt,  int maxTokens,  double temperature,  String? grammarBnf,  String? imagePath)  $default,) {final _that = this;
switch (_that) {
case _InferenceRequest():
return $default(_that.prompt,_that.maxTokens,_that.temperature,_that.grammarBnf,_that.imagePath);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String prompt,  int maxTokens,  double temperature,  String? grammarBnf,  String? imagePath)?  $default,) {final _that = this;
switch (_that) {
case _InferenceRequest() when $default != null:
return $default(_that.prompt,_that.maxTokens,_that.temperature,_that.grammarBnf,_that.imagePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InferenceRequest implements InferenceRequest {
  const _InferenceRequest({required this.prompt, this.maxTokens = 512, this.temperature = 0.7, this.grammarBnf, this.imagePath});
  factory _InferenceRequest.fromJson(Map<String, dynamic> json) => _$InferenceRequestFromJson(json);

@override final  String prompt;
@override@JsonKey() final  int maxTokens;
@override@JsonKey() final  double temperature;
@override final  String? grammarBnf;
// optional GBNF grammar for constrained output
@override final  String? imagePath;

/// Create a copy of InferenceRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InferenceRequestCopyWith<_InferenceRequest> get copyWith => __$InferenceRequestCopyWithImpl<_InferenceRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InferenceRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InferenceRequest&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.maxTokens, maxTokens) || other.maxTokens == maxTokens)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.grammarBnf, grammarBnf) || other.grammarBnf == grammarBnf)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,maxTokens,temperature,grammarBnf,imagePath);

@override
String toString() {
  return 'InferenceRequest(prompt: $prompt, maxTokens: $maxTokens, temperature: $temperature, grammarBnf: $grammarBnf, imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class _$InferenceRequestCopyWith<$Res> implements $InferenceRequestCopyWith<$Res> {
  factory _$InferenceRequestCopyWith(_InferenceRequest value, $Res Function(_InferenceRequest) _then) = __$InferenceRequestCopyWithImpl;
@override @useResult
$Res call({
 String prompt, int maxTokens, double temperature, String? grammarBnf, String? imagePath
});




}
/// @nodoc
class __$InferenceRequestCopyWithImpl<$Res>
    implements _$InferenceRequestCopyWith<$Res> {
  __$InferenceRequestCopyWithImpl(this._self, this._then);

  final _InferenceRequest _self;
  final $Res Function(_InferenceRequest) _then;

/// Create a copy of InferenceRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prompt = null,Object? maxTokens = null,Object? temperature = null,Object? grammarBnf = freezed,Object? imagePath = freezed,}) {
  return _then(_InferenceRequest(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,maxTokens: null == maxTokens ? _self.maxTokens : maxTokens // ignore: cast_nullable_to_non_nullable
as int,temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,grammarBnf: freezed == grammarBnf ? _self.grammarBnf : grammarBnf // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$InferenceResponse {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InferenceResponse);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'InferenceResponse()';
}


}

/// @nodoc
class $InferenceResponseCopyWith<$Res>  {
$InferenceResponseCopyWith(InferenceResponse _, $Res Function(InferenceResponse) __);
}


/// Adds pattern-matching-related methods to [InferenceResponse].
extension InferenceResponsePatterns on InferenceResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( InferenceSuccess value)?  success,TResult Function( InferenceFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case InferenceSuccess() when success != null:
return success(_that);case InferenceFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( InferenceSuccess value)  success,required TResult Function( InferenceFailure value)  failure,}){
final _that = this;
switch (_that) {
case InferenceSuccess():
return success(_that);case InferenceFailure():
return failure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( InferenceSuccess value)?  success,TResult? Function( InferenceFailure value)?  failure,}){
final _that = this;
switch (_that) {
case InferenceSuccess() when success != null:
return success(_that);case InferenceFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text,  int tokensGenerated)?  success,TResult Function( String error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case InferenceSuccess() when success != null:
return success(_that.text,_that.tokensGenerated);case InferenceFailure() when failure != null:
return failure(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text,  int tokensGenerated)  success,required TResult Function( String error)  failure,}) {final _that = this;
switch (_that) {
case InferenceSuccess():
return success(_that.text,_that.tokensGenerated);case InferenceFailure():
return failure(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text,  int tokensGenerated)?  success,TResult? Function( String error)?  failure,}) {final _that = this;
switch (_that) {
case InferenceSuccess() when success != null:
return success(_that.text,_that.tokensGenerated);case InferenceFailure() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class InferenceSuccess implements InferenceResponse {
  const InferenceSuccess({required this.text, this.tokensGenerated = 0});
  

 final  String text;
@JsonKey() final  int tokensGenerated;

/// Create a copy of InferenceResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InferenceSuccessCopyWith<InferenceSuccess> get copyWith => _$InferenceSuccessCopyWithImpl<InferenceSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InferenceSuccess&&(identical(other.text, text) || other.text == text)&&(identical(other.tokensGenerated, tokensGenerated) || other.tokensGenerated == tokensGenerated));
}


@override
int get hashCode => Object.hash(runtimeType,text,tokensGenerated);

@override
String toString() {
  return 'InferenceResponse.success(text: $text, tokensGenerated: $tokensGenerated)';
}


}

/// @nodoc
abstract mixin class $InferenceSuccessCopyWith<$Res> implements $InferenceResponseCopyWith<$Res> {
  factory $InferenceSuccessCopyWith(InferenceSuccess value, $Res Function(InferenceSuccess) _then) = _$InferenceSuccessCopyWithImpl;
@useResult
$Res call({
 String text, int tokensGenerated
});




}
/// @nodoc
class _$InferenceSuccessCopyWithImpl<$Res>
    implements $InferenceSuccessCopyWith<$Res> {
  _$InferenceSuccessCopyWithImpl(this._self, this._then);

  final InferenceSuccess _self;
  final $Res Function(InferenceSuccess) _then;

/// Create a copy of InferenceResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,Object? tokensGenerated = null,}) {
  return _then(InferenceSuccess(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,tokensGenerated: null == tokensGenerated ? _self.tokensGenerated : tokensGenerated // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class InferenceFailure implements InferenceResponse {
  const InferenceFailure({required this.error});
  

 final  String error;

/// Create a copy of InferenceResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InferenceFailureCopyWith<InferenceFailure> get copyWith => _$InferenceFailureCopyWithImpl<InferenceFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InferenceFailure&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'InferenceResponse.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class $InferenceFailureCopyWith<$Res> implements $InferenceResponseCopyWith<$Res> {
  factory $InferenceFailureCopyWith(InferenceFailure value, $Res Function(InferenceFailure) _then) = _$InferenceFailureCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$InferenceFailureCopyWithImpl<$Res>
    implements $InferenceFailureCopyWith<$Res> {
  _$InferenceFailureCopyWithImpl(this._self, this._then);

  final InferenceFailure _self;
  final $Res Function(InferenceFailure) _then;

/// Create a copy of InferenceResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(InferenceFailure(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
