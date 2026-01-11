import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Multi-Object Detection Service for Waste Items
/// Uses REGION-BASED ANALYSIS for detecting multiple waste objects
/// 
/// Research Paper Reference:
/// - Algorithm: Sliding Window + Region Analysis + Color Clustering
/// - Features: Connected component analysis, color segmentation, skin detection
/// - This is a rule-based detector inspired by YOLO/SSD patterns
class MultiObjectDetectionService {
  static bool _isInitialized = false;
  
  // Detection parameters
  static const int _gridSize = 7; // 7x7 grid like YOLO
  static const double _confidenceThreshold = 0.55; // Higher threshold for better accuracy
  static const double _iouThreshold = 0.4; // For NMS
  static const double _minTextureScore = 0.08; // Minimum texture to be considered an object
  
  // Skin tone detection ranges (HSV)
  static const double _skinHueMin = 0;
  static const double _skinHueMax = 50;
  static const double _skinSatMin = 0.15;
  static const double _skinSatMax = 0.75;
  static const double _skinValMin = 0.2;
  static const double _skinValMax = 0.95;
  
  // Waste type color ranges (HSV)
  static final Map<String, List<ColorRange>> _wasteColorRanges = {
    'Organic': [
      ColorRange(hMin: 20, hMax: 45, sMin: 0.3, sMax: 1.0, vMin: 0.2, vMax: 0.8),  // Brown
      ColorRange(hMin: 60, hMax: 150, sMin: 0.2, sMax: 1.0, vMin: 0.2, vMax: 0.9), // Green
      ColorRange(hMin: 45, hMax: 60, sMin: 0.4, sMax: 1.0, vMin: 0.3, vMax: 0.9),  // Yellow-green
    ],
    'Recyclable': [
      ColorRange(hMin: 0, hMax: 30, sMin: 0.0, sMax: 0.1, vMin: 0.8, vMax: 1.0),   // White/clear
      ColorRange(hMin: 180, hMax: 240, sMin: 0.1, sMax: 0.5, vMin: 0.5, vMax: 0.9), // Blue plastic
      ColorRange(hMin: 0, hMax: 360, sMin: 0.0, sMax: 0.15, vMin: 0.6, vMax: 0.95), // Silver/gray
    ],
    'Hazardous': [
      ColorRange(hMin: 0, hMax: 20, sMin: 0.6, sMax: 1.0, vMin: 0.4, vMax: 0.9),   // Red
      ColorRange(hMin: 340, hMax: 360, sMin: 0.6, sMax: 1.0, vMin: 0.4, vMax: 0.9), // Red (wraparound)
      ColorRange(hMin: 20, hMax: 40, sMin: 0.7, sMax: 1.0, vMin: 0.5, vMax: 0.95),  // Orange
    ],
    'E-Waste': [
      ColorRange(hMin: 0, hMax: 360, sMin: 0.0, sMax: 0.2, vMin: 0.0, vMax: 0.3),  // Black
      ColorRange(hMin: 0, hMax: 360, sMin: 0.0, sMax: 0.15, vMin: 0.3, vMax: 0.5), // Dark gray
      ColorRange(hMin: 200, hMax: 260, sMin: 0.2, sMax: 0.6, vMin: 0.2, vMax: 0.5), // Dark blue
    ],
    'General': [
      ColorRange(hMin: 0, hMax: 360, sMin: 0.0, sMax: 0.3, vMin: 0.3, vMax: 0.7),  // Mixed gray
    ],
  };

  /// Initialize the detection service
  static Future<bool> initialize() async {
    _isInitialized = true;
    if (kDebugMode) {
      print('MultiObjectDetection: Initialized with grid-based region analysis');
    }
    return true;
  }

  /// Check if initialized
  static bool get isInitialized => _isInitialized;

  /// Detect objects from image file path
  static Future<DetectionResult> detectObjects(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return DetectionResult(
          detections: [],
          imageWidth: 0,
          imageHeight: 0,
          processingTimeMs: 0,
          analysisDetails: 'Image file not found',
        );
      }
      
      final bytes = await file.readAsBytes();
      return detectObjectsFromBytes(bytes);
    } catch (e) {
      if (kDebugMode) {
        print('MultiObjectDetection: Error reading image: $e');
      }
      return DetectionResult(
        detections: [],
        imageWidth: 0,
        imageHeight: 0,
        processingTimeMs: 0,
        analysisDetails: 'Error processing image: $e',
      );
    }
  }

  /// Detect objects from image bytes
  static Future<DetectionResult> detectObjectsFromBytes(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final stopwatch = Stopwatch()..start();
    
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return DetectionResult(
          detections: [],
          imageWidth: 0,
          imageHeight: 0,
          processingTimeMs: stopwatch.elapsedMilliseconds,
          analysisDetails: 'Could not decode image',
        );
      }
      
      // Resize for processing
      final processSize = 448; // Processing resolution
      final resized = img.copyResize(image, width: processSize, height: processSize);
      
      // Detect regions using grid-based analysis
      final detections = <Detection>[];
      final cellWidth = processSize ~/ _gridSize;
      final cellHeight = processSize ~/ _gridSize;
      
      // Analyze each grid cell
      for (int gy = 0; gy < _gridSize; gy++) {
        for (int gx = 0; gx < _gridSize; gx++) {
          final cellX = gx * cellWidth;
          final cellY = gy * cellHeight;
          
          // Analyze cell region
          final cellAnalysis = _analyzeRegion(
            resized, 
            cellX, 
            cellY, 
            cellWidth, 
            cellHeight,
          );
          
          // Check if this cell has significant content
          if (cellAnalysis.confidence > _confidenceThreshold && cellAnalysis.hasContent) {
            // Convert to original image coordinates
            final scaleX = image.width / processSize;
            final scaleY = image.height / processSize;
            
            detections.add(Detection(
              label: cellAnalysis.wasteType,
              confidence: cellAnalysis.confidence,
              boundingBox: BoundingBox(
                x: (cellX * scaleX).round(),
                y: (cellY * scaleY).round(),
                width: (cellWidth * scaleX).round(),
                height: (cellHeight * scaleY).round(),
              ),
              colorProfile: cellAnalysis.dominantColor,
            ));
          }
        }
      }
      
      // Merge adjacent cells of same type
      final mergedDetections = _mergeAdjacentDetections(detections);
      
      // Apply Non-Maximum Suppression
      final finalDetections = _nonMaximumSuppression(mergedDetections);
      
      stopwatch.stop();
      
      final analysisDetails = '''
Detection Analysis:
- Grid Size: ${_gridSize}x$_gridSize
- Cells Analyzed: ${_gridSize * _gridSize}
- Regions Detected: ${detections.length}
- After Merge: ${mergedDetections.length}
- Final Detections: ${finalDetections.length}
- Processing Time: ${stopwatch.elapsedMilliseconds}ms
''';
      
      if (kDebugMode) {
        print('MultiObjectDetection: Found ${finalDetections.length} objects in ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return DetectionResult(
        detections: finalDetections,
        imageWidth: image.width,
        imageHeight: image.height,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        analysisDetails: analysisDetails,
      );
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print('MultiObjectDetection: Detection error: $e');
      }
      return DetectionResult(
        detections: [],
        imageWidth: 0,
        imageHeight: 0,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        analysisDetails: 'Detection error: $e',
      );
    }
  }

  /// Analyze a region of the image
  static RegionAnalysis _analyzeRegion(
    img.Image image, 
    int startX, 
    int startY, 
    int width, 
    int height,
  ) {
    final hueHistogram = List<int>.filled(360, 0);
    double totalSaturation = 0;
    double totalValue = 0;
    double totalEdge = 0;
    int pixelCount = 0;
    int edgeCount = 0;
    int skinPixelCount = 0;
    int backgroundPixelCount = 0;
    
    // Sample pixels in region
    for (int y = startY; y < startY + height && y < image.height; y++) {
      for (int x = startX; x < startX + width && x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        final hsv = _rgbToHsv(r, g, b);
        hueHistogram[hsv.h.floor() % 360]++;
        totalSaturation += hsv.s;
        totalValue += hsv.v;
        pixelCount++;
        
        // Check for skin tone
        if (_isSkinTone(hsv.h, hsv.s, hsv.v, r, g, b)) {
          skinPixelCount++;
        }
        
        // Check for common background colors (white, beige, gray)
        if (_isBackgroundColor(hsv.h, hsv.s, hsv.v)) {
          backgroundPixelCount++;
        }
        
        // Edge detection
        if (x > startX && y > startY) {
          final prevX = image.getPixel(x - 1, y);
          final prevY = image.getPixel(x, y - 1);
          final gx = ((r - prevX.r.toInt()).abs() + 
                      (g - prevX.g.toInt()).abs() + 
                      (b - prevX.b.toInt()).abs()) / 765.0;
          final gy = ((r - prevY.r.toInt()).abs() + 
                      (g - prevY.g.toInt()).abs() + 
                      (b - prevY.b.toInt()).abs()) / 765.0;
          totalEdge += sqrt(gx * gx + gy * gy);
          edgeCount++;
        }
      }
    }
    
    if (pixelCount == 0) {
      return RegionAnalysis(
        wasteType: 'None',
        confidence: 0,
        hasContent: false,
        dominantColor: 'Unknown',
        isSkin: false,
        isBackground: false,
      );
    }
    
    // Calculate ratios
    final skinRatio = skinPixelCount / pixelCount;
    final backgroundRatio = backgroundPixelCount / pixelCount;
    final avgEdge = edgeCount > 0 ? totalEdge / edgeCount : 0.0;
    
    // If mostly skin, mark as human/not waste
    if (skinRatio > 0.4) {
      return RegionAnalysis(
        wasteType: 'Human',
        confidence: 0,
        hasContent: false,
        dominantColor: 'Skin',
        isSkin: true,
        isBackground: false,
      );
    }
    
    // If mostly background, skip
    if (backgroundRatio > 0.7 && avgEdge < 0.03) {
      return RegionAnalysis(
        wasteType: 'Background',
        confidence: 0,
        hasContent: false,
        dominantColor: 'Background',
        isSkin: false,
        isBackground: true,
      );
    }
    
    // Find dominant hue
    int dominantHue = 0;
    int maxCount = 0;
    for (int h = 0; h < 360; h++) {
      int count = 0;
      for (int delta = -15; delta <= 15; delta++) {
        count += hueHistogram[(h + delta + 360) % 360];
      }
      if (count > maxCount) {
        maxCount = count;
        dominantHue = h;
      }
    }
    
    final avgSaturation = totalSaturation / pixelCount;
    final avgValue = totalValue / pixelCount;
    
    // Check if region has enough texture to be an object (not flat surface)
    final variance = _calculateColorVariance(hueHistogram, pixelCount);
    final hasEnoughTexture = avgEdge > _minTextureScore;
    final hasContent = (variance > 0.08 || avgEdge > 0.06) && hasEnoughTexture;
    
    // If not enough texture/edges, likely not a distinct waste object
    if (!hasContent) {
      return RegionAnalysis(
        wasteType: 'None',
        confidence: 0,
        hasContent: false,
        dominantColor: _hueToColorName(dominantHue),
        isSkin: false,
        isBackground: true,
      );
    }
    
    // Determine waste type
    String bestType = 'General';
    double bestScore = 0;
    
    for (var entry in _wasteColorRanges.entries) {
      double score = 0;
      for (var range in entry.value) {
        if (range.matches(dominantHue.toDouble(), avgSaturation, avgValue)) {
          score = max(score, 0.75);
        } else {
          score = max(score, range.partialMatch(dominantHue.toDouble(), avgSaturation, avgValue));
        }
      }
      
      // E-Waste needs high edge/texture (electronics have complex patterns)
      if (entry.key == 'E-Waste') {
        if (avgEdge > 0.12) {
          score += 0.15;
        } else {
          score *= 0.5; // Reduce score if not textured enough
        }
      }
      
      // Hazardous usually has distinct warning colors
      if (entry.key == 'Hazardous' && avgSaturation < 0.5) {
        score *= 0.5;
      }
      
      if (score > bestScore) {
        bestScore = score;
        bestType = entry.key;
      }
    }
    
    // Apply penalties for skin-adjacent regions and low texture
    double confidence = bestScore * (0.6 + variance * 0.2 + avgEdge * 0.2);
    
    // Penalty if there's some skin in the region (might be human holding something)
    if (skinRatio > 0.15) {
      confidence *= 0.6;
    }
    
    // Penalty for low texture (likely background or clothing)
    if (avgEdge < 0.05) {
      confidence *= 0.5;
    }
    
    return RegionAnalysis(
      wasteType: bestType,
      confidence: confidence.toDouble(),
      hasContent: hasContent,
      dominantColor: _hueToColorName(dominantHue),
      isSkin: skinRatio > 0.2,
      isBackground: backgroundRatio > 0.5,
    );
  }

  /// Calculate color variance
  static double _calculateColorVariance(List<int> hueHistogram, int total) {
    if (total == 0) return 0;
    
    // Count bins with significant content
    int significantBins = 0;
    for (int h = 0; h < 360; h += 30) {
      int binCount = 0;
      for (int i = 0; i < 30; i++) {
        binCount += hueHistogram[(h + i) % 360];
      }
      if (binCount > total * 0.05) {
        significantBins++;
      }
    }
    
    return significantBins / 12.0; // Normalize to 0-1
  }

  /// Merge adjacent detections of same type
  static List<Detection> _mergeAdjacentDetections(List<Detection> detections) {
    if (detections.isEmpty) return [];
    
    final merged = <Detection>[];
    final used = List<bool>.filled(detections.length, false);
    
    for (int i = 0; i < detections.length; i++) {
      if (used[i]) continue;
      
      var current = detections[i];
      used[i] = true;
      
      // Find adjacent detections of same type
      bool foundMerge = true;
      while (foundMerge) {
        foundMerge = false;
        for (int j = 0; j < detections.length; j++) {
          if (used[j]) continue;
          if (detections[j].label != current.label) continue;
          
          // Check if adjacent
          if (_areAdjacent(current.boundingBox, detections[j].boundingBox)) {
            current = _mergeBoxes(current, detections[j]);
            used[j] = true;
            foundMerge = true;
          }
        }
      }
      
      merged.add(current);
    }
    
    return merged;
  }

  /// Check if two boxes are adjacent
  static bool _areAdjacent(BoundingBox a, BoundingBox b) {
    final margin = 10; // Pixels
    return !(a.x + a.width + margin < b.x ||
             b.x + b.width + margin < a.x ||
             a.y + a.height + margin < b.y ||
             b.y + b.height + margin < a.y);
  }

  /// Merge two detections
  static Detection _mergeBoxes(Detection a, Detection b) {
    final minX = min(a.boundingBox.x, b.boundingBox.x);
    final minY = min(a.boundingBox.y, b.boundingBox.y);
    final maxX = max(a.boundingBox.x + a.boundingBox.width, 
                     b.boundingBox.x + b.boundingBox.width);
    final maxY = max(a.boundingBox.y + a.boundingBox.height, 
                     b.boundingBox.y + b.boundingBox.height);
    
    return Detection(
      label: a.label,
      confidence: (a.confidence + b.confidence) / 2,
      boundingBox: BoundingBox(
        x: minX,
        y: minY,
        width: maxX - minX,
        height: maxY - minY,
      ),
      colorProfile: a.colorProfile,
    );
  }

  /// Non-Maximum Suppression
  static List<Detection> _nonMaximumSuppression(List<Detection> detections) {
    if (detections.isEmpty) return [];
    
    // Sort by confidence
    final sorted = List<Detection>.from(detections);
    sorted.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    final result = <Detection>[];
    final suppressed = List<bool>.filled(sorted.length, false);
    
    for (int i = 0; i < sorted.length; i++) {
      if (suppressed[i]) continue;
      
      result.add(sorted[i]);
      
      for (int j = i + 1; j < sorted.length; j++) {
        if (suppressed[j]) continue;
        
        final iou = _calculateIoU(sorted[i].boundingBox, sorted[j].boundingBox);
        if (iou > _iouThreshold) {
          suppressed[j] = true;
        }
      }
    }
    
    return result;
  }

  /// Calculate Intersection over Union
  static double _calculateIoU(BoundingBox a, BoundingBox b) {
    final interLeft = max(a.x, b.x);
    final interTop = max(a.y, b.y);
    final interRight = min(a.x + a.width, b.x + b.width);
    final interBottom = min(a.y + a.height, b.y + b.height);
    
    if (interRight <= interLeft || interBottom <= interTop) {
      return 0;
    }
    
    final interArea = (interRight - interLeft) * (interBottom - interTop);
    final aArea = a.width * a.height;
    final bArea = b.width * b.height;
    final unionArea = aArea + bArea - interArea;
    
    return unionArea > 0 ? interArea / unionArea : 0;
  }

  /// Convert RGB to HSV
  static HSV _rgbToHsv(int r, int g, int b) {
    final rNorm = r / 255.0;
    final gNorm = g / 255.0;
    final bNorm = b / 255.0;
    
    final maxC = max(max(rNorm, gNorm), bNorm);
    final minC = min(min(rNorm, gNorm), bNorm);
    final delta = maxC - minC;
    
    double h = 0;
    if (delta > 0) {
      if (maxC == rNorm) {
        h = 60 * (((gNorm - bNorm) / delta) % 6);
      } else if (maxC == gNorm) {
        h = 60 * (((bNorm - rNorm) / delta) + 2);
      } else {
        h = 60 * (((rNorm - gNorm) / delta) + 4);
      }
    }
    if (h < 0) h += 360;
    
    final s = maxC > 0 ? delta / maxC : 0.0;
    final v = maxC;
    
    return HSV(h, s.toDouble(), v.toDouble());
  }

  /// Check if pixel is skin tone (works for various skin colors)
  static bool _isSkinTone(double h, double s, double v, int r, int g, int b) {
    // HSV-based skin detection
    bool hsvSkin = (h >= _skinHueMin && h <= _skinHueMax) &&
                   (s >= _skinSatMin && s <= _skinSatMax) &&
                   (v >= _skinValMin && v <= _skinValMax);
    
    // RGB-based skin detection (more robust for different lighting)
    // Rule: R > 95, G > 40, B > 20, max(R,G,B) - min(R,G,B) > 15, |R-G| > 15, R > G, R > B
    bool rgbSkin = r > 95 && g > 40 && b > 20 &&
                   (max(max(r, g), b) - min(min(r, g), b)) > 15 &&
                   (r - g).abs() > 15 &&
                   r > g && r > b;
    
    // YCbCr color space check (commonly used for skin detection)
    double y = 0.299 * r + 0.587 * g + 0.114 * b;
    double cb = 128 - 0.168736 * r - 0.331264 * g + 0.5 * b;
    double cr = 128 + 0.5 * r - 0.418688 * g - 0.081312 * b;
    bool ycbcrSkin = cr >= 133 && cr <= 173 && cb >= 77 && cb <= 127;
    
    // Return true if at least 2 methods agree
    int skinVotes = (hsvSkin ? 1 : 0) + (rgbSkin ? 1 : 0) + (ycbcrSkin ? 1 : 0);
    return skinVotes >= 2;
  }

  /// Check if pixel is likely background (walls, floors, furniture)
  static bool _isBackgroundColor(double h, double s, double v) {
    // White/off-white backgrounds
    if (s < 0.15 && v > 0.7) return true;
    
    // Gray backgrounds
    if (s < 0.1 && v > 0.3 && v < 0.8) return true;
    
    // Beige/cream (common wall colors)
    if (h >= 30 && h <= 50 && s < 0.25 && v > 0.6) return true;
    
    // Very dark (shadows)
    if (v < 0.15) return true;
    
    return false;
  }

  /// Convert hue to color name
  static String _hueToColorName(int hue) {
    if (hue < 15 || hue >= 345) return 'Red';
    if (hue < 45) return 'Orange';
    if (hue < 75) return 'Yellow';
    if (hue < 150) return 'Green';
    if (hue < 210) return 'Cyan';
    if (hue < 270) return 'Blue';
    if (hue < 315) return 'Purple';
    return 'Pink';
  }

  /// Dispose resources
  static void dispose() {
    _isInitialized = false;
    if (kDebugMode) {
      print('MultiObjectDetection: Disposed');
    }
  }
}

/// Color range for waste type detection
class ColorRange {
  final int hMin, hMax;
  final double sMin, sMax;
  final double vMin, vMax;
  
  ColorRange({
    required this.hMin,
    required this.hMax,
    required this.sMin,
    required this.sMax,
    required this.vMin,
    required this.vMax,
  });
  
  bool matches(double h, double s, double v) {
    bool hueMatch = hMax >= hMin 
        ? (h >= hMin && h <= hMax)
        : (h >= hMin || h <= hMax); // Handle wraparound
    return hueMatch && s >= sMin && s <= sMax && v >= vMin && v <= vMax;
  }
  
  double partialMatch(double h, double s, double v) {
    double score = 0;
    
    // Hue score
    final hMid = (hMin + hMax) / 2;
    final hRange = (hMax - hMin) / 2;
    final hDiff = min((h - hMid).abs(), 360 - (h - hMid).abs());
    score += max(0, 1 - hDiff / (hRange + 30)) * 0.4;
    
    // Saturation score
    final sMid = (sMin + sMax) / 2;
    final sRange = (sMax - sMin) / 2;
    score += max(0, 1 - (s - sMid).abs() / (sRange + 0.2)) * 0.3;
    
    // Value score
    final vMid = (vMin + vMax) / 2;
    final vRange = (vMax - vMin) / 2;
    score += max(0, 1 - (v - vMid).abs() / (vRange + 0.2)) * 0.3;
    
    return score;
  }
}

/// HSV color representation
class HSV {
  final double h;
  final double s;
  final double v;
  
  HSV(this.h, this.s, this.v);
}

/// Region analysis result
class RegionAnalysis {
  final String wasteType;
  final double confidence;
  final bool hasContent;
  final String dominantColor;
  final bool isSkin;
  final bool isBackground;
  
  RegionAnalysis({
    required this.wasteType,
    required this.confidence,
    required this.hasContent,
    required this.dominantColor,
    this.isSkin = false,
    this.isBackground = false,
  });
}

/// Detection bounding box
class BoundingBox {
  final int x;
  final int y;
  final int width;
  final int height;
  
  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
  
  int get right => x + width;
  int get bottom => y + height;
  int get centerX => x + width ~/ 2;
  int get centerY => y + height ~/ 2;
  int get area => width * height;
}

/// Single detection result
class Detection {
  final String label;
  final double confidence;
  final BoundingBox boundingBox;
  final String colorProfile;
  
  Detection({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.colorProfile = '',
  });
  
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}

/// Overall detection result
class DetectionResult {
  final List<Detection> detections;
  final int imageWidth;
  final int imageHeight;
  final int processingTimeMs;
  final String analysisDetails;
  
  DetectionResult({
    required this.detections,
    required this.imageWidth,
    required this.imageHeight,
    required this.processingTimeMs,
    required this.analysisDetails,
  });
  
  int get objectCount => detections.length;
  bool get hasDetections => detections.isNotEmpty;
  
  Map<String, int> get wasteTypeCounts {
    final counts = <String, int>{};
    for (var detection in detections) {
      counts[detection.label] = (counts[detection.label] ?? 0) + 1;
    }
    return counts;
  }
}
