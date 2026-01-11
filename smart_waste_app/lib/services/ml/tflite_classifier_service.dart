import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// TensorFlow Lite-style Waste Classifier Service
/// Uses COLOR HISTOGRAM and TEXTURE ANALYSIS for classification
/// 
/// Research Paper Reference:
/// - Algorithms: Color Histogram Analysis, Texture Feature Extraction
/// - Features: HSV color space, edge detection, contrast analysis
/// - This is a rule-based ML classifier inspired by TFLite patterns
class TFLiteClassifierService {
  static bool _isInitialized = false;
  
  // Waste type definitions with color and texture profiles
  static final Map<String, WasteProfile> _wasteProfiles = {
    'Organic': WasteProfile(
      dominantHues: [30, 60, 90, 120], // Brown, green, yellow
      saturationRange: (0.2, 0.7),
      valueRange: (0.2, 0.7),
      textureScore: 0.4, // Medium texture
      keywords: ['food', 'leaf', 'plant', 'fruit', 'vegetable', 'compost'],
    ),
    'Recyclable': WasteProfile(
      dominantHues: [180, 200, 220, 240], // Blue, cyan (plastics, metals)
      saturationRange: (0.1, 0.4),
      valueRange: (0.5, 0.95),
      textureScore: 0.2, // Smooth
      keywords: ['plastic', 'bottle', 'can', 'metal', 'paper', 'cardboard'],
    ),
    'Hazardous': WasteProfile(
      dominantHues: [0, 15, 345, 330], // Red, orange (warning colors)
      saturationRange: (0.5, 1.0),
      valueRange: (0.3, 0.8),
      textureScore: 0.3,
      keywords: ['battery', 'chemical', 'paint', 'oil', 'medicine'],
    ),
    'E-Waste': WasteProfile(
      dominantHues: [0, 180, 200, 280], // Black/dark with some blue
      saturationRange: (0.0, 0.3),
      valueRange: (0.0, 0.4),
      textureScore: 0.5, // Complex patterns
      keywords: ['electronic', 'phone', 'computer', 'cable', 'battery'],
    ),
    'General': WasteProfile(
      dominantHues: [0, 30, 180, 210], // Various
      saturationRange: (0.0, 0.5),
      valueRange: (0.2, 0.8),
      textureScore: 0.5,
      keywords: ['mixed', 'trash', 'garbage', 'waste'],
    ),
  };

  /// Initialize the classifier
  static Future<bool> initialize() async {
    _isInitialized = true;
    if (kDebugMode) {
      print('TFLiteClassifier: Initialized with color-texture analysis model');
    }
    return true;
  }

  /// Check if initialized
  static bool get isInitialized => _isInitialized;

  /// Classify waste from image file path
  static Future<ClassificationResult> classifyImage(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return ClassificationResult(
          label: 'Unknown',
          confidence: 0.0,
          allPredictions: {},
          analysisDetails: 'Image file not found',
        );
      }
      
      final bytes = await file.readAsBytes();
      return classifyImageBytes(bytes);
    } catch (e) {
      if (kDebugMode) {
        print('TFLiteClassifier: Error reading image: $e');
      }
      return ClassificationResult(
        label: 'General',
        confidence: 0.5,
        allPredictions: {'General': 0.5},
        analysisDetails: 'Error processing image: $e',
      );
    }
  }

  /// Classify waste from image bytes
  static Future<ClassificationResult> classifyImageBytes(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return ClassificationResult(
          label: 'General',
          confidence: 0.5,
          allPredictions: {'General': 0.5},
          analysisDetails: 'Could not decode image',
        );
      }
      
      // Resize for faster processing
      final resized = img.copyResize(image, width: 224, height: 224);
      
      // First check for human/skin content
      final skinAnalysis = _analyzeSkinContent(resized);
      if (skinAnalysis.skinRatio > 0.3) {
        return ClassificationResult(
          label: 'Not Waste',
          confidence: skinAnalysis.skinRatio,
          allPredictions: {
            'Not Waste (Human Detected)': skinAnalysis.skinRatio,
            'General': 1.0 - skinAnalysis.skinRatio,
          },
          analysisDetails: '''
⚠️ Human Detected in Image

Skin content: ${(skinAnalysis.skinRatio * 100).toStringAsFixed(1)}%

This image appears to contain a person rather than waste.
Please take a photo of only the waste item for accurate classification.
''',
          isHumanDetected: true,
        );
      }
      
      // Extract features
      final colorFeatures = _extractColorFeatures(resized);
      final textureScore = _calculateTextureScore(resized);
      final brightness = _calculateBrightness(resized);
      
      // Score each waste type
      final scores = <String, double>{};
      
      for (var entry in _wasteProfiles.entries) {
        final profile = entry.value;
        double score = 0.0;
        
        // Color hue matching (40% weight)
        final hueScore = _calculateHueMatch(colorFeatures.dominantHue, profile.dominantHues);
        score += hueScore * 0.4;
        
        // Saturation matching (20% weight)
        final satScore = _inRangeScore(colorFeatures.avgSaturation, profile.saturationRange);
        score += satScore * 0.2;
        
        // Value/brightness matching (20% weight)
        final valScore = _inRangeScore(brightness, profile.valueRange);
        score += valScore * 0.2;
        
        // Texture matching (20% weight)
        final texScore = 1.0 - (textureScore - profile.textureScore).abs();
        score += texScore * 0.2;
        
        scores[entry.key] = score;
      }
      
      // Penalty if some skin detected (person holding waste)
      if (skinAnalysis.skinRatio > 0.1) {
        // Reduce confidence since image contains human
        scores.updateAll((key, value) => value * (1.0 - skinAnalysis.skinRatio * 0.5));
      }
      
      // Normalize scores
      final totalScore = scores.values.reduce((a, b) => a + b);
      if (totalScore > 0) {
        scores.updateAll((key, value) => value / totalScore);
      }
      
      // Find best match
      var bestLabel = 'General';
      var bestScore = 0.0;
      for (var entry in scores.entries) {
        if (entry.value > bestScore) {
          bestScore = entry.value;
          bestLabel = entry.key;
        }
      }
      
      // Apply minimum confidence threshold
      if (bestScore < 0.25) {
        bestLabel = 'General';
        bestScore = scores['General'] ?? 0.3;
      }
      
      String warningText = '';
      if (skinAnalysis.skinRatio > 0.1) {
        warningText = '\n⚠️ Note: ${(skinAnalysis.skinRatio * 100).toStringAsFixed(0)}% skin detected - results may be less accurate.\n';
      }
      
      final analysisDetails = '''
Color Analysis:
- Dominant Hue: ${colorFeatures.dominantHue.toStringAsFixed(1)}°
- Saturation: ${(colorFeatures.avgSaturation * 100).toStringAsFixed(1)}%
- Brightness: ${(brightness * 100).toStringAsFixed(1)}%
- Texture Score: ${(textureScore * 100).toStringAsFixed(1)}%
$warningText
Classification: $bestLabel (${(bestScore * 100).toStringAsFixed(1)}% confidence)
''';
      
      if (kDebugMode) {
        print('TFLiteClassifier: Classified as $bestLabel with ${(bestScore * 100).toStringAsFixed(1)}% confidence');
      }
      
      return ClassificationResult(
        label: bestLabel,
        confidence: bestScore,
        allPredictions: scores,
        analysisDetails: analysisDetails,
      );
    } catch (e) {
      if (kDebugMode) {
        print('TFLiteClassifier: Classification error: $e');
      }
      return ClassificationResult(
        label: 'General',
        confidence: 0.4,
        allPredictions: {'General': 0.4},
        analysisDetails: 'Classification error: $e',
      );
    }
  }

  /// Extract color features from image
  static ColorFeatures _extractColorFeatures(img.Image image) {
    final hueHistogram = List<int>.filled(360, 0);
    double totalSaturation = 0;
    double totalValue = 0;
    int pixelCount = 0;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        final hsv = _rgbToHsv(r, g, b);
        
        hueHistogram[hsv.h.floor() % 360]++;
        totalSaturation += hsv.s;
        totalValue += hsv.v;
        pixelCount++;
      }
    }
    
    // Find dominant hue
    int dominantHue = 0;
    int maxCount = 0;
    
    // Smooth histogram and find peak
    for (int h = 0; h < 360; h++) {
      int count = 0;
      for (int delta = -10; delta <= 10; delta++) {
        count += hueHistogram[(h + delta + 360) % 360];
      }
      if (count > maxCount) {
        maxCount = count;
        dominantHue = h;
      }
    }
    
    return ColorFeatures(
      dominantHue: dominantHue.toDouble(),
      avgSaturation: pixelCount > 0 ? totalSaturation / pixelCount : 0,
      avgValue: pixelCount > 0 ? totalValue / pixelCount : 0,
    );
  }

  /// Analyze skin content in image
  static SkinAnalysis _analyzeSkinContent(img.Image image) {
    int skinPixels = 0;
    int totalPixels = 0;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        totalPixels++;
        
        // Multiple skin detection methods
        if (_isSkinPixel(r, g, b)) {
          skinPixels++;
        }
      }
    }
    
    return SkinAnalysis(
      skinRatio: totalPixels > 0 ? skinPixels / totalPixels : 0,
      skinPixelCount: skinPixels,
      totalPixels: totalPixels,
    );
  }

  /// Check if a pixel is skin tone
  static bool _isSkinPixel(int r, int g, int b) {
    // RGB-based skin detection
    // Rule: R > 95, G > 40, B > 20, max-min > 15, |R-G| > 15, R > G, R > B
    bool rgbSkin = r > 95 && g > 40 && b > 20 &&
                   (max(max(r, g), b) - min(min(r, g), b)) > 15 &&
                   (r - g).abs() > 15 &&
                   r > g && r > b;
    
    // YCbCr color space check
    double y = 0.299 * r + 0.587 * g + 0.114 * b;
    double cb = 128 - 0.168736 * r - 0.331264 * g + 0.5 * b;
    double cr = 128 + 0.5 * r - 0.418688 * g - 0.081312 * b;
    bool ycbcrSkin = cr >= 133 && cr <= 173 && cb >= 77 && cb <= 127;
    
    // HSV-based check
    final hsv = _rgbToHsv(r, g, b);
    bool hsvSkin = (hsv.h >= 0 && hsv.h <= 50) &&
                   (hsv.s >= 0.15 && hsv.s <= 0.75) &&
                   (hsv.v >= 0.2 && hsv.v <= 0.95);
    
    // Return true if at least 2 methods agree
    int votes = (rgbSkin ? 1 : 0) + (ycbcrSkin ? 1 : 0) + (hsvSkin ? 1 : 0);
    return votes >= 2;
  }

  /// Calculate texture score using edge detection
  static double _calculateTextureScore(img.Image image) {
    final grayscale = img.grayscale(image);
    double edgeSum = 0;
    int edgeCount = 0;
    
    // Simple Sobel-like edge detection
    for (int y = 1; y < grayscale.height - 1; y++) {
      for (int x = 1; x < grayscale.width - 1; x++) {
        final center = grayscale.getPixel(x, y).luminance;
        final left = grayscale.getPixel(x - 1, y).luminance;
        final right = grayscale.getPixel(x + 1, y).luminance;
        final top = grayscale.getPixel(x, y - 1).luminance;
        final bottom = grayscale.getPixel(x, y + 1).luminance;
        
        final gx = (right - left).abs();
        final gy = (bottom - top).abs();
        final gradient = sqrt(gx * gx + gy * gy);
        
        edgeSum += gradient;
        edgeCount++;
      }
    }
    
    // Normalize texture score (0-1)
    final avgEdge = edgeCount > 0 ? edgeSum / edgeCount : 0;
    return min(avgEdge / 0.3, 1.0); // Normalize assuming max gradient ~0.3
  }

  /// Calculate average brightness
  static double _calculateBrightness(img.Image image) {
    double totalBrightness = 0;
    int count = 0;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        totalBrightness += pixel.luminance;
        count++;
      }
    }
    
    return count > 0 ? totalBrightness / count : 0.5;
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

  /// Calculate hue matching score
  static double _calculateHueMatch(double imageHue, List<int> profileHues) {
    double bestMatch = 0;
    for (var targetHue in profileHues) {
      final diff = _hueDifference(imageHue, targetHue.toDouble());
      final match = 1.0 - (diff / 180.0); // 180 is max difference
      if (match > bestMatch) {
        bestMatch = match;
      }
    }
    return bestMatch;
  }

  /// Calculate circular hue difference
  static double _hueDifference(double h1, double h2) {
    final diff = (h1 - h2).abs();
    return min(diff, 360 - diff);
  }

  /// Score for value in range
  static double _inRangeScore(double value, (double, double) range) {
    if (value >= range.$1 && value <= range.$2) {
      return 1.0;
    }
    if (value < range.$1) {
      return max(0, 1.0 - (range.$1 - value) * 2);
    }
    return max(0, 1.0 - (value - range.$2) * 2);
  }

  /// Dispose resources
  static void dispose() {
    _isInitialized = false;
    if (kDebugMode) {
      print('TFLiteClassifier: Disposed');
    }
  }
}

/// Waste type profile for classification
class WasteProfile {
  final List<int> dominantHues;
  final (double, double) saturationRange;
  final (double, double) valueRange;
  final double textureScore;
  final List<String> keywords;
  
  WasteProfile({
    required this.dominantHues,
    required this.saturationRange,
    required this.valueRange,
    required this.textureScore,
    required this.keywords,
  });
}

/// Color features extracted from image
class ColorFeatures {
  final double dominantHue;
  final double avgSaturation;
  final double avgValue;
  
  ColorFeatures({
    required this.dominantHue,
    required this.avgSaturation,
    required this.avgValue,
  });
}

/// HSV color representation
class HSV {
  final double h;
  final double s;
  final double v;
  
  HSV(this.h, this.s, this.v);
}

/// Skin analysis result
class SkinAnalysis {
  final double skinRatio;
  final int skinPixelCount;
  final int totalPixels;
  
  SkinAnalysis({
    required this.skinRatio,
    required this.skinPixelCount,
    required this.totalPixels,
  });
}

/// Classification result
class ClassificationResult {
  final String label;
  final double confidence;
  final Map<String, double> allPredictions;
  final String analysisDetails;
  final bool isHumanDetected;
  
  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.allPredictions,
    this.analysisDetails = '',
    this.isHumanDetected = false,
  });
  
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
  
  bool get isHighConfidence => confidence >= 0.7 && !isHumanDetected;
  bool get isMediumConfidence => confidence >= 0.5 && confidence < 0.7 && !isHumanDetected;
  bool get isLowConfidence => confidence < 0.5 || isHumanDetected;
  
  String get confidenceLevel {
    if (isHumanDetected) return 'Not Waste';
    if (isHighConfidence) return 'High';
    if (isMediumConfidence) return 'Medium';
    return 'Low';
  }
}
