// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TutorState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TutorState()';
}


}

/// @nodoc
class $TutorStateCopyWith<$Res>  {
$TutorStateCopyWith(TutorState _, $Res Function(TutorState) __);
}


/// Adds pattern-matching-related methods to [TutorState].
extension TutorStatePatterns on TutorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TutorIdle value)?  idle,TResult Function( TutorClassifying value)?  classifying,TResult Function( TutorAsking value)?  asking,TResult Function( TutorChecking value)?  checking,TResult Function( TutorHinting value)?  hinting,TResult Function( TutorSolved value)?  solved,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TutorIdle() when idle != null:
return idle(_that);case TutorClassifying() when classifying != null:
return classifying(_that);case TutorAsking() when asking != null:
return asking(_that);case TutorChecking() when checking != null:
return checking(_that);case TutorHinting() when hinting != null:
return hinting(_that);case TutorSolved() when solved != null:
return solved(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TutorIdle value)  idle,required TResult Function( TutorClassifying value)  classifying,required TResult Function( TutorAsking value)  asking,required TResult Function( TutorChecking value)  checking,required TResult Function( TutorHinting value)  hinting,required TResult Function( TutorSolved value)  solved,}){
final _that = this;
switch (_that) {
case TutorIdle():
return idle(_that);case TutorClassifying():
return classifying(_that);case TutorAsking():
return asking(_that);case TutorChecking():
return checking(_that);case TutorHinting():
return hinting(_that);case TutorSolved():
return solved(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TutorIdle value)?  idle,TResult? Function( TutorClassifying value)?  classifying,TResult? Function( TutorAsking value)?  asking,TResult? Function( TutorChecking value)?  checking,TResult? Function( TutorHinting value)?  hinting,TResult? Function( TutorSolved value)?  solved,}){
final _that = this;
switch (_that) {
case TutorIdle() when idle != null:
return idle(_that);case TutorClassifying() when classifying != null:
return classifying(_that);case TutorAsking() when asking != null:
return asking(_that);case TutorChecking() when checking != null:
return checking(_that);case TutorHinting() when hinting != null:
return hinting(_that);case TutorSolved() when solved != null:
return solved(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( String problemText)?  classifying,TResult Function( String problemText,  Topic topic,  String opener,  String problemId)?  asking,TResult Function( String problemText,  Topic topic,  String attempt,  String problemId)?  checking,TResult Function( String problemText,  Topic topic,  int level,  String hint,  String problemId,  DateTime firstHintAt)?  hinting,TResult Function( String problemId)?  solved,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TutorIdle() when idle != null:
return idle();case TutorClassifying() when classifying != null:
return classifying(_that.problemText);case TutorAsking() when asking != null:
return asking(_that.problemText,_that.topic,_that.opener,_that.problemId);case TutorChecking() when checking != null:
return checking(_that.problemText,_that.topic,_that.attempt,_that.problemId);case TutorHinting() when hinting != null:
return hinting(_that.problemText,_that.topic,_that.level,_that.hint,_that.problemId,_that.firstHintAt);case TutorSolved() when solved != null:
return solved(_that.problemId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( String problemText)  classifying,required TResult Function( String problemText,  Topic topic,  String opener,  String problemId)  asking,required TResult Function( String problemText,  Topic topic,  String attempt,  String problemId)  checking,required TResult Function( String problemText,  Topic topic,  int level,  String hint,  String problemId,  DateTime firstHintAt)  hinting,required TResult Function( String problemId)  solved,}) {final _that = this;
switch (_that) {
case TutorIdle():
return idle();case TutorClassifying():
return classifying(_that.problemText);case TutorAsking():
return asking(_that.problemText,_that.topic,_that.opener,_that.problemId);case TutorChecking():
return checking(_that.problemText,_that.topic,_that.attempt,_that.problemId);case TutorHinting():
return hinting(_that.problemText,_that.topic,_that.level,_that.hint,_that.problemId,_that.firstHintAt);case TutorSolved():
return solved(_that.problemId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( String problemText)?  classifying,TResult? Function( String problemText,  Topic topic,  String opener,  String problemId)?  asking,TResult? Function( String problemText,  Topic topic,  String attempt,  String problemId)?  checking,TResult? Function( String problemText,  Topic topic,  int level,  String hint,  String problemId,  DateTime firstHintAt)?  hinting,TResult? Function( String problemId)?  solved,}) {final _that = this;
switch (_that) {
case TutorIdle() when idle != null:
return idle();case TutorClassifying() when classifying != null:
return classifying(_that.problemText);case TutorAsking() when asking != null:
return asking(_that.problemText,_that.topic,_that.opener,_that.problemId);case TutorChecking() when checking != null:
return checking(_that.problemText,_that.topic,_that.attempt,_that.problemId);case TutorHinting() when hinting != null:
return hinting(_that.problemText,_that.topic,_that.level,_that.hint,_that.problemId,_that.firstHintAt);case TutorSolved() when solved != null:
return solved(_that.problemId);case _:
  return null;

}
}

}

/// @nodoc


class TutorIdle implements TutorState {
  const TutorIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TutorState.idle()';
}


}




/// @nodoc


class TutorClassifying implements TutorState {
  const TutorClassifying(this.problemText);
  

 final  String problemText;

/// Create a copy of TutorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorClassifyingCopyWith<TutorClassifying> get copyWith => _$TutorClassifyingCopyWithImpl<TutorClassifying>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorClassifying&&(identical(other.problemText, problemText) || other.problemText == problemText));
}


@override
int get hashCode => Object.hash(runtimeType,problemText);

@override
String toString() {
  return 'TutorState.classifying(problemText: $problemText)';
}


}

/// @nodoc
abstract mixin class $TutorClassifyingCopyWith<$Res> implements $TutorStateCopyWith<$Res> {
  factory $TutorClassifyingCopyWith(TutorClassifying value, $Res Function(TutorClassifying) _then) = _$TutorClassifyingCopyWithImpl;
@useResult
$Res call({
 String problemText
});




}
/// @nodoc
class _$TutorClassifyingCopyWithImpl<$Res>
    implements $TutorClassifyingCopyWith<$Res> {
  _$TutorClassifyingCopyWithImpl(this._self, this._then);

  final TutorClassifying _self;
  final $Res Function(TutorClassifying) _then;

/// Create a copy of TutorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? problemText = null,}) {
  return _then(TutorClassifying(
null == problemText ? _self.problemText : problemText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TutorAsking implements TutorState {
  const TutorAsking({required this.problemText, required this.topic, required this.opener, required this.problemId});
  

 final  String problemText;
 final  Topic topic;
 final  String opener;
 final  String problemId;

/// Create a copy of TutorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorAskingCopyWith<TutorAsking> get copyWith => _$TutorAskingCopyWithImpl<TutorAsking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorAsking&&(identical(other.problemText, problemText) || other.problemText == problemText)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.opener, opener) || other.opener == opener)&&(identical(other.problemId, problemId) || other.problemId == problemId));
}


@override
int get hashCode => Object.hash(runtimeType,problemText,topic,opener,problemId);

@override
String toString() {
  return 'TutorState.asking(problemText: $problemText, topic: $topic, opener: $opener, problemId: $problemId)';
}


}

/// @nodoc
abstract mixin class $TutorAskingCopyWith<$Res> implements $TutorStateCopyWith<$Res> {
  factory $TutorAskingCopyWith(TutorAsking value, $Res Function(TutorAsking) _then) = _$TutorAskingCopyWithImpl;
@useResult
$Res call({
 String problemText, Topic topic, String opener, String problemId
});




}
/// @nodoc
class _$TutorAskingCopyWithImpl<$Res>
    implements $TutorAskingCopyWith<$Res> {
  _$TutorAskingCopyWithImpl(this._self, this._then);

  final TutorAsking _self;
  final $Res Function(TutorAsking) _then;

/// Create a copy of TutorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? problemText = null,Object? topic = null,Object? opener = null,Object? problemId = null,}) {
  return _then(TutorAsking(
problemText: null == problemText ? _self.problemText : problemText // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as Topic,opener: null == opener ? _self.opener : opener // ignore: cast_nullable_to_non_nullable
as String,problemId: null == problemId ? _self.problemId : problemId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TutorChecking implements TutorState {
  const TutorChecking({required this.problemText, required this.topic, required this.attempt, required this.problemId});
  

 final  String problemText;
 final  Topic topic;
 final  String attempt;
 final  String problemId;

/// Create a copy of TutorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorCheckingCopyWith<TutorChecking> get copyWith => _$TutorCheckingCopyWithImpl<TutorChecking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorChecking&&(identical(other.problemText, problemText) || other.problemText == problemText)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.attempt, attempt) || other.attempt == attempt)&&(identical(other.problemId, problemId) || other.problemId == problemId));
}


@override
int get hashCode => Object.hash(runtimeType,problemText,topic,attempt,problemId);

@override
String toString() {
  return 'TutorState.checking(problemText: $problemText, topic: $topic, attempt: $attempt, problemId: $problemId)';
}


}

/// @nodoc
abstract mixin class $TutorCheckingCopyWith<$Res> implements $TutorStateCopyWith<$Res> {
  factory $TutorCheckingCopyWith(TutorChecking value, $Res Function(TutorChecking) _then) = _$TutorCheckingCopyWithImpl;
@useResult
$Res call({
 String problemText, Topic topic, String attempt, String problemId
});




}
/// @nodoc
class _$TutorCheckingCopyWithImpl<$Res>
    implements $TutorCheckingCopyWith<$Res> {
  _$TutorCheckingCopyWithImpl(this._self, this._then);

  final TutorChecking _self;
  final $Res Function(TutorChecking) _then;

/// Create a copy of TutorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? problemText = null,Object? topic = null,Object? attempt = null,Object? problemId = null,}) {
  return _then(TutorChecking(
problemText: null == problemText ? _self.problemText : problemText // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as Topic,attempt: null == attempt ? _self.attempt : attempt // ignore: cast_nullable_to_non_nullable
as String,problemId: null == problemId ? _self.problemId : problemId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TutorHinting implements TutorState {
  const TutorHinting({required this.problemText, required this.topic, required this.level, required this.hint, required this.problemId, required this.firstHintAt});
  

 final  String problemText;
 final  Topic topic;
 final  int level;
 final  String hint;
 final  String problemId;
 final  DateTime firstHintAt;

/// Create a copy of TutorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorHintingCopyWith<TutorHinting> get copyWith => _$TutorHintingCopyWithImpl<TutorHinting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorHinting&&(identical(other.problemText, problemText) || other.problemText == problemText)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.level, level) || other.level == level)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.problemId, problemId) || other.problemId == problemId)&&(identical(other.firstHintAt, firstHintAt) || other.firstHintAt == firstHintAt));
}


@override
int get hashCode => Object.hash(runtimeType,problemText,topic,level,hint,problemId,firstHintAt);

@override
String toString() {
  return 'TutorState.hinting(problemText: $problemText, topic: $topic, level: $level, hint: $hint, problemId: $problemId, firstHintAt: $firstHintAt)';
}


}

/// @nodoc
abstract mixin class $TutorHintingCopyWith<$Res> implements $TutorStateCopyWith<$Res> {
  factory $TutorHintingCopyWith(TutorHinting value, $Res Function(TutorHinting) _then) = _$TutorHintingCopyWithImpl;
@useResult
$Res call({
 String problemText, Topic topic, int level, String hint, String problemId, DateTime firstHintAt
});




}
/// @nodoc
class _$TutorHintingCopyWithImpl<$Res>
    implements $TutorHintingCopyWith<$Res> {
  _$TutorHintingCopyWithImpl(this._self, this._then);

  final TutorHinting _self;
  final $Res Function(TutorHinting) _then;

/// Create a copy of TutorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? problemText = null,Object? topic = null,Object? level = null,Object? hint = null,Object? problemId = null,Object? firstHintAt = null,}) {
  return _then(TutorHinting(
problemText: null == problemText ? _self.problemText : problemText // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as Topic,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,hint: null == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String,problemId: null == problemId ? _self.problemId : problemId // ignore: cast_nullable_to_non_nullable
as String,firstHintAt: null == firstHintAt ? _self.firstHintAt : firstHintAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class TutorSolved implements TutorState {
  const TutorSolved({required this.problemId});
  

 final  String problemId;

/// Create a copy of TutorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorSolvedCopyWith<TutorSolved> get copyWith => _$TutorSolvedCopyWithImpl<TutorSolved>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorSolved&&(identical(other.problemId, problemId) || other.problemId == problemId));
}


@override
int get hashCode => Object.hash(runtimeType,problemId);

@override
String toString() {
  return 'TutorState.solved(problemId: $problemId)';
}


}

/// @nodoc
abstract mixin class $TutorSolvedCopyWith<$Res> implements $TutorStateCopyWith<$Res> {
  factory $TutorSolvedCopyWith(TutorSolved value, $Res Function(TutorSolved) _then) = _$TutorSolvedCopyWithImpl;
@useResult
$Res call({
 String problemId
});




}
/// @nodoc
class _$TutorSolvedCopyWithImpl<$Res>
    implements $TutorSolvedCopyWith<$Res> {
  _$TutorSolvedCopyWithImpl(this._self, this._then);

  final TutorSolved _self;
  final $Res Function(TutorSolved) _then;

/// Create a copy of TutorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? problemId = null,}) {
  return _then(TutorSolved(
problemId: null == problemId ? _self.problemId : problemId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
