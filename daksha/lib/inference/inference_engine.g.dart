// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inference_engine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InferenceRequestImpl _$$InferenceRequestImplFromJson(
  Map<String, dynamic> json,
) => _$InferenceRequestImpl(
  prompt: json['prompt'] as String,
  maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 512,
  temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
  grammarBnf: json['grammarBnf'] as String?,
);

Map<String, dynamic> _$$InferenceRequestImplToJson(
  _$InferenceRequestImpl instance,
) => <String, dynamic>{
  'prompt': instance.prompt,
  'maxTokens': instance.maxTokens,
  'temperature': instance.temperature,
  'grammarBnf': instance.grammarBnf,
};
