import 'package:json_annotation/json_annotation.dart';

import 'event.dart';

part 'mfa_events.g.dart';

@JsonSerializable()
class AddTOTPSecretEvent extends Event {
  AddTOTPSecretEvent({required this.totpStored});

  @JsonKey(name: 'TOTPStored')
  final TOTPStored totpStored;

  factory AddTOTPSecretEvent.fromJson(Map<String, dynamic> json) => _$AddTOTPSecretEventFromJson(json);

  Map<String, dynamic> toJson() => _$AddTOTPSecretEventToJson(this);
}

@JsonSerializable()
class GetAllTOTPSecretsEvent extends Event {
  GetAllTOTPSecretsEvent({this.codes});

  @JsonKey(name: 'Codes')
  final List<TOTPcode>? codes;

  factory GetAllTOTPSecretsEvent.fromJson(Map<String, dynamic> json) => _$GetAllTOTPSecretsEventFromJson(json);

  Map<String, dynamic> toJson() => _$GetAllTOTPSecretsEventToJson(this);
}

@JsonSerializable()
class RemoveTOTPSecretEvent extends Event {
  RemoveTOTPSecretEvent({required this.code});

  @JsonKey(name: 'Code')
  final TOTPcode code;

  factory RemoveTOTPSecretEvent.fromJson(Map<String, dynamic> json) => _$RemoveTOTPSecretEventFromJson(json);
  Map<String, dynamic> toJson() => _$RemoveTOTPSecretEventToJson(this);
}

@JsonSerializable()
class TOTPStored {
  @JsonKey(name: 'Issuer')
  final String issuer;
  @JsonKey(name: 'UserAccount')
  final String userAccount;
  @JsonKey(name: 'Secret')
  final String secret;
  @JsonKey(name: 'Period')
  final int period;
  @JsonKey(name: 'Algorithm')
  final String algorithm;

  TOTPStored({
    required this.issuer,
    required this.userAccount,
    required this.secret,
    required this.period,
    required this.algorithm,
  });

  factory TOTPStored.fromJson(Map<String, dynamic> json) => _$TOTPStoredFromJson(json);
  Map<String, dynamic> toJson() => _$TOTPStoredToJson(this);
}

@JsonSerializable()
class TOTPcode {
  @JsonKey(name: 'Issuer')
  final String issuer;
  @JsonKey(name: 'UserAccount')
  final String userAccount;
  @JsonKey(name: 'Code')
  final String code;
  @JsonKey(name: 'NextCode')
  final String nextCode;
  @JsonKey(name: 'Period')
  final int period;
  @JsonKey(name: 'TimerProgress')
  final int timerProgress;

  TOTPcode({
    required this.issuer,
    required this.userAccount,
    required this.code,
    required this.nextCode,
    required this.period,
    required this.timerProgress,
  });

  factory TOTPcode.fromJson(Map<String, dynamic> json) => _$TOTPcodeFromJson(json);
  Map<String, dynamic> toJson() => _$TOTPcodeToJson(this);
}
