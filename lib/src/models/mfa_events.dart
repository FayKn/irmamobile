import 'package:json_annotation/json_annotation.dart';

import 'event.dart';

part 'mfa_events.g.dart';

@JsonSerializable()
class AddTOTPCodeEvent extends Event {
  AddTOTPCodeEvent({required this.totpStored});

  @JsonKey(name: 'TOTPStored')
  final TOTPStored totpStored;

  factory AddTOTPCodeEvent.fromJson(Map<String, dynamic> json) => _$AddTOTPCodeEventFromJson(json);
  Map<String, dynamic> toJson() => _$AddTOTPCodeEventToJson(this);
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
}
