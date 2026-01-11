import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// AI-powered waste classification using image analysis
/// Uses color analysis, edge detection, and heuristics to classify waste
class WasteClassifierService {
  
  /// Initialize (for compatibility - no actual initialization needed)
  static void initialize() {}
  
  /// Dispose (for compatibility - no resources to dispose)
  static void dispose() {}

  /// Classify waste from image file
  static Future<WasteClassificationResult> classifyFromFile(File imageFile) async {
    try {
      // Check file size before processing to avoid memory issues
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) { // 10MB limit
        return WasteClassificationResult(
          wasteType: 'General',
          confidence: 0.5,
          detectedItems: ['Image too large'],
          suggestions: ['Please take a smaller photo'],
          disposalTips: 'If unsure, place in general waste bin.',
        );
      }

      final bytes = await imageFile.readAsBytes();
      
      // Process in isolate to avoid UI freeze
      final result = await compute(_analyzeImageIsolate, bytes);
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Classification error: $e');
      }
      return WasteClassificationResult(
        wasteType: 'General',
        confidence: 0.5,
        detectedItems: ['Unable to analyze image'],
        suggestions: ['Please try taking another photo with better lighting'],
        disposalTips: 'If unsure, place in general waste bin.',
      );
    }
  }

  /// Run image analysis in isolate for better performance
  static WasteClassificationResult _analyzeImageIsolate(Uint8List bytes) {
    try {
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        return WasteClassificationResult(
          wasteType: 'General',
          confidence: 0.5,
          detectedItems: ['Failed to decode image'],
          suggestions: ['Please try taking another photo'],
          disposalTips: 'If unsure, place in general waste bin.',
        );
      }

      // Resize for faster processing - reduced size for memory efficiency
      final resized = img.copyResize(image, width: 200);
      
      // Analyze image characteristics
      final colorAnalysis = _analyzeColors(resized);
      final textureAnalysis = _analyzeTexture(resized);
      
      // Combine analyses to determine waste type
      return _classifyFromAnalysis(colorAnalysis, textureAnalysis);
    } catch (e) {
      return WasteClassificationResult(
        wasteType: 'General',
        confidence: 0.5,
        detectedItems: ['Analysis error'],
        suggestions: ['Please try again with a different image'],
        disposalTips: 'If unsure, place in general waste bin.',
      );
    }
  }

  /// Analyze dominant colors in the image
  static Map<String, dynamic> _analyzeColors(img.Image image) {
    int totalPixels = 0;
    int greenPixels = 0;
    int brownPixels = 0;
    int bluePixels = 0;
    int metallicPixels = 0;
    int plasticLikePixels = 0;
    int darkPixels = 0;
    int brightPixels = 0;
    int redOrangePixels = 0;
    int whitePixels = 0;
    int clearTransparentLike = 0;
    int skinTonePixels = 0;

    // Analyze all pixels
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        totalPixels++;
        
        // Calculate luminance and saturation
        final luminance = (0.299 * r + 0.587 * g + 0.114 * b);
        final maxC = [r, g, b].reduce((a, b) => a > b ? a : b);
        final minC = [r, g, b].reduce((a, b) => a < b ? a : b);
        final saturation = maxC > 0 ? (maxC - minC) / maxC : 0;
        
        if (luminance < 40) darkPixels++;
        if (luminance > 220) brightPixels++;
        if (luminance > 240 && saturation < 0.1) whitePixels++;
        
        // SKIN TONE DETECTION - Multiple skin tone ranges for different ethnicities
        // This helps detect humans/faces and avoid classifying them as waste
        bool isSkinTone = false;
        
        // Light skin tones
        if (r > 95 && g > 40 && b > 20 &&
            r > g && r > b && 
            (r - g) > 15 && (r - b) > 15 &&
            (maxC - minC) > 15 &&
            luminance > 80 && luminance < 220) {
          isSkinTone = true;
        }
        
        // Medium/tan skin tones
        if (r > 80 && g > 50 && b > 30 &&
            r > g && g > b &&
            (r - b) > 20 && (r - b) < 100 &&
            luminance > 60 && luminance < 180) {
          isSkinTone = true;
        }
        
        // Darker skin tones
        if (r > 45 && g > 30 && b > 15 &&
            r > g && g > b &&
            (r - b) > 10 && (r - b) < 80 &&
            luminance > 30 && luminance < 120 &&
            saturation > 0.1 && saturation < 0.6) {
          isSkinTone = true;
        }
        
        if (isSkinTone) {
          skinTonePixels++;
        }
        
        // Green detection (organic waste indicator - leaves, vegetables)
        if (g > r + 15 && g > b + 15 && g > 70) {
          greenPixels++;
        }
        
        // Brown detection (organic/cardboard indicator) - BUT NOT skin tones
        if (r > 80 && g > 50 && g < r && b < g - 10 && r - b > 30 && !isSkinTone) {
          brownPixels++;
        }
        
        // Blue detection (recyclable plastic bottles, containers)
        if (b > r + 25 && b > g + 15 && b > 100) {
          bluePixels++;
        }
        
        // Metallic/gray detection (e-waste, cans)
        final grayDeviation = ((r - g).abs() + (g - b).abs() + (r - b).abs()) / 3;
        if (grayDeviation < 15 && luminance > 80 && luminance < 200) {
          metallicPixels++;
        }
        
        // Plastic-like detection (bright, uniform colors, high saturation)
        if (saturation > 0.3 && luminance > 100 && luminance < 230) {
          plasticLikePixels++;
        }
        
        // Clear/transparent-like (high brightness, low saturation)
        if (luminance > 180 && saturation < 0.15 && grayDeviation < 20) {
          clearTransparentLike++;
        }
        
        // Red/Orange detection (hazardous, warning colors)
        if (r > g + 40 && r > b + 40 && r > 140) {
          redOrangePixels++;
        }
      }
    }

    return {
      'greenRatio': greenPixels / totalPixels,
      'brownRatio': brownPixels / totalPixels,
      'blueRatio': bluePixels / totalPixels,
      'metallicRatio': metallicPixels / totalPixels,
      'plasticRatio': plasticLikePixels / totalPixels,
      'darkRatio': darkPixels / totalPixels,
      'brightRatio': brightPixels / totalPixels,
      'redOrangeRatio': redOrangePixels / totalPixels,
      'whiteRatio': whitePixels / totalPixels,
      'clearRatio': clearTransparentLike / totalPixels,
      'skinToneRatio': skinTonePixels / totalPixels,
      'totalPixels': totalPixels,
    };
  }

  /// Analyze texture patterns in the image
  static Map<String, dynamic> _analyzeTexture(img.Image image) {
    int edgeCount = 0;
    int smoothAreas = 0;
    int totalChecked = 0;
    double variance = 0;
    
    List<double> luminances = [];

    for (int y = 1; y < image.height - 1; y += 2) {
      for (int x = 1; x < image.width - 1; x += 2) {
        final current = _getLuminance(image.getPixel(x, y));
        final right = _getLuminance(image.getPixel(x + 1, y));
        final below = _getLuminance(image.getPixel(x, y + 1));
        
        luminances.add(current);
        
        final diffX = (current - right).abs();
        final diffY = (current - below).abs();
        
        totalChecked++;
        
        if (diffX > 25 || diffY > 25) {
          edgeCount++;
        } else if (diffX < 8 && diffY < 8) {
          smoothAreas++;
        }
      }
    }
    
    // Calculate variance for texture complexity
    if (luminances.isNotEmpty) {
      final mean = luminances.reduce((a, b) => a + b) / luminances.length;
      variance = luminances.map((l) => (l - mean) * (l - mean)).reduce((a, b) => a + b) / luminances.length;
    }
    
    final total = totalChecked > 0 ? totalChecked : 1;
    return {
      'edgeDensity': edgeCount / total,
      'smoothness': smoothAreas / total,
      'complexity': variance / 10000, // Normalize
    };
  }

  static double _getLuminance(img.Pixel pixel) {
    return 0.299 * pixel.r.toDouble() + 0.587 * pixel.g.toDouble() + 0.114 * pixel.b.toDouble();
  }

  /// Classify based on combined analysis
  static WasteClassificationResult _classifyFromAnalysis(
    Map<String, dynamic> colors,
    Map<String, dynamic> texture,
  ) {
    final greenRatio = colors['greenRatio'] as double;
    final brownRatio = colors['brownRatio'] as double;
    final blueRatio = colors['blueRatio'] as double;
    final metallicRatio = colors['metallicRatio'] as double;
    final plasticRatio = colors['plasticRatio'] as double;
    final darkRatio = colors['darkRatio'] as double;
    final redOrangeRatio = colors['redOrangeRatio'] as double;
    final whiteRatio = colors['whiteRatio'] as double;
    final clearRatio = colors['clearRatio'] as double;
    final skinToneRatio = colors['skinToneRatio'] as double;
    final smoothness = texture['smoothness'] as double;
    final edgeDensity = texture['edgeDensity'] as double;
    final complexity = texture['complexity'] as double;

    // === HUMAN/PERSON DETECTION ===
    // If significant skin tones detected, this is likely a person, not waste
    if (skinToneRatio > 0.15) {
      return WasteClassificationResult(
        wasteType: 'Not Waste',
        confidence: 0.90,
        detectedItems: ['Person/Human detected'],
        suggestions: [
          'This appears to be a person, not waste',
          'Please scan actual waste items',
          'Point camera at plastic, paper, food waste, or electronics',
        ],
        disposalTips: 'Please take a photo of the waste item you want to classify, not people or animals.',
      );
    }

    // Calculate scores for each category
    Map<String, double> scores = {
      'Organic': 0,
      'Recyclable': 0,
      'E-Waste': 0,
      'Hazardous': 0,
      'General': 0.2, // Base score
    };

    List<String> detectedFeatures = [];

    // === ORGANIC DETECTION ===
    // High green = likely organic (plants, vegetables, fruits)
    if (greenRatio > 0.15) {
      scores['Organic'] = scores['Organic']! + 0.5;
      detectedFeatures.add('Green organic material');
    } else if (greenRatio > 0.08) {
      scores['Organic'] = scores['Organic']! + 0.3;
      detectedFeatures.add('Some organic matter');
    }
    
    // Brown with texture = organic waste or cardboard
    if (brownRatio > 0.2 && smoothness < 0.4) {
      scores['Organic'] = scores['Organic']! + 0.4;
      detectedFeatures.add('Brown organic/paper material');
    }

    // === RECYCLABLE DETECTION ===
    // Clear/transparent + smooth = plastic bottle
    if (clearRatio > 0.25 && smoothness > 0.3) {
      scores['Recyclable'] = scores['Recyclable']! + 0.6;
      detectedFeatures.add('Clear plastic container');
    }
    
    // Blue color = common for plastic bottles/containers
    if (blueRatio > 0.1) {
      scores['Recyclable'] = scores['Recyclable']! + 0.4;
      detectedFeatures.add('Blue plastic material');
    }
    
    // High saturation + smooth = colored plastic
    if (plasticRatio > 0.3 && smoothness > 0.35) {
      scores['Recyclable'] = scores['Recyclable']! + 0.45;
      detectedFeatures.add('Colored plastic surface');
    }
    
    // White + smooth = paper/styrofoam
    if (whiteRatio > 0.3 && smoothness > 0.4) {
      scores['Recyclable'] = scores['Recyclable']! + 0.35;
      detectedFeatures.add('White recyclable material');
    }
    
    // Brown + smooth = cardboard
    if (brownRatio > 0.15 && smoothness > 0.35) {
      scores['Recyclable'] = scores['Recyclable']! + 0.4;
      detectedFeatures.add('Cardboard/paper');
    }

    // === E-WASTE DETECTION ===
    // Metallic gray colors
    if (metallicRatio > 0.2) {
      scores['E-Waste'] = scores['E-Waste']! + 0.45;
      detectedFeatures.add('Metallic surface detected');
    }
    
    // Dark + metallic + complex edges = electronics
    if (darkRatio > 0.25 && metallicRatio > 0.1 && edgeDensity > 0.15) {
      scores['E-Waste'] = scores['E-Waste']! + 0.5;
      detectedFeatures.add('Electronic device pattern');
    }
    
    // High edge complexity = circuit boards, electronics
    if (complexity > 0.15 && darkRatio > 0.2) {
      scores['E-Waste'] = scores['E-Waste']! + 0.3;
    }
    
    // Metallic + can-like (rounded edges implied by smoothness zones)
    if (metallicRatio > 0.15 && smoothness > 0.4) {
      // Could be metal can - recyclable
      scores['Recyclable'] = scores['Recyclable']! + 0.3;
      detectedFeatures.add('Metal can');
    }

    // === HAZARDOUS DETECTION ===
    // Warning colors (red/orange)
    if (redOrangeRatio > 0.15) {
      scores['Hazardous'] = scores['Hazardous']! + 0.4;
      detectedFeatures.add('Warning color detected');
    }
    
    // Very dark with some color = possibly chemicals
    if (darkRatio > 0.4 && (redOrangeRatio > 0.05 || blueRatio > 0.05)) {
      scores['Hazardous'] = scores['Hazardous']! + 0.25;
    }

    // Find best category
    String bestCategory = 'General';
    double bestScore = 0;
    
    scores.forEach((category, score) {
      if (score > bestScore) {
        bestScore = score;
        bestCategory = category;
      }
    });

    // Require minimum confidence to classify
    if (bestScore < 0.35) {
      bestCategory = 'General';
    }

    // Calculate display confidence
    double confidence;
    if (bestScore > 0.8) {
      confidence = 0.92;
    } else if (bestScore > 0.6) {
      confidence = 0.85;
    } else if (bestScore > 0.45) {
      confidence = 0.75;
    } else if (bestScore > 0.35) {
      confidence = 0.65;
    } else {
      confidence = 0.55;
    }

    // Ensure we have at least one feature
    if (detectedFeatures.isEmpty) {
      detectedFeatures.add('Mixed materials detected');
    }

    return WasteClassificationResult(
      wasteType: bestCategory,
      confidence: confidence,
      detectedItems: detectedFeatures.take(4).toList(),
      suggestions: _getSuggestions(bestCategory),
      disposalTips: _getDisposalTips(bestCategory),
    );
  }

  static List<String> _getSuggestions(String wasteType) {
    switch (wasteType) {
      case 'Recyclable':
        return [
          'Clean and rinse before recycling',
          'Remove caps and labels if possible',
          'Flatten cardboard boxes to save space',
          'Check local recycling guidelines',
        ];
      case 'Organic':
        return [
          'Can be composted at home',
          'Keep separate from plastic bags',
          'Avoid mixing with non-organic waste',
          'Great for garden composting',
        ];
      case 'E-Waste':
        return [
          'Never throw in regular trash',
          'Remove batteries before disposal',
          'Wipe personal data from devices',
          'Take to certified e-waste center',
        ];
      case 'Hazardous':
        return [
          'Handle with extreme care',
          'Keep in original containers',
          'Never mix different chemicals',
          'Requires special disposal facility',
        ];
      default:
        return [
          'Check if items can be recycled',
          'Reduce waste when possible',
          'Consider reusing before disposing',
        ];
    }
  }

  static String _getDisposalTips(String wasteType) {
    switch (wasteType) {
      case 'Recyclable':
        return 'Place in the blue recycling bin. Ensure items are clean and dry. Remove food residue before recycling.';
      case 'Organic':
        return 'Place in the green organic waste bin or compost at home. Avoid plastic bags.';
      case 'E-Waste':
        return 'Do NOT throw in regular trash. Schedule a special e-waste pickup or take to an authorized collection center.';
      case 'Hazardous':
        return 'Requires special handling. Contact local authorities for safe disposal. Never pour down drains.';
      default:
        return 'Place in the general waste bin. Consider if any parts can be recycled separately.';
    }
  }
}

/// Result of waste classification
class WasteClassificationResult {
  final String wasteType;
  final double confidence;
  final List<String> detectedItems;
  final List<String> suggestions;
  final String disposalTips;

  WasteClassificationResult({
    required this.wasteType,
    required this.confidence,
    required this.detectedItems,
    required this.suggestions,
    required this.disposalTips,
  });

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(0)}%';
  
  bool get isHighConfidence => confidence >= 0.7;
}
