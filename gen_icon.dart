import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in sizes.entries) {
    await _generateIcon(entry.key, entry.value);
  }

  print('Icons generated!');
  exit(0);
}

Future<void> _generateIcon(String folder, int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));

  final bgPaint = Paint()..color = const Color(0xFFF3F4F6);
  final shadowDark = Paint()
    ..color = const Color(0x1F000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final shadowLight = Paint()
    ..color = const Color(0xF2FFFFFF)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final accentPaint = Paint()..color = const Color(0xFFFF9F1C);
  final notePaint = Paint()..color = Colors.white;

  final r = size * 0.22;
  final cx = size * 0.5;
  final cy = size * 0.5;

  // Background circle
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), Radius.circular(size * 0.25)),
    bgPaint,
  );

  // Neumorphic shadow - dark
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, size - 4, size - 4), Radius.circular(size * 0.24)),
    shadowDark,
  );

  // Inner circle (accent)
  canvas.drawOval(
    Rect.fromCenter(center: Offset(cx, cy), width: r * 2.6, height: r * 2.6),
    accentPaint,
  );

  // Music note - simplified
  final noteSize = size * 0.28;
  final noteX = cx - noteSize * 0.1;
  final noteY = cy + noteSize * 0.15;

  // Note head (circle)
  canvas.drawOval(
    Rect.fromCenter(center: Offset(noteX - noteSize * 0.15, noteY), width: noteSize * 0.35, height: noteSize * 0.28),
    notePaint,
  );

  // Note stem
  final stemPaint = Paint()
    ..color = Colors.white
    ..strokeWidth = size * 0.035
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(noteX + noteSize * 0.02, noteY - noteSize * 0.02),
    Offset(noteX + noteSize * 0.02, noteY - noteSize * 0.45),
    stemPaint,
  );

  // Note flag
  final flagPath = Path();
  flagPath.moveTo(noteX + noteSize * 0.02, noteY - noteSize * 0.45);
  flagPath.quadraticBezierTo(
    noteX + noteSize * 0.25, noteY - noteSize * 0.3,
    noteX + noteSize * 0.02, noteY - noteSize * 0.15,
  );
  canvas.drawPath(flagPath, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = size * 0.025..strokeCap = StrokeCap.round);

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  final dir = Directory('android/app/src/main/res/$folder');
  if (!await dir.exists()) await dir.create(recursive: true);
  await File('${dir.path}/ic_launcher.png').writeAsBytes(bytes);
  await File('${dir.path}/ic_launcher_round.png').writeAsBytes(bytes);

  print('Generated $folder ($size x $size)');
}
