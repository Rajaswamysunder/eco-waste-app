// Run this script to generate the app icon
// dart run tool/generate_icon.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';

void main() async {
  print('Generating Smart Waste App icons...');
  
  // Create main app icon (1024x1024)
  await generateMainIcon();
  
  // Create foreground icon for adaptive icons
  await generateForegroundIcon();
  
  print('Icons generated successfully!');
  print('');
  print('Now run: flutter pub get && dart run flutter_launcher_icons');
}

Future<void> generateMainIcon() async {
  final size = 1024;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  
  // Green background
  final bgPaint = ui.Paint()
    ..color = const ui.Color(0xFF4CAF50);
  canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), bgPaint);
  
  // Draw recycle symbol
  final centerX = size / 2;
  final centerY = size / 2;
  final radius = size * 0.35;
  
  final arrowPaint = ui.Paint()
    ..color = const ui.Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = size * 0.08
    ..strokeCap = ui.StrokeCap.round;
  
  // Draw 3 curved arrows in a cycle
  for (int i = 0; i < 3; i++) {
    final angle = (i * 120 - 90) * pi / 180;
    final nextAngle = ((i + 1) * 120 - 90) * pi / 180;
    
    final startX = centerX + radius * cos(angle);
    final startY = centerY + radius * sin(angle);
    final endX = centerX + radius * cos(nextAngle);
    final endY = centerY + radius * sin(nextAngle);
    
    final path = ui.Path();
    path.moveTo(startX, startY);
    path.arcToPoint(
      ui.Offset(endX, endY),
      radius: ui.Radius.circular(radius),
      clockwise: true,
    );
    
    canvas.drawPath(path, arrowPaint);
    
    // Draw arrowhead
    final arrowHeadPaint = ui.Paint()
      ..color = const ui.Color(0xFFFFFFFF)
      ..style = ui.PaintingStyle.fill;
    
    final arrowSize = size * 0.1;
    final arrowAngle = nextAngle + pi / 6;
    
    final arrowPath = ui.Path();
    arrowPath.moveTo(endX, endY);
    arrowPath.lineTo(
      endX - arrowSize * cos(arrowAngle - pi / 6),
      endY - arrowSize * sin(arrowAngle - pi / 6),
    );
    arrowPath.lineTo(
      endX - arrowSize * cos(arrowAngle + pi / 6),
      endY - arrowSize * sin(arrowAngle + pi / 6),
    );
    arrowPath.close();
    
    canvas.drawPath(arrowPath, arrowHeadPaint);
  }
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  
  if (byteData != null) {
    final file = File('assets/icon/app_icon.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    print('Created: assets/icon/app_icon.png');
  }
}

Future<void> generateForegroundIcon() async {
  final size = 1024;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  
  // Transparent background
  final bgPaint = ui.Paint()
    ..color = const ui.Color(0x00000000);
  canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), bgPaint);
  
  // Draw recycle symbol (same as main but on transparent bg)
  final centerX = size / 2;
  final centerY = size / 2;
  final radius = size * 0.3;
  
  final arrowPaint = ui.Paint()
    ..color = const ui.Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = size * 0.06
    ..strokeCap = ui.StrokeCap.round;
  
  for (int i = 0; i < 3; i++) {
    final angle = (i * 120 - 90) * pi / 180;
    final nextAngle = ((i + 1) * 120 - 90) * pi / 180;
    
    final startX = centerX + radius * cos(angle);
    final startY = centerY + radius * sin(angle);
    final endX = centerX + radius * cos(nextAngle);
    final endY = centerY + radius * sin(nextAngle);
    
    final path = ui.Path();
    path.moveTo(startX, startY);
    path.arcToPoint(
      ui.Offset(endX, endY),
      radius: ui.Radius.circular(radius),
      clockwise: true,
    );
    
    canvas.drawPath(path, arrowPaint);
  }
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  
  if (byteData != null) {
    final file = File('assets/icon/app_icon_foreground.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    print('Created: assets/icon/app_icon_foreground.png');
  }
}
