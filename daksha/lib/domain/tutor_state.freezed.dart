// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TutorState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String problemText) classifying,
    required TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )
    asking,
    required TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )
    checking,
    required TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )
    hinting,
    required TResult Function(String problemId) solved,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String problemText)? classifying,
    TResult? Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult? Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult? Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult? Function(String problemId)? solved,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String problemText)? classifying,
    TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult Function(String problemId)? solved,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TutorIdle value) idle,
    required TResult Function(TutorClassifying value) classifying,
    required TResult Function(TutorAsking value) asking,
    required TResult Function(TutorChecking value) checking,
    required TResult Function(TutorHinting value) hinting,
    required TResult Function(TutorSolved value) solved,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TutorIdle value)? idle,
    TResult? Function(TutorClassifying value)? classifying,
    TResult? Function(TutorAsking value)? asking,
    TResult? Function(TutorChecking value)? checking,
    TResult? Function(TutorHinting value)? hinting,
    TResult? Function(TutorSolved value)? solved,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TutorIdle value)? idle,
    TResult Function(TutorClassifying value)? classifying,
    TResult Function(TutorAsking value)? asking,
    TResult Function(TutorChecking value)? checking,
    TResult Function(TutorHinting value)? hinting,
    TResult Function(TutorSolved value)? solved,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorStateCopyWith<$Res> {
  factory $TutorStateCopyWith(
    TutorState value,
    $Res Function(TutorState) then,
  ) = _$TutorStateCopyWithImpl<$Res, TutorState>;
}

/// @nodoc
class _$TutorStateCopyWithImpl<$Res, $Val extends TutorState>
    implements $TutorStateCopyWith<$Res> {
  _$TutorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TutorIdleImplCopyWith<$Res> {
  factory _$$TutorIdleImplCopyWith(
    _$TutorIdleImpl value,
    $Res Function(_$TutorIdleImpl) then,
  ) = __$$TutorIdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TutorIdleImplCopyWithImpl<$Res>
    extends _$TutorStateCopyWithImpl<$Res, _$TutorIdleImpl>
    implements _$$TutorIdleImplCopyWith<$Res> {
  __$$TutorIdleImplCopyWithImpl(
    _$TutorIdleImpl _value,
    $Res Function(_$TutorIdleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TutorIdleImpl implements TutorIdle {
  const _$TutorIdleImpl();

  @override
  String toString() {
    return 'TutorState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$TutorIdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String problemText) classifying,
    required TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )
    asking,
    required TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )
    checking,
    required TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )
    hinting,
    required TResult Function(String problemId) solved,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String problemText)? classifying,
    TResult? Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult? Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult? Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult? Function(String problemId)? solved,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String problemText)? classifying,
    TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult Function(String problemId)? solved,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TutorIdle value) idle,
    required TResult Function(TutorClassifying value) classifying,
    required TResult Function(TutorAsking value) asking,
    required TResult Function(TutorChecking value) checking,
    required TResult Function(TutorHinting value) hinting,
    required TResult Function(TutorSolved value) solved,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TutorIdle value)? idle,
    TResult? Function(TutorClassifying value)? classifying,
    TResult? Function(TutorAsking value)? asking,
    TResult? Function(TutorChecking value)? checking,
    TResult? Function(TutorHinting value)? hinting,
    TResult? Function(TutorSolved value)? solved,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TutorIdle value)? idle,
    TResult Function(TutorClassifying value)? classifying,
    TResult Function(TutorAsking value)? asking,
    TResult Function(TutorChecking value)? checking,
    TResult Function(TutorHinting value)? hinting,
    TResult Function(TutorSolved value)? solved,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class TutorIdle implements TutorState {
  const factory TutorIdle() = _$TutorIdleImpl;
}

/// @nodoc
abstract class _$$TutorClassifyingImplCopyWith<$Res> {
  factory _$$TutorClassifyingImplCopyWith(
    _$TutorClassifyingImpl value,
    $Res Function(_$TutorClassifyingImpl) then,
  ) = __$$TutorClassifyingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String problemText});
}

/// @nodoc
class __$$TutorClassifyingImplCopyWithImpl<$Res>
    extends _$TutorStateCopyWithImpl<$Res, _$TutorClassifyingImpl>
    implements _$$TutorClassifyingImplCopyWith<$Res> {
  __$$TutorClassifyingImplCopyWithImpl(
    _$TutorClassifyingImpl _value,
    $Res Function(_$TutorClassifyingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? problemText = null}) {
    return _then(
      _$TutorClassifyingImpl(
        null == problemText
            ? _value.problemText
            : problemText // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TutorClassifyingImpl implements TutorClassifying {
  const _$TutorClassifyingImpl(this.problemText);

  @override
  final String problemText;

  @override
  String toString() {
    return 'TutorState.classifying(problemText: $problemText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorClassifyingImpl &&
            (identical(other.problemText, problemText) ||
                other.problemText == problemText));
  }

  @override
  int get hashCode => Object.hash(runtimeType, problemText);

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorClassifyingImplCopyWith<_$TutorClassifyingImpl> get copyWith =>
      __$$TutorClassifyingImplCopyWithImpl<_$TutorClassifyingImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String problemText) classifying,
    required TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )
    asking,
    required TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )
    checking,
    required TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )
    hinting,
    required TResult Function(String problemId) solved,
  }) {
    return classifying(problemText);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String problemText)? classifying,
    TResult? Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult? Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult? Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult? Function(String problemId)? solved,
  }) {
    return classifying?.call(problemText);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String problemText)? classifying,
    TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult Function(String problemId)? solved,
    required TResult orElse(),
  }) {
    if (classifying != null) {
      return classifying(problemText);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TutorIdle value) idle,
    required TResult Function(TutorClassifying value) classifying,
    required TResult Function(TutorAsking value) asking,
    required TResult Function(TutorChecking value) checking,
    required TResult Function(TutorHinting value) hinting,
    required TResult Function(TutorSolved value) solved,
  }) {
    return classifying(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TutorIdle value)? idle,
    TResult? Function(TutorClassifying value)? classifying,
    TResult? Function(TutorAsking value)? asking,
    TResult? Function(TutorChecking value)? checking,
    TResult? Function(TutorHinting value)? hinting,
    TResult? Function(TutorSolved value)? solved,
  }) {
    return classifying?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TutorIdle value)? idle,
    TResult Function(TutorClassifying value)? classifying,
    TResult Function(TutorAsking value)? asking,
    TResult Function(TutorChecking value)? checking,
    TResult Function(TutorHinting value)? hinting,
    TResult Function(TutorSolved value)? solved,
    required TResult orElse(),
  }) {
    if (classifying != null) {
      return classifying(this);
    }
    return orElse();
  }
}

abstract class TutorClassifying implements TutorState {
  const factory TutorClassifying(final String problemText) =
      _$TutorClassifyingImpl;

  String get problemText;

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorClassifyingImplCopyWith<_$TutorClassifyingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TutorAskingImplCopyWith<$Res> {
  factory _$$TutorAskingImplCopyWith(
    _$TutorAskingImpl value,
    $Res Function(_$TutorAskingImpl) then,
  ) = __$$TutorAskingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String problemText, Topic topic, String opener, String problemId});
}

/// @nodoc
class __$$TutorAskingImplCopyWithImpl<$Res>
    extends _$TutorStateCopyWithImpl<$Res, _$TutorAskingImpl>
    implements _$$TutorAskingImplCopyWith<$Res> {
  __$$TutorAskingImplCopyWithImpl(
    _$TutorAskingImpl _value,
    $Res Function(_$TutorAskingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemText = null,
    Object? topic = null,
    Object? opener = null,
    Object? problemId = null,
  }) {
    return _then(
      _$TutorAskingImpl(
        problemText: null == problemText
            ? _value.problemText
            : problemText // ignore: cast_nullable_to_non_nullable
                  as String,
        topic: null == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as Topic,
        opener: null == opener
            ? _value.opener
            : opener // ignore: cast_nullable_to_non_nullable
                  as String,
        problemId: null == problemId
            ? _value.problemId
            : problemId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TutorAskingImpl implements TutorAsking {
  const _$TutorAskingImpl({
    required this.problemText,
    required this.topic,
    required this.opener,
    required this.problemId,
  });

  @override
  final String problemText;
  @override
  final Topic topic;
  @override
  final String opener;
  @override
  final String problemId;

  @override
  String toString() {
    return 'TutorState.asking(problemText: $problemText, topic: $topic, opener: $opener, problemId: $problemId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorAskingImpl &&
            (identical(other.problemText, problemText) ||
                other.problemText == problemText) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.opener, opener) || other.opener == opener) &&
            (identical(other.problemId, problemId) ||
                other.problemId == problemId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, problemText, topic, opener, problemId);

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorAskingImplCopyWith<_$TutorAskingImpl> get copyWith =>
      __$$TutorAskingImplCopyWithImpl<_$TutorAskingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String problemText) classifying,
    required TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )
    asking,
    required TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )
    checking,
    required TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )
    hinting,
    required TResult Function(String problemId) solved,
  }) {
    return asking(problemText, topic, opener, problemId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String problemText)? classifying,
    TResult? Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult? Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult? Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult? Function(String problemId)? solved,
  }) {
    return asking?.call(problemText, topic, opener, problemId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String problemText)? classifying,
    TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult Function(String problemId)? solved,
    required TResult orElse(),
  }) {
    if (asking != null) {
      return asking(problemText, topic, opener, problemId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TutorIdle value) idle,
    required TResult Function(TutorClassifying value) classifying,
    required TResult Function(TutorAsking value) asking,
    required TResult Function(TutorChecking value) checking,
    required TResult Function(TutorHinting value) hinting,
    required TResult Function(TutorSolved value) solved,
  }) {
    return asking(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TutorIdle value)? idle,
    TResult? Function(TutorClassifying value)? classifying,
    TResult? Function(TutorAsking value)? asking,
    TResult? Function(TutorChecking value)? checking,
    TResult? Function(TutorHinting value)? hinting,
    TResult? Function(TutorSolved value)? solved,
  }) {
    return asking?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TutorIdle value)? idle,
    TResult Function(TutorClassifying value)? classifying,
    TResult Function(TutorAsking value)? asking,
    TResult Function(TutorChecking value)? checking,
    TResult Function(TutorHinting value)? hinting,
    TResult Function(TutorSolved value)? solved,
    required TResult orElse(),
  }) {
    if (asking != null) {
      return asking(this);
    }
    return orElse();
  }
}

abstract class TutorAsking implements TutorState {
  const factory TutorAsking({
    required final String problemText,
    required final Topic topic,
    required final String opener,
    required final String problemId,
  }) = _$TutorAskingImpl;

  String get problemText;
  Topic get topic;
  String get opener;
  String get problemId;

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorAskingImplCopyWith<_$TutorAskingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TutorCheckingImplCopyWith<$Res> {
  factory _$$TutorCheckingImplCopyWith(
    _$TutorCheckingImpl value,
    $Res Function(_$TutorCheckingImpl) then,
  ) = __$$TutorCheckingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String problemText,
    Topic topic,
    String attempt,
    String problemId,
  });
}

/// @nodoc
class __$$TutorCheckingImplCopyWithImpl<$Res>
    extends _$TutorStateCopyWithImpl<$Res, _$TutorCheckingImpl>
    implements _$$TutorCheckingImplCopyWith<$Res> {
  __$$TutorCheckingImplCopyWithImpl(
    _$TutorCheckingImpl _value,
    $Res Function(_$TutorCheckingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemText = null,
    Object? topic = null,
    Object? attempt = null,
    Object? problemId = null,
  }) {
    return _then(
      _$TutorCheckingImpl(
        problemText: null == problemText
            ? _value.problemText
            : problemText // ignore: cast_nullable_to_non_nullable
                  as String,
        topic: null == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as Topic,
        attempt: null == attempt
            ? _value.attempt
            : attempt // ignore: cast_nullable_to_non_nullable
                  as String,
        problemId: null == problemId
            ? _value.problemId
            : problemId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TutorCheckingImpl implements TutorChecking {
  const _$TutorCheckingImpl({
    required this.problemText,
    required this.topic,
    required this.attempt,
    required this.problemId,
  });

  @override
  final String problemText;
  @override
  final Topic topic;
  @override
  final String attempt;
  @override
  final String problemId;

  @override
  String toString() {
    return 'TutorState.checking(problemText: $problemText, topic: $topic, attempt: $attempt, problemId: $problemId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorCheckingImpl &&
            (identical(other.problemText, problemText) ||
                other.problemText == problemText) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.attempt, attempt) || other.attempt == attempt) &&
            (identical(other.problemId, problemId) ||
                other.problemId == problemId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, problemText, topic, attempt, problemId);

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorCheckingImplCopyWith<_$TutorCheckingImpl> get copyWith =>
      __$$TutorCheckingImplCopyWithImpl<_$TutorCheckingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String problemText) classifying,
    required TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )
    asking,
    required TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )
    checking,
    required TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )
    hinting,
    required TResult Function(String problemId) solved,
  }) {
    return checking(problemText, topic, attempt, problemId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String problemText)? classifying,
    TResult? Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult? Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult? Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult? Function(String problemId)? solved,
  }) {
    return checking?.call(problemText, topic, attempt, problemId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String problemText)? classifying,
    TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult Function(String problemId)? solved,
    required TResult orElse(),
  }) {
    if (checking != null) {
      return checking(problemText, topic, attempt, problemId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TutorIdle value) idle,
    required TResult Function(TutorClassifying value) classifying,
    required TResult Function(TutorAsking value) asking,
    required TResult Function(TutorChecking value) checking,
    required TResult Function(TutorHinting value) hinting,
    required TResult Function(TutorSolved value) solved,
  }) {
    return checking(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TutorIdle value)? idle,
    TResult? Function(TutorClassifying value)? classifying,
    TResult? Function(TutorAsking value)? asking,
    TResult? Function(TutorChecking value)? checking,
    TResult? Function(TutorHinting value)? hinting,
    TResult? Function(TutorSolved value)? solved,
  }) {
    return checking?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TutorIdle value)? idle,
    TResult Function(TutorClassifying value)? classifying,
    TResult Function(TutorAsking value)? asking,
    TResult Function(TutorChecking value)? checking,
    TResult Function(TutorHinting value)? hinting,
    TResult Function(TutorSolved value)? solved,
    required TResult orElse(),
  }) {
    if (checking != null) {
      return checking(this);
    }
    return orElse();
  }
}

abstract class TutorChecking implements TutorState {
  const factory TutorChecking({
    required final String problemText,
    required final Topic topic,
    required final String attempt,
    required final String problemId,
  }) = _$TutorCheckingImpl;

  String get problemText;
  Topic get topic;
  String get attempt;
  String get problemId;

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorCheckingImplCopyWith<_$TutorCheckingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TutorHintingImplCopyWith<$Res> {
  factory _$$TutorHintingImplCopyWith(
    _$TutorHintingImpl value,
    $Res Function(_$TutorHintingImpl) then,
  ) = __$$TutorHintingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String problemText,
    Topic topic,
    int level,
    String hint,
    String problemId,
    DateTime firstHintAt,
  });
}

/// @nodoc
class __$$TutorHintingImplCopyWithImpl<$Res>
    extends _$TutorStateCopyWithImpl<$Res, _$TutorHintingImpl>
    implements _$$TutorHintingImplCopyWith<$Res> {
  __$$TutorHintingImplCopyWithImpl(
    _$TutorHintingImpl _value,
    $Res Function(_$TutorHintingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemText = null,
    Object? topic = null,
    Object? level = null,
    Object? hint = null,
    Object? problemId = null,
    Object? firstHintAt = null,
  }) {
    return _then(
      _$TutorHintingImpl(
        problemText: null == problemText
            ? _value.problemText
            : problemText // ignore: cast_nullable_to_non_nullable
                  as String,
        topic: null == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as Topic,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        hint: null == hint
            ? _value.hint
            : hint // ignore: cast_nullable_to_non_nullable
                  as String,
        problemId: null == problemId
            ? _value.problemId
            : problemId // ignore: cast_nullable_to_non_nullable
                  as String,
        firstHintAt: null == firstHintAt
            ? _value.firstHintAt
            : firstHintAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$TutorHintingImpl implements TutorHinting {
  const _$TutorHintingImpl({
    required this.problemText,
    required this.topic,
    required this.level,
    required this.hint,
    required this.problemId,
    required this.firstHintAt,
  });

  @override
  final String problemText;
  @override
  final Topic topic;
  @override
  final int level;
  @override
  final String hint;
  @override
  final String problemId;
  @override
  final DateTime firstHintAt;

  @override
  String toString() {
    return 'TutorState.hinting(problemText: $problemText, topic: $topic, level: $level, hint: $hint, problemId: $problemId, firstHintAt: $firstHintAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorHintingImpl &&
            (identical(other.problemText, problemText) ||
                other.problemText == problemText) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.hint, hint) || other.hint == hint) &&
            (identical(other.problemId, problemId) ||
                other.problemId == problemId) &&
            (identical(other.firstHintAt, firstHintAt) ||
                other.firstHintAt == firstHintAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    problemText,
    topic,
    level,
    hint,
    problemId,
    firstHintAt,
  );

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorHintingImplCopyWith<_$TutorHintingImpl> get copyWith =>
      __$$TutorHintingImplCopyWithImpl<_$TutorHintingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String problemText) classifying,
    required TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )
    asking,
    required TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )
    checking,
    required TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )
    hinting,
    required TResult Function(String problemId) solved,
  }) {
    return hinting(problemText, topic, level, hint, problemId, firstHintAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String problemText)? classifying,
    TResult? Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult? Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult? Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult? Function(String problemId)? solved,
  }) {
    return hinting?.call(
      problemText,
      topic,
      level,
      hint,
      problemId,
      firstHintAt,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String problemText)? classifying,
    TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult Function(String problemId)? solved,
    required TResult orElse(),
  }) {
    if (hinting != null) {
      return hinting(problemText, topic, level, hint, problemId, firstHintAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TutorIdle value) idle,
    required TResult Function(TutorClassifying value) classifying,
    required TResult Function(TutorAsking value) asking,
    required TResult Function(TutorChecking value) checking,
    required TResult Function(TutorHinting value) hinting,
    required TResult Function(TutorSolved value) solved,
  }) {
    return hinting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TutorIdle value)? idle,
    TResult? Function(TutorClassifying value)? classifying,
    TResult? Function(TutorAsking value)? asking,
    TResult? Function(TutorChecking value)? checking,
    TResult? Function(TutorHinting value)? hinting,
    TResult? Function(TutorSolved value)? solved,
  }) {
    return hinting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TutorIdle value)? idle,
    TResult Function(TutorClassifying value)? classifying,
    TResult Function(TutorAsking value)? asking,
    TResult Function(TutorChecking value)? checking,
    TResult Function(TutorHinting value)? hinting,
    TResult Function(TutorSolved value)? solved,
    required TResult orElse(),
  }) {
    if (hinting != null) {
      return hinting(this);
    }
    return orElse();
  }
}

abstract class TutorHinting implements TutorState {
  const factory TutorHinting({
    required final String problemText,
    required final Topic topic,
    required final int level,
    required final String hint,
    required final String problemId,
    required final DateTime firstHintAt,
  }) = _$TutorHintingImpl;

  String get problemText;
  Topic get topic;
  int get level;
  String get hint;
  String get problemId;
  DateTime get firstHintAt;

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorHintingImplCopyWith<_$TutorHintingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TutorSolvedImplCopyWith<$Res> {
  factory _$$TutorSolvedImplCopyWith(
    _$TutorSolvedImpl value,
    $Res Function(_$TutorSolvedImpl) then,
  ) = __$$TutorSolvedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String problemId});
}

/// @nodoc
class __$$TutorSolvedImplCopyWithImpl<$Res>
    extends _$TutorStateCopyWithImpl<$Res, _$TutorSolvedImpl>
    implements _$$TutorSolvedImplCopyWith<$Res> {
  __$$TutorSolvedImplCopyWithImpl(
    _$TutorSolvedImpl _value,
    $Res Function(_$TutorSolvedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? problemId = null}) {
    return _then(
      _$TutorSolvedImpl(
        problemId: null == problemId
            ? _value.problemId
            : problemId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TutorSolvedImpl implements TutorSolved {
  const _$TutorSolvedImpl({required this.problemId});

  @override
  final String problemId;

  @override
  String toString() {
    return 'TutorState.solved(problemId: $problemId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorSolvedImpl &&
            (identical(other.problemId, problemId) ||
                other.problemId == problemId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, problemId);

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorSolvedImplCopyWith<_$TutorSolvedImpl> get copyWith =>
      __$$TutorSolvedImplCopyWithImpl<_$TutorSolvedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String problemText) classifying,
    required TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )
    asking,
    required TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )
    checking,
    required TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )
    hinting,
    required TResult Function(String problemId) solved,
  }) {
    return solved(problemId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String problemText)? classifying,
    TResult? Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult? Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult? Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult? Function(String problemId)? solved,
  }) {
    return solved?.call(problemId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String problemText)? classifying,
    TResult Function(
      String problemText,
      Topic topic,
      String opener,
      String problemId,
    )?
    asking,
    TResult Function(
      String problemText,
      Topic topic,
      String attempt,
      String problemId,
    )?
    checking,
    TResult Function(
      String problemText,
      Topic topic,
      int level,
      String hint,
      String problemId,
      DateTime firstHintAt,
    )?
    hinting,
    TResult Function(String problemId)? solved,
    required TResult orElse(),
  }) {
    if (solved != null) {
      return solved(problemId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TutorIdle value) idle,
    required TResult Function(TutorClassifying value) classifying,
    required TResult Function(TutorAsking value) asking,
    required TResult Function(TutorChecking value) checking,
    required TResult Function(TutorHinting value) hinting,
    required TResult Function(TutorSolved value) solved,
  }) {
    return solved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TutorIdle value)? idle,
    TResult? Function(TutorClassifying value)? classifying,
    TResult? Function(TutorAsking value)? asking,
    TResult? Function(TutorChecking value)? checking,
    TResult? Function(TutorHinting value)? hinting,
    TResult? Function(TutorSolved value)? solved,
  }) {
    return solved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TutorIdle value)? idle,
    TResult Function(TutorClassifying value)? classifying,
    TResult Function(TutorAsking value)? asking,
    TResult Function(TutorChecking value)? checking,
    TResult Function(TutorHinting value)? hinting,
    TResult Function(TutorSolved value)? solved,
    required TResult orElse(),
  }) {
    if (solved != null) {
      return solved(this);
    }
    return orElse();
  }
}

abstract class TutorSolved implements TutorState {
  const factory TutorSolved({required final String problemId}) =
      _$TutorSolvedImpl;

  String get problemId;

  /// Create a copy of TutorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorSolvedImplCopyWith<_$TutorSolvedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
