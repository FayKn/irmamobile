// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddTOTPSecretEvent _$AddTOTPSecretEventFromJson(Map<String, dynamic> json) => AddTOTPSecretEvent(
      totpStored: TOTPStored.fromJson(json['TOTPStored'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddTOTPSecretEventToJson(AddTOTPSecretEvent instance) => <String, dynamic>{
      'TOTPStored': instance.totpStored,
    };

GetAllTOTPSecretsEvent _$GetAllTOTPSecretsEventFromJson(Map<String, dynamic> json) => GetAllTOTPSecretsEvent();

Map<String, dynamic> _$GetAllTOTPSecretsEventToJson(GetAllTOTPSecretsEvent instance) => <String, dynamic>{};

TOTPStored _$TOTPStoredFromJson(Map<String, dynamic> json) => TOTPStored(
      issuer: json['Issuer'] as String,
      userAccount: json['UserAccount'] as String,
      secret: json['Secret'] as String,
      period: (json['Period'] as num).toInt(),
      algorithm: json['Algorithm'] as String,
    );

Map<String, dynamic> _$TOTPStoredToJson(TOTPStored instance) => <String, dynamic>{
      'Issuer': instance.issuer,
      'UserAccount': instance.userAccount,
      'Secret': instance.secret,
      'Period': instance.period,
      'Algorithm': instance.algorithm,
    };
