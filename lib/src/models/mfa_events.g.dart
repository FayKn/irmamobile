// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddTOTPCodeEvent _$AddTOTPCodeEventFromJson(Map<String, dynamic> json) => AddTOTPCodeEvent(
      totpStored: TOTPStored.fromJson(json['TOTPStored'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddTOTPCodeEventToJson(AddTOTPCodeEvent instance) => <String, dynamic>{
      'TOTPStored': instance.totpStored,
    };

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
