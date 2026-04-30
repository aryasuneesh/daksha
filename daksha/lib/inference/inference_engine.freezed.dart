// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inference_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InferenceRequest _$InferenceRequestFromJson(Map<String, dynamic> json) {
  return _InferenceRequest.fromJson(json);
}

/// @nodoc
mixin _$InferenceRequest {
  String get prompt => throw _privateConstructorUsedError;
  int get maxTokens => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  String? get grammarBnf => throw _privateConstructorUsedError;

  /// Serializes this InferenceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InferenceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InferenceRequestCopyWith<InferenceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InferenceRequestCopyWith<$Res> {
  factory $InferenceRequestCopyWith(
    InferenceRequest value,
    $Res Function(InferenceRequest) then,
  ) = _$InferenceRequestCopyWithImpl<$Res, InferenceRequest>;
  @useResult
  $Res call({
    String prompt,
    int maxTokens,
    double temperature,
    String? grammarBnf,
  });
}

/// @nodoc
class _$InferenceRequestCopyWithImpl<$Res, $Val extends InferenceRequest>
    implements $InferenceRequestCopyWith<$Res> {
  _$InferenceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InferenceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = null,
    Object? maxTokens = null,
    Object? temperature = null,
    Object? grammarBnf = freezed,
  }) {
    return _then(
      _value.copyWith(
            prompt: null == prompt
                ? _value.prompt
                : prompt // ignore: cast_nullable_to_non_nullable
                      as String,
            maxTokens: null == maxTokens
                ? _value.maxTokens
                : maxTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            grammarBnf: freezed == grammarBnf
                ? _value.grammarBnf
                : grammarBnf // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InferenceRequestImplCopyWith<$Res>
    implements $InferenceRequestCopyWith<$Res> {
  factory _$$InferenceRequestImplCopyWith(
    _$InferenceRequestImpl value,
    $Res Function(_$InferenceRequestImpl) then,
  ) = __$$InferenceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String prompt,
    int maxTokens,
    double temperature,
    String? grammarBnf,
  });
}

/// @nodoc
class __$$InferenceRequestImplCopyWithImpl<$Res>
    extends _$InferenceRequestCopyWithImpl<$Res, _$InferenceRequestImpl>
    implements _$$InferenceRequestImplCopyWith<$Res> {
  __$$InferenceRequestImplCopyWithImpl(
    _$InferenceRequestImpl _value,
    $Res Function(_$InferenceRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InferenceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = null,
    Object? maxTokens = null,
    Object? temperature = null,
    Object? grammarBnf = freezed,
  }) {
    return _then(
      _$InferenceRequestImpl(
        prompt: null == prompt
            ? _value.prompt
            : prompt // ignore: cast_nullable_to_non_nullable
                  as String,
        maxTokens: null == maxTokens
            ? _value.maxTokens
            : maxTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        grammarBnf: freezed == grammarBnf
            ? _value.grammarBnf
            : grammarBnf // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InferenceRequestImpl implements _InferenceRequest {
  const _$InferenceRequestImpl({
    required this.prompt,
    this.maxTokens = 512,
    this.temperature = 0.7,
    this.grammarBnf,
  });

  factory _$InferenceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$InferenceRequestImplFromJson(json);

  @override
  final String prompt;
  @override
  @JsonKey()
  final int maxTokens;
  @override
  @JsonKey()
  final double temperature;
  @override
  final String? grammarBnf;

  @override
  String toString() {
    return 'InferenceRequest(prompt: $prompt, maxTokens: $maxTokens, temperature: $temperature, grammarBnf: $grammarBnf)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InferenceRequestImpl &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.grammarBnf, grammarBnf) ||
                other.grammarBnf == grammarBnf));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, prompt, maxTokens, temperature, grammarBnf);

  /// Create a copy of InferenceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InferenceRequestImplCopyWith<_$InferenceRequestImpl> get copyWith =>
      __$$InferenceRequestImplCopyWithImpl<_$InferenceRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InferenceRequestImplToJson(this);
  }
}

abstract class _InferenceRequest implements InferenceRequest {
  const factory _InferenceRequest({
    required final String prompt,
    final int maxTokens,
    final double temperature,
    final String? grammarBnf,
  }) = _$InferenceRequestImpl;

  factory _InferenceRequest.fromJson(Map<String, dynamic> json) =
      _$InferenceRequestImpl.fromJson;

  @override
  String get prompt;
  @override
  int get maxTokens;
  @override
  double get temperature;
  @override
  String? get grammarBnf;

  /// Create a copy of InferenceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InferenceRequestImplCopyWith<_$InferenceRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$InferenceResponse {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text, int tokensGenerated) success,
    required TResult Function(String error) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text, int tokensGenerated)? success,
    TResult? Function(String error)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text, int tokensGenerated)? success,
    TResult Function(String error)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InferenceSuccess value) success,
    required TResult Function(InferenceFailure value) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InferenceSuccess value)? success,
    TResult? Function(InferenceFailure value)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InferenceSuccess value)? success,
    TResult Function(InferenceFailure value)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InferenceResponseCopyWith<$Res> {
  factory $InferenceResponseCopyWith(
    InferenceResponse value,
    $Res Function(InferenceResponse) then,
  ) = _$InferenceResponseCopyWithImpl<$Res, InferenceResponse>;
}

/// @nodoc
class _$InferenceResponseCopyWithImpl<$Res, $Val extends InferenceResponse>
    implements $InferenceResponseCopyWith<$Res> {
  _$InferenceResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InferenceResponse
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InferenceSuccessImplCopyWith<$Res> {
  factory _$$InferenceSuccessImplCopyWith(
    _$InferenceSuccessImpl value,
    $Res Function(_$InferenceSuccessImpl) then,
  ) = __$$InferenceSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String text, int tokensGenerated});
}

/// @nodoc
class __$$InferenceSuccessImplCopyWithImpl<$Res>
    extends _$InferenceResponseCopyWithImpl<$Res, _$InferenceSuccessImpl>
    implements _$$InferenceSuccessImplCopyWith<$Res> {
  __$$InferenceSuccessImplCopyWithImpl(
    _$InferenceSuccessImpl _value,
    $Res Function(_$InferenceSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InferenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? text = null, Object? tokensGenerated = null}) {
    return _then(
      _$InferenceSuccessImpl(
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        tokensGenerated: null == tokensGenerated
            ? _value.tokensGenerated
            : tokensGenerated // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$InferenceSuccessImpl implements InferenceSuccess {
  const _$InferenceSuccessImpl({required this.text, this.tokensGenerated = 0});

  @override
  final String text;
  @override
  @JsonKey()
  final int tokensGenerated;

  @override
  String toString() {
    return 'InferenceResponse.success(text: $text, tokensGenerated: $tokensGenerated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InferenceSuccessImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.tokensGenerated, tokensGenerated) ||
                other.tokensGenerated == tokensGenerated));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text, tokensGenerated);

  /// Create a copy of InferenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InferenceSuccessImplCopyWith<_$InferenceSuccessImpl> get copyWith =>
      __$$InferenceSuccessImplCopyWithImpl<_$InferenceSuccessImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text, int tokensGenerated) success,
    required TResult Function(String error) failure,
  }) {
    return success(text, tokensGenerated);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text, int tokensGenerated)? success,
    TResult? Function(String error)? failure,
  }) {
    return success?.call(text, tokensGenerated);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text, int tokensGenerated)? success,
    TResult Function(String error)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(text, tokensGenerated);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InferenceSuccess value) success,
    required TResult Function(InferenceFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InferenceSuccess value)? success,
    TResult? Function(InferenceFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InferenceSuccess value)? success,
    TResult Function(InferenceFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class InferenceSuccess implements InferenceResponse {
  const factory InferenceSuccess({
    required final String text,
    final int tokensGenerated,
  }) = _$InferenceSuccessImpl;

  String get text;
  int get tokensGenerated;

  /// Create a copy of InferenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InferenceSuccessImplCopyWith<_$InferenceSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$InferenceFailureImplCopyWith<$Res> {
  factory _$$InferenceFailureImplCopyWith(
    _$InferenceFailureImpl value,
    $Res Function(_$InferenceFailureImpl) then,
  ) = __$$InferenceFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$InferenceFailureImplCopyWithImpl<$Res>
    extends _$InferenceResponseCopyWithImpl<$Res, _$InferenceFailureImpl>
    implements _$$InferenceFailureImplCopyWith<$Res> {
  __$$InferenceFailureImplCopyWithImpl(
    _$InferenceFailureImpl _value,
    $Res Function(_$InferenceFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InferenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? error = null}) {
    return _then(
      _$InferenceFailureImpl(
        error: null == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$InferenceFailureImpl implements InferenceFailure {
  const _$InferenceFailureImpl({required this.error});

  @override
  final String error;

  @override
  String toString() {
    return 'InferenceResponse.failure(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InferenceFailureImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of InferenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InferenceFailureImplCopyWith<_$InferenceFailureImpl> get copyWith =>
      __$$InferenceFailureImplCopyWithImpl<_$InferenceFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text, int tokensGenerated) success,
    required TResult Function(String error) failure,
  }) {
    return failure(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text, int tokensGenerated)? success,
    TResult? Function(String error)? failure,
  }) {
    return failure?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text, int tokensGenerated)? success,
    TResult Function(String error)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InferenceSuccess value) success,
    required TResult Function(InferenceFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InferenceSuccess value)? success,
    TResult? Function(InferenceFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InferenceSuccess value)? success,
    TResult Function(InferenceFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class InferenceFailure implements InferenceResponse {
  const factory InferenceFailure({required final String error}) =
      _$InferenceFailureImpl;

  String get error;

  /// Create a copy of InferenceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InferenceFailureImplCopyWith<_$InferenceFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
