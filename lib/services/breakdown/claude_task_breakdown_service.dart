import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/ladder_step.dart';
import 'breakdown_config.dart';
import 'task_breakdown_service.dart';

/// Calls the Claude Messages API directly over HTTPS with a structured JSON
/// output schema. Dart has no official Anthropic SDK, so this is a thin raw
/// client. Swap [BreakdownConfig.baseUrl] to route through a backend proxy.
class ClaudeTaskBreakdownService implements TaskBreakdownService {
  ClaudeTaskBreakdownService({
    required this.apiKeyProvider,
    this.config = BreakdownConfig.defaults,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final Future<String?> Function() apiKeyProvider;
  final BreakdownConfig config;
  final http.Client _client;

  @override
  String get name => 'Claude (${config.model})';

  @override
  Future<bool> isAvailable() async {
    final key = await apiKeyProvider();
    return key != null && key.trim().isNotEmpty;
  }

  @override
  Future<BreakdownResult> breakDown(BreakdownRequest request) async {
    final key = (await apiKeyProvider())?.trim();
    if (key == null || key.isEmpty) {
      throw BreakdownException('No API key set. Add one in Settings.');
    }
    final uri = Uri.parse('${config.baseUrl}/v1/messages');
    final headers = <String, String>{
      'content-type': 'application/json',
      'x-api-key': key,
      'anthropic-version': config.apiVersion,
      if (config.useServerSideFallback)
        'anthropic-beta': BreakdownConfig.fallbackBetaHeader,
    };
    final body = jsonEncode(buildRequestBody(request, config));

    final http.Response response;
    try {
      response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(config.timeout);
    } on TimeoutException catch (e) {
      throw BreakdownException('The request timed out.', cause: e, retryable: true);
    } on http.ClientException catch (e) {
      throw BreakdownException('Could not reach the service.', cause: e, retryable: true);
    }

    if (response.statusCode != 200) {
      throw BreakdownException(
        _errorMessage(response),
        retryable: response.statusCode == 429 || response.statusCode >= 500,
      );
    }
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw BreakdownException('The reply was not valid JSON.', cause: e);
    }
    return parseResponse(json, source: name, maxSteps: request.maxSteps);
  }

  /// The exact request body. Public so tests can pin it.
  static Map<String, dynamic> buildRequestBody(
    BreakdownRequest request,
    BreakdownConfig config,
  ) {
    return {
      'model': config.model,
      'max_tokens': config.maxTokens,
      'system': config.systemPrompt,
      'messages': [
        {'role': 'user', 'content': buildUserPrompt(request)},
      ],
      'output_config': {
        'effort': config.effort,
        'format': {'type': 'json_schema', 'schema': config.outputSchema},
      },
      if (config.useServerSideFallback) 'fallbacks': 'default',
    };
  }

  static String buildUserPrompt(BreakdownRequest r) {
    final b = StringBuffer();
    b.writeln('Task: ${r.taskTitle.trim()}');
    if (r.taskNote?.trim().isNotEmpty ?? false) {
      b.writeln('Notes about the task: ${r.taskNote!.trim()}');
    }
    if (r.currentLadder.isNotEmpty) {
      b.writeln('Current ladder, smallest first:');
      for (var i = 0; i < r.currentLadder.length; i++) {
        b.writeln('${i + 1}. ${r.currentLadder[i]}');
      }
    }
    if (r.goSmaller && (r.currentRung?.trim().isNotEmpty ?? false)) {
      b.writeln('Go smaller than this step: "${r.currentRung!.trim()}"');
      b.writeln('Every step must be smaller than or equal to it; the last step is that step itself.');
    }
    if (r.feelingNote?.trim().isNotEmpty ?? false) {
      b.writeln('How the person feels right now: ${r.feelingNote!.trim()}');
    }
    final min = r.maxSteps < 4 ? r.maxSteps : 4;
    b.writeln('Return between $min and ${r.maxSteps} steps.');
    return b.toString().trimRight();
  }

  /// Parses a Messages API response. Public so tests can feed canned replies.
  static BreakdownResult parseResponse(
    Map<String, dynamic> json, {
    required String source,
    int maxSteps = 8,
  }) {
    final stopReason = json['stop_reason'];
    if (stopReason == 'refusal') {
      throw BreakdownException('The service declined this request.');
    }
    if (stopReason == 'max_tokens') {
      throw BreakdownException('The reply was cut short. Try again.', retryable: true);
    }
    final content = json['content'];
    if (content is! List) throw BreakdownException('Unexpected reply shape.');
    final text = content
        .whereType<Map<String, dynamic>>()
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'])
        .whereType<String>()
        .join();
    if (text.trim().isEmpty) throw BreakdownException('The reply was empty.');

    final Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(text) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw BreakdownException('The reply was not valid JSON.', cause: e);
    }
    final rawSteps = parsed['steps'];
    if (rawSteps is! List) throw BreakdownException('The reply had no steps.');
    final steps = <MicroStep>[];
    for (final raw in rawSteps) {
      if (raw is! Map) continue;
      final t = raw['text'];
      if (t is! String || t.trim().isEmpty) continue;
      final m = raw['minutes'];
      final minutes = m is num ? m.toInt() : 0;
      steps.add(
        MicroStep(
          t.trim(),
          suggestedDuration: minutes > 0 ? Duration(minutes: minutes) : null,
        ),
      );
      if (steps.length >= maxSteps) break;
    }
    if (steps.isEmpty) throw BreakdownException('The reply had no usable steps.');
    final note = parsed['note'];
    return BreakdownResult(
      steps: steps,
      source: source,
      note: note is String && note.trim().isNotEmpty ? note.trim() : null,
    );
  }

  static String _errorMessage(http.Response response) {
    String? detail;
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] is Map) {
        detail = (body['error'] as Map)['message'] as String?;
      }
    } catch (_) {}
    return switch (response.statusCode) {
      401 => 'The API key was not accepted.',
      403 => 'This key is not allowed to do that.',
      404 => 'The model or endpoint was not found. Check Settings.',
      429 => 'Rate limited. Try again in a moment.',
      >= 500 => 'The service had a problem. Try again later.',
      _ => detail ?? 'Request failed (${response.statusCode}).',
    };
  }
}
