import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/timer/timer_engine.dart';

enum AppThemeMode { system, dark, light }

@immutable
class AppSettings {
  const AppSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.keepScreenOn = false,
    this.themeMode = AppThemeMode.dark,
    this.approach = const Duration(minutes: 2),
    this.rest = const Duration(minutes: 10),
    this.longRest,
    this.cyclesBeforeLongRest = 0,
    this.snoozeBy = const Duration(minutes: 2),
    this.autoStartRest = true,
    this.askMood = false,
    this.breakdownModel = 'claude-opus-5-5',
    this.preferClaude = true,
    this.lastPresetId,
    this.lastTargetTaskId,
  });

  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool keepScreenOn;
  final AppThemeMode themeMode;

  /// The current ratio. Changing a preset writes these.
  final Duration approach;
  final Duration rest;
  final Duration? longRest;
  final int cyclesBeforeLongRest;
  final Duration snoozeBy;
  final bool autoStartRest;

  /// Offer the one-word mood prompt before and after a session.
  final bool askMood;
  final String breakdownModel;

  /// Use Claude when a key is present, otherwise the built-in ladders.
  final bool preferClaude;
  final String? lastPresetId;
  final String? lastTargetTaskId;

  TimerConfig get timerConfig => TimerConfig(
    approach: approach,
    rest: rest,
    longRest: longRest,
    cyclesBeforeLongRest: cyclesBeforeLongRest,
    snoozeBy: snoozeBy,
    autoStartRest: autoStartRest,
  );

  AppSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? keepScreenOn,
    AppThemeMode? themeMode,
    Duration? approach,
    Duration? rest,
    Duration? longRest,
    bool clearLongRest = false,
    int? cyclesBeforeLongRest,
    Duration? snoozeBy,
    bool? autoStartRest,
    bool? askMood,
    String? breakdownModel,
    bool? preferClaude,
    String? lastPresetId,
    bool clearLastPresetId = false,
    String? lastTargetTaskId,
    bool clearLastTargetTaskId = false,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      themeMode: themeMode ?? this.themeMode,
      approach: approach ?? this.approach,
      rest: rest ?? this.rest,
      longRest: clearLongRest ? null : (longRest ?? this.longRest),
      cyclesBeforeLongRest: cyclesBeforeLongRest ?? this.cyclesBeforeLongRest,
      snoozeBy: snoozeBy ?? this.snoozeBy,
      autoStartRest: autoStartRest ?? this.autoStartRest,
      askMood: askMood ?? this.askMood,
      breakdownModel: breakdownModel ?? this.breakdownModel,
      preferClaude: preferClaude ?? this.preferClaude,
      lastPresetId: clearLastPresetId ? null : (lastPresetId ?? this.lastPresetId),
      lastTargetTaskId:
          clearLastTargetTaskId ? null : (lastTargetTaskId ?? this.lastTargetTaskId),
    );
  }

  Map<String, dynamic> toJson() => {
    'soundEnabled': soundEnabled,
    'vibrationEnabled': vibrationEnabled,
    'keepScreenOn': keepScreenOn,
    'themeMode': themeMode.name,
    'approachMs': approach.inMilliseconds,
    'restMs': rest.inMilliseconds,
    'longRestMs': longRest?.inMilliseconds,
    'cyclesBeforeLongRest': cyclesBeforeLongRest,
    'snoozeByMs': snoozeBy.inMilliseconds,
    'autoStartRest': autoStartRest,
    'askMood': askMood,
    'breakdownModel': breakdownModel,
    'preferClaude': preferClaude,
    'lastPresetId': lastPresetId,
    'lastTargetTaskId': lastTargetTaskId,
  };

  static AppSettings fromJson(Map<String, dynamic> j) {
    const d = AppSettings();
    Duration ms(String key, Duration fallback) =>
        j[key] is num ? Duration(milliseconds: (j[key] as num).toInt()) : fallback;
    return AppSettings(
      soundEnabled: j['soundEnabled'] as bool? ?? d.soundEnabled,
      vibrationEnabled: j['vibrationEnabled'] as bool? ?? d.vibrationEnabled,
      keepScreenOn: j['keepScreenOn'] as bool? ?? d.keepScreenOn,
      themeMode: AppThemeMode.values.firstWhere(
        (m) => m.name == j['themeMode'],
        orElse: () => d.themeMode,
      ),
      approach: ms('approachMs', d.approach),
      rest: ms('restMs', d.rest),
      longRest: j['longRestMs'] is num
          ? Duration(milliseconds: (j['longRestMs'] as num).toInt())
          : null,
      cyclesBeforeLongRest: (j['cyclesBeforeLongRest'] as num?)?.toInt() ?? 0,
      snoozeBy: ms('snoozeByMs', d.snoozeBy),
      autoStartRest: j['autoStartRest'] as bool? ?? d.autoStartRest,
      askMood: j['askMood'] as bool? ?? d.askMood,
      breakdownModel: j['breakdownModel'] as String? ?? d.breakdownModel,
      preferClaude: j['preferClaude'] as bool? ?? d.preferClaude,
      lastPresetId: j['lastPresetId'] as String?,
      lastTargetTaskId: j['lastTargetTaskId'] as String?,
    );
  }
}

/// Small key-value store so tests can run without platform plugins.
abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
}

class PrefsKeyValueStore implements KeyValueStore {
  PrefsKeyValueStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  @override
  Future<String?> getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  @override
  Future<bool?> getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object> _values = {};

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<void> setString(String key, String value) async => _values[key] = value;

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;

  @override
  Future<void> remove(String key) async => _values.remove(key);
}

/// Where the API key lives: the platform keychain in the app, memory in tests.
abstract class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureSecretStore implements SecretStore {
  SecureSecretStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class InMemorySecretStore implements SecretStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

/// Settings in SharedPreferences, the API key in the platform keychain, and
/// the running timer's state so it survives process death.
class SettingsService {
  SettingsService({KeyValueStore? prefs, SecretStore? secrets})
    : _prefs = prefs ?? PrefsKeyValueStore(),
      _secure = secrets ?? SecureSecretStore();

  final KeyValueStore _prefs;
  final SecretStore _secure;

  static const _settingsKey = 'settings.v1';
  static const _activeTimerKey = 'active_timer.v1';
  static const _apiKeyKey = 'anthropic_api_key';
  static const _seededKey = 'seeded.v1';

  Future<AppSettings> load() async {
    try {
      final raw = await _prefs.getString(_settingsKey);
      if (raw == null) return const AppSettings();
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Settings load failed, using defaults: $e');
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) =>
      _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));

  Future<String?> apiKey() async {
    try {
      return await _secure.read(_apiKeyKey);
    } catch (e) {
      debugPrint('Secure storage read failed: $e');
      return null;
    }
  }

  Future<void> setApiKey(String? key) async {
    try {
      if (key == null || key.trim().isEmpty) {
        await _secure.delete(_apiKeyKey);
      } else {
        await _secure.write(_apiKeyKey, key.trim());
      }
    } catch (e) {
      debugPrint('Secure storage write failed: $e');
    }
  }

  Future<Map<String, dynamic>?> loadActiveTimer() async {
    try {
      final raw = await _prefs.getString(_activeTimerKey);
      return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActiveTimer(Map<String, dynamic>? json) async {
    if (json == null) {
      await _prefs.remove(_activeTimerKey);
    } else {
      await _prefs.setString(_activeTimerKey, jsonEncode(json));
    }
  }

  Future<bool> isSeeded() async => await _prefs.getBool(_seededKey) ?? false;

  Future<void> markSeeded() => _prefs.setBool(_seededKey, true);
}
