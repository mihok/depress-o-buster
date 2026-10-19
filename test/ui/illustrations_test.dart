import 'dart:io';

import 'package:depress_o_buster/ui/widgets/illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// The contract in docs/VISUALS.md, checked against the files on disk.
void main() {
  const palette = {'#8FB39A', '#8E9BC7', '#E6E8EA', '#9AA3AB', '#1F2328', '#0F1114'};
  const glint = '#FFFFFF'; // always light, never mapped
  const forbiddenElements = ['filter', 'style', 'text', 'image', 'mask', 'use', 'foreignObject'];

  group('illustration files', () {
    for (final kind in Illustration.values) {
      final file = File(kind.assetPath);

      test('${kind.file}: exists and is small', () {
        expect(file.existsSync(), isTrue, reason: '${kind.assetPath} is missing');
        expect(file.lengthSync(), lessThan(4096), reason: 'a handful of shapes, not a painting');
      });

      test('${kind.file}: uses only palette colours and the flutter_svg subset', () {
        final text = file.readAsStringSync();
        final colours = RegExp(r'#[0-9a-fA-F]{6}\b').allMatches(text).map((m) => m[0]!.toUpperCase()).toSet();
        expect(colours.difference({...palette, glint}), isEmpty, reason: 'off-palette colours cannot be themed');
        for (final name in forbiddenElements) {
          expect(RegExp('<$name[\\s>]').hasMatch(text), isFalse, reason: '<$name> is outside the flutter_svg subset');
        }
        expect(text.contains('class='), isFalse, reason: 'CSS classes are not supported');
        expect(text.contains('xmlns="http://www.w3.org/2000/svg"'), isTrue);
      });

      if (kind.followsTheme) {
        test('${kind.file}: has the shared viewBox and no fixed size', () {
          final text = file.readAsStringSync();
          final root = RegExp(r'<svg[^>]*>').firstMatch(text)![0]!;
          expect(root, contains('viewBox="0 0 240 160"'));
          expect(RegExp(r'\swidth=').hasMatch(root), isFalse, reason: 'size comes from the widget');
          expect(RegExp(r'\sheight=').hasMatch(root), isFalse, reason: 'size comes from the widget');
        });
      }
    }
  });

  group('PaletteMapper', () {
    test('light maps every palette colour and leaves others alone', () {
      const mapper = PaletteMapper.light;
      for (final hex in palette) {
        final value = int.parse('FF${hex.substring(1)}', radix: 16);
        final mapped = mapper.substitute(null, 'path', 'fill', Color(value));
        expect(mapped.toARGB32(), isNot(value), reason: '$hex should change in the light theme');
      }
      expect(mapper.substitute(null, 'path', 'fill', const Color(0xFFFFFFFF)).toARGB32(), 0xFFFFFFFF, reason: 'glint stays light');
      expect(mapper.substitute(null, 'path', 'fill', const Color(0xFF123456)).toARGB32(), 0xFF123456);
    });

    test('dark is the identity', () {
      const mapper = PaletteMapper.dark;
      for (final hex in palette) {
        final value = int.parse('FF${hex.substring(1)}', radix: 16);
        expect(mapper.substitute(null, 'path', 'fill', Color(value)).toARGB32(), value);
      }
    });
  });

  group('AppIllustration renders', () {
    for (final brightness in [Brightness.dark, Brightness.light]) {
      testWidgets('every illustration parses in the ${brightness.name} theme', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: Scaffold(
                body: ListView(
                  children: [for (final k in Illustration.values) AppIllustration(k, height: 80)],
                ),
              ),
            ),
          );
          // Asset loading is real I/O: give it a moment, then settle.
          await Future<void>.delayed(const Duration(milliseconds: 400));
          await tester.pump();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        });
        expect(tester.takeException(), isNull);
        expect(find.byType(SvgPicture), findsNWidgets(Illustration.values.length));
      });
    }

    testWidgets('decorative by default, labelled when asked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppIllustration(Illustration.stoneStill, height: 40),
                AppIllustration(Illustration.restMoon, height: 40, decorative: false),
              ],
            ),
          ),
        ),
      );
      final pictures = tester.widgetList<SvgPicture>(find.byType(SvgPicture)).toList();
      expect((pictures[0].bytesLoader as SvgAssetLoader).colorMapper, isNotNull, reason: 'themed');
      expect(pictures[0].excludeFromSemantics, isTrue);
      expect(pictures[1].excludeFromSemantics, isFalse);
      expect(pictures[1].semanticsLabel, Illustration.restMoon.description);
    });

    testWidgets('the mark keeps its brand colours in the light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: const Scaffold(body: AppIllustration(Illustration.mark, height: 40)),
        ),
      );
      final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect((picture.bytesLoader as SvgAssetLoader).colorMapper, isNull);
    });
  });
}
