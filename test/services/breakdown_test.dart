import 'dart:convert';

import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/services/breakdown/breakdown_config.dart';
import 'package:depress_o_buster/services/breakdown/claude_task_breakdown_service.dart';
import 'package:depress_o_buster/services/breakdown/mock_task_breakdown_service.dart';
import 'package:depress_o_buster/services/breakdown/task_breakdown_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('MockTaskBreakdownService', () {
    final service = MockTaskBreakdownService();

    test('is always available and names itself', () async {
      expect(await service.isAvailable(), isTrue);
      expect(service.name, contains('offline'));
    });

    test('matches a known task by keyword', () async {
      final r = await service.breakDown(const BreakdownRequest(taskTitle: 'do the laundry', maxSteps: 20));
      expect(r.steps.first.text, 'Think about laundry for 1 minute');
      expect(r.steps, hasLength(9));
      expect(r.source, service.name);
    });

    test('falls back to a generic ladder that names the task', () async {
      final r = await service.breakDown(const BreakdownRequest(taskTitle: 'Water the plants'));
      expect(r.steps.first.text, contains('Water the plants'));
      expect(r.steps.last.text, contains('Water the plants'));
    });

    test('goSmaller returns steps that end with the rung', () async {
      final r = await service.breakDown(
        const BreakdownRequest(
          taskTitle: 'Laundry',
          goSmaller: true,
          currentRung: 'Put 3 items in the basket',
          currentRungMinutes: 3,
        ),
      );
      expect(r.steps.last.text, 'Put 3 items in the basket');
      expect(r.steps.last.suggestedDuration, const Duration(minutes: 3));
      expect(r.steps.first.text, contains('Think about'));
    });

    test('respects maxSteps, keeping the first and the last', () async {
      final r = await service.breakDown(const BreakdownRequest(taskTitle: 'Laundry', maxSteps: 4));
      expect(r.steps, hasLength(4));
      expect(r.steps.first.text, 'Think about laundry for 1 minute');
      expect(r.steps.last.text, 'Full laundry cycle');
    });

    test('fit keeps order and bounds', () {
      final steps = [for (var i = 0; i < 10; i++) MicroStep('s$i')];
      expect(MockTaskBreakdownService.fit(steps, 1).map((s) => s.text), ['s0']);
      expect(MockTaskBreakdownService.fit(steps, 0), steps);
      final three = MockTaskBreakdownService.fit(steps, 3).map((s) => s.text).toList();
      expect(three, ['s0', 's5', 's9']);
    });
  });

  group('ClaudeTaskBreakdownService', () {
    const config = BreakdownConfig.defaults;

    test('request body uses structured JSON output, the configured model, no thinking override', () {
      final body = ClaudeTaskBreakdownService.buildRequestBody(
        const BreakdownRequest(taskTitle: 'Shower'),
        config,
      );
      expect(body['model'], 'claude-opus-5-5');
      expect(body['max_tokens'], 2048);
      expect(body['system'], config.systemPrompt);
      expect(body.containsKey('thinking'), isFalse);
      expect(body['fallbacks'], 'default');
      final out = body['output_config'] as Map<String, dynamic>;
      expect(out['effort'], 'medium');
      final format = out['format'] as Map<String, dynamic>;
      expect(format['type'], 'json_schema');
      final schema = format['schema'] as Map<String, dynamic>;
      expect(schema['additionalProperties'], isFalse);
      expect((schema['required'] as List), containsAll(['steps', 'note']));
      final messages = body['messages'] as List;
      expect(messages, hasLength(1));
      expect((messages.first as Map)['role'], 'user');
    });

    test('config copyWith swaps the model and drops the fallback', () {
      final c = config.copyWith(model: 'claude-haiku-5-5', useServerSideFallback: false);
      final body = ClaudeTaskBreakdownService.buildRequestBody(const BreakdownRequest(taskTitle: 'x'), c);
      expect(body['model'], 'claude-haiku-5-5');
      expect(body.containsKey('fallbacks'), isFalse);
    });

    test('user prompt carries the ladder, the feeling note and the go-smaller rule', () {
      final prompt = ClaudeTaskBreakdownService.buildUserPrompt(
        const BreakdownRequest(
          taskTitle: 'Laundry',
          taskNote: 'pile is on the chair',
          currentLadder: ['Think about laundry', 'Sit up'],
          currentRung: 'Sit up',
          goSmaller: true,
          feelingNote: 'very flat today',
          maxSteps: 6,
        ),
      );
      expect(prompt, contains('Task: Laundry'));
      expect(prompt, contains('pile is on the chair'));
      expect(prompt, contains('1. Think about laundry'));
      expect(prompt, contains('Go smaller than this step: "Sit up"'));
      expect(prompt, contains('very flat today'));
      expect(prompt, contains('between 4 and 6 steps'));
    });

    test('system prompt forbids cheering and health talk', () {
      expect(config.systemPrompt, contains('No cheering'));
      expect(config.systemPrompt.toLowerCase(), contains('absurdly small'));
      expect(config.systemPrompt, isNot(contains('!')));
    });

    Map<String, dynamic> reply(Map<String, dynamic> json, {String stop = 'end_turn'}) => {
      'id': 'msg_1',
      'type': 'message',
      'role': 'assistant',
      'model': 'claude-opus-5-5',
      'stop_reason': stop,
      'content': [
        {'type': 'text', 'text': jsonEncode(json)},
      ],
    };

    test('parseResponse maps steps and minutes, dropping blanks', () {
      final r = ClaudeTaskBreakdownService.parseResponse(
        reply({
          'steps': [
            {'text': 'Think about the shower for 1 minute', 'minutes': 1},
            {'text': '   ', 'minutes': 3},
            {'text': 'Stand in the bathroom doorway', 'minutes': 0},
          ],
          'note': ' Keep a towel within reach. ',
        }),
        source: 'Claude',
      );
      expect(r.steps, hasLength(2));
      expect(r.steps.first.suggestedDuration, const Duration(minutes: 1));
      expect(r.steps.last.suggestedDuration, isNull);
      expect(r.note, 'Keep a towel within reach.');
      expect(r.source, 'Claude');
    });

    test('parseResponse caps at maxSteps', () {
      final r = ClaudeTaskBreakdownService.parseResponse(
        reply({
          'steps': [for (var i = 0; i < 12; i++) {'text': 'step $i', 'minutes': 1}],
          'note': '',
        }),
        source: 'Claude',
        maxSteps: 5,
      );
      expect(r.steps, hasLength(5));
    });

    test('parseResponse rejects refusals, truncation, empty and malformed replies', () {
      expect(
        () => ClaudeTaskBreakdownService.parseResponse(reply({'steps': [], 'note': ''}, stop: 'refusal'), source: 'c'),
        throwsA(isA<BreakdownException>().having((e) => e.message, 'message', contains('declined'))),
      );
      expect(
        () => ClaudeTaskBreakdownService.parseResponse(reply({'steps': [], 'note': ''}, stop: 'max_tokens'), source: 'c'),
        throwsA(isA<BreakdownException>().having((e) => e.retryable, 'retryable', isTrue)),
      );
      expect(
        () => ClaudeTaskBreakdownService.parseResponse(reply({'steps': [], 'note': ''}), source: 'c'),
        throwsA(isA<BreakdownException>()),
      );
      expect(
        () => ClaudeTaskBreakdownService.parseResponse({
          'stop_reason': 'end_turn',
          'content': [{'type': 'text', 'text': 'not json'}],
        }, source: 'c'),
        throwsA(isA<BreakdownException>()),
      );
    });

    test('breakDown posts to /v1/messages with the right headers and parses the reply', () async {
      late http.Request seen;
      final client = MockClient((request) async {
        seen = request;
        return http.Response(
          jsonEncode(reply({
            'steps': [{'text': 'Sit up for 2 minutes', 'minutes': 2}],
            'note': '',
          })),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final service = ClaudeTaskBreakdownService(
        apiKeyProvider: () async => 'sk-test',
        client: client,
      );
      expect(await service.isAvailable(), isTrue);
      final r = await service.breakDown(const BreakdownRequest(taskTitle: 'Get up'));
      expect(seen.url.toString(), 'https://api.anthropic.com/v1/messages');
      expect(seen.method, 'POST');
      expect(seen.headers['x-api-key'], 'sk-test');
      expect(seen.headers['anthropic-version'], '2023-06-01');
      expect(seen.headers['anthropic-beta'], 'server-side-fallback-2026-07-01');
      expect(seen.headers['content-type'], startsWith('application/json'));
      final body = jsonDecode(seen.body) as Map<String, dynamic>;
      expect(body['model'], 'claude-opus-5-5');
      expect(r.steps.single.text, 'Sit up for 2 minutes');
      expect(r.source, contains('claude-opus-5-5'));
    });

    test('a custom base URL routes through a proxy', () async {
      late Uri seen;
      final client = MockClient((request) async {
        seen = request.url;
        return http.Response(jsonEncode(reply({'steps': [{'text': 'a', 'minutes': 0}], 'note': ''})), 200);
      });
      final service = ClaudeTaskBreakdownService(
        apiKeyProvider: () async => 'k',
        config: config.copyWith(baseUrl: 'https://proxy.example.com/claude'),
        client: client,
      );
      await service.breakDown(const BreakdownRequest(taskTitle: 'x'));
      expect(seen.toString(), 'https://proxy.example.com/claude/v1/messages');
    });

    test('no key: clear error, no network call', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      });
      final service = ClaudeTaskBreakdownService(apiKeyProvider: () async => '  ', client: client);
      expect(await service.isAvailable(), isFalse);
      await expectLater(
        service.breakDown(const BreakdownRequest(taskTitle: 'x')),
        throwsA(isA<BreakdownException>().having((e) => e.message, 'message', contains('API key'))),
      );
      expect(calls, 0);
    });

    test('HTTP errors map to plain messages; 429 and 5xx are retryable', () async {
      Future<BreakdownException> run(int status) async {
        final client = MockClient((_) async => http.Response('{"error":{"message":"nope"}}', status));
        final service = ClaudeTaskBreakdownService(apiKeyProvider: () async => 'k', client: client);
        try {
          await service.breakDown(const BreakdownRequest(taskTitle: 'x'));
        } on BreakdownException catch (e) {
          return e;
        }
        fail('expected an exception');
      }

      expect((await run(401)).message, contains('API key'));
      expect((await run(401)).retryable, isFalse);
      expect((await run(429)).retryable, isTrue);
      expect((await run(503)).retryable, isTrue);
      expect((await run(400)).message, 'nope');
    });
  });
}
