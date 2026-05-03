// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inference_engine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InferenceRequest _$InferenceRequestFromJson(Map<String, dynamic> json) =>
    _InferenceRequest(
      prompt: json['prompt'] as String,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 512,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      grammarBnf: json['grammarBnf'] as String?,
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$InferenceRequestToJson(_InferenceRequest instance) =>
    <String, dynamic>{
      'prompt': instance.prompt,
      'maxTokens': instance.maxTokens,
      'temperature': instance.temperature,
      'grammarBnf': instance.grammarBnf,
      'imagePath': instance.imagePath,
    };
