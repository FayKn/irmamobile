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

ExportSecretsEvent _$ExportSecretsEventFromJson(Map<String, dynamic> json) => ExportSecretsEvent(
      totpStored:
          (json['Secrets'] as List<dynamic>?)?.map((e) => TOTPStored.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$ExportSecretsEventToJson(ExportSecretsEvent instance) => <String, dynamic>{
      'Secrets': instance.totpStored,
    };

ExportSecretsInputToUrlEvent _$ExportSecretsInputToUrlEventFromJson(Map<String, dynamic> json) =>
    ExportSecretsInputToUrlEvent(
      secrets: (json['secrets'] as List<dynamic>).map((e) => TOTPStored.fromJson(e as Map<String, dynamic>)).toList(),
      isGoogle: json['isGoogle'] as bool,
    );

Map<String, dynamic> _$ExportSecretsInputToUrlEventToJson(ExportSecretsInputToUrlEvent instance) => <String, dynamic>{
      'secrets': instance.secrets,
      'isGoogle': instance.isGoogle,
    };

ExportSecretsToUrlEvent _$ExportSecretsToUrlEventFromJson(Map<String, dynamic> json) => ExportSecretsToUrlEvent(
      (json['URLs'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ExportSecretsToUrlEventToJson(ExportSecretsToUrlEvent instance) => <String, dynamic>{
      'URLs': instance.urls,
    };

StoreTOTPSecretByURLEvent _$StoreTOTPSecretByURLEventFromJson(Map<String, dynamic> json) => StoreTOTPSecretByURLEvent(
      inputUrl: json['inputUrl'] as String,
    );

Map<String, dynamic> _$StoreTOTPSecretByURLEventToJson(StoreTOTPSecretByURLEvent instance) => <String, dynamic>{
      'inputUrl': instance.inputUrl,
    };

GetAllTOTPSecretsEvent _$GetAllTOTPSecretsEventFromJson(Map<String, dynamic> json) => GetAllTOTPSecretsEvent(
      codes: (json['Codes'] as List<dynamic>?)?.map((e) => TOTPcode.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$GetAllTOTPSecretsEventToJson(GetAllTOTPSecretsEvent instance) => <String, dynamic>{
      'Codes': instance.codes,
    };

RemoveTOTPSecretEvent _$RemoveTOTPSecretEventFromJson(Map<String, dynamic> json) => RemoveTOTPSecretEvent(
      code: TOTPcode.fromJson(json['Code'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RemoveTOTPSecretEventToJson(RemoveTOTPSecretEvent instance) => <String, dynamic>{
      'Code': instance.code,
    };

EncryptExportFileSendEvent _$EncryptExportFileSendEventFromJson(Map<String, dynamic> json) =>
    EncryptExportFileSendEvent(
      encryptedFile: json['EncryptedFile'] as String,
      password: json['Password'] as String,
    );

Map<String, dynamic> _$EncryptExportFileSendEventToJson(EncryptExportFileSendEvent instance) => <String, dynamic>{
      'EncryptedFile': instance.encryptedFile,
      'Password': instance.password,
    };

DecryptExportFileSendEvent _$DecryptExportFileSendEventFromJson(Map<String, dynamic> json) =>
    DecryptExportFileSendEvent(
      encryptedFile: json['EncryptedFile'] as String,
      password: json['Password'] as String,
    );

Map<String, dynamic> _$DecryptExportFileSendEventToJson(DecryptExportFileSendEvent instance) => <String, dynamic>{
      'EncryptedFile': instance.encryptedFile,
      'Password': instance.password,
    };

EncryptExportFileReceiveEvent _$EncryptExportFileReceiveEventFromJson(Map<String, dynamic> json) =>
    EncryptExportFileReceiveEvent(
      content: json['Content'] as String,
    );

Map<String, dynamic> _$EncryptExportFileReceiveEventToJson(EncryptExportFileReceiveEvent instance) => <String, dynamic>{
      'Content': instance.content,
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

TOTPcode _$TOTPcodeFromJson(Map<String, dynamic> json) => TOTPcode(
      issuer: json['Issuer'] as String,
      userAccount: json['UserAccount'] as String,
      code: json['Code'] as String,
      nextCode: json['NextCode'] as String,
      period: (json['Period'] as num).toInt(),
      timerProgress: (json['TimerProgress'] as num).toInt(),
    );

Map<String, dynamic> _$TOTPcodeToJson(TOTPcode instance) => <String, dynamic>{
      'Issuer': instance.issuer,
      'UserAccount': instance.userAccount,
      'Code': instance.code,
      'NextCode': instance.nextCode,
      'Period': instance.period,
      'TimerProgress': instance.timerProgress,
    };
