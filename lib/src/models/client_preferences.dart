import 'package:json_annotation/json_annotation.dart';

import 'event.dart';

part 'client_preferences.g.dart';

@JsonSerializable()
class ClientPreferencesEvent extends Event {
  ClientPreferencesEvent({required this.clientPreferences});

  @JsonKey(name: 'Preferences')
  final ClientPreferences clientPreferences;

  factory ClientPreferencesEvent.fromJson(Map<String, dynamic> json) => _$ClientPreferencesEventFromJson(json);
  Map<String, dynamic> toJson() => _$ClientPreferencesEventToJson(this);
}

@JsonSerializable()
class ClientPreferences {
  ClientPreferences({required this.developerMode, required this.experimentalFeatures});

  @JsonKey(name: 'DeveloperMode')
  final bool developerMode;
  @JsonKey(name: 'ExperimentalFeatures')
  final bool experimentalFeatures;

  factory ClientPreferences.fromJson(Map<String, dynamic> json) => _$ClientPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$ClientPreferencesToJson(this);
}
