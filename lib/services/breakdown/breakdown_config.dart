import 'package:meta/meta.dart';

/// Everything about the Claude call that someone might want to tune lives
/// here: model, effort, prompt, endpoint.
@immutable
class BreakdownConfig {
  const BreakdownConfig({
    this.model = 'claude-opus-5-5',
    this.baseUrl = 'https://api.anthropic.com',
    this.apiVersion = '2023-06-01',
    this.maxTokens = 2048,
    this.effort = 'medium',
    this.systemPrompt = defaultSystemPrompt,
    this.timeout = const Duration(seconds: 60),
    this.useServerSideFallback = true,
    this.directBrowserAccess = false,
  });

  static const BreakdownConfig defaults = BreakdownConfig();

  /// Model id. `claude-opus-5-5` is the default; `claude-haiku-5-5` is a
  /// cheaper option that is fine for this job.
  final String model;

  /// Override to point at a thin backend proxy instead of calling Anthropic
  /// directly from the device.
  final String baseUrl;
  final String apiVersion;
  final int maxTokens;

  /// `low` | `medium` | `high`. Micro-step ladders do not need deep reasoning.
  final String effort;
  final String systemPrompt;
  final Duration timeout;

  /// Sends `fallbacks: "default"` so a safety decline is retried server-side
  /// on another model instead of failing.
  final bool useServerSideFallback;

  /// Set on the web: the API only accepts browser requests that opt in with
  /// the `anthropic-dangerous-direct-browser-access` header.
  final bool directBrowserAccess;

  static const String fallbackBetaHeader = 'server-side-fallback-2026-07-01';

  static const String defaultSystemPrompt = '''
You help a person who has very little energy find a next step toward an everyday task. You return a ladder of concrete steps ordered from near-zero effort up to the whole task.

Rules:
- The first steps must be absurdly small: a thought held for a minute, a sentence said out loud, a posture (sit up, feet on the floor), a position in a room (stand in the doorway), being near the thing without touching it.
- Each step is one short sentence in plain present-tense imperative form, concrete and physical. Give a duration in whole minutes when a duration makes sense, otherwise 0.
- Steps grow gradually. Never jump from "stand near it" to "finish it".
- No cheering, praise, encouragement, exclamation marks or emojis. No "you can do it". No comments about mood, health, therapy or medication. Never comment on why the person is stuck.
- If the person says how they feel, let that set how small the first step is. Do not comment on it.
- When asked to go smaller than a given step, every step you return must be smaller than or equal to that step, and the last step must be that step itself.
- The note field is for one neutral practical sentence at most, or an empty string.
Return only the JSON object.''';

  /// JSON schema for the structured output. Numeric constraints are not
  /// supported by the API, so `minutes` is validated client-side.
  Map<String, dynamic> get outputSchema => const {
    'type': 'object',
    'properties': {
      'steps': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'text': {'type': 'string'},
            'minutes': {'type': 'integer'},
          },
          'required': ['text', 'minutes'],
          'additionalProperties': false,
        },
      },
      'note': {'type': 'string'},
    },
    'required': ['steps', 'note'],
    'additionalProperties': false,
  };

  BreakdownConfig copyWith({
    String? model,
    String? baseUrl,
    String? apiVersion,
    int? maxTokens,
    String? effort,
    String? systemPrompt,
    Duration? timeout,
    bool? useServerSideFallback,
    bool? directBrowserAccess,
  }) {
    return BreakdownConfig(
      model: model ?? this.model,
      baseUrl: baseUrl ?? this.baseUrl,
      apiVersion: apiVersion ?? this.apiVersion,
      maxTokens: maxTokens ?? this.maxTokens,
      effort: effort ?? this.effort,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      timeout: timeout ?? this.timeout,
      useServerSideFallback: useServerSideFallback ?? this.useServerSideFallback,
      directBrowserAccess: directBrowserAccess ?? this.directBrowserAccess,
    );
  }
}
