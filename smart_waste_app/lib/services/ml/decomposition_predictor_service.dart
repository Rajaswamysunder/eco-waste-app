import 'dart:math';

/// Waste Decomposition Timeline Predictor
/// AI-powered service that predicts decomposition time and environmental impact
/// 
/// Research Paper Reference:
/// - Algorithm: Waste Type Classification → Database Lookup → Impact Calculation
/// - Features: Decomposition time, CO2 equivalent, recyclability, eco-tips
/// - Uses established environmental science data for predictions
class DecompositionPredictorService {
  static bool _isInitialized = false;

  /// Initialize the service
  static Future<bool> initialize() async {
    _isInitialized = true;
    return true;
  }

  /// Predict decomposition based on waste type
  static Future<DecompositionResult> predict(String wasteType) async {
    if (!_isInitialized) await initialize();

    final normalizedType = wasteType.toLowerCase().trim();
    
    // Find matching waste data
    final data = _findWasteData(normalizedType);
    
    return DecompositionResult(
      wasteType: wasteType,
      decompositionTime: data.decompositionTime,
      decompositionUnit: data.unit,
      displayTime: data.displayTime,
      environmentalImpact: data.impact,
      isRecyclable: data.recyclable,
      isBiodegradable: data.biodegradable,
      isHazardous: data.hazardous,
      co2Equivalent: data.co2Kg,
      ecoTips: data.tips,
      alternatives: data.alternatives,
      disposalMethod: data.disposalMethod,
      category: data.category,
    );
  }

  /// Find waste data from database
  static _WasteData _findWasteData(String type) {
    // Check exact matches first
    for (final entry in _wasteDatabase.entries) {
      if (type.contains(entry.key) || entry.key.contains(type)) {
        return entry.value;
      }
    }
    
    // Check category matches
    for (final entry in _categoryDefaults.entries) {
      for (final keyword in entry.value.keywords) {
        if (type.contains(keyword)) {
          return entry.value;
        }
      }
    }
    
    // Default unknown
    return _WasteData(
      decompositionTime: 0,
      unit: 'Unknown',
      displayTime: 'Unknown',
      impact: EnvironmentalImpact.unknown,
      recyclable: false,
      biodegradable: false,
      hazardous: false,
      co2Kg: 0,
      tips: ['Please consult local waste management guidelines'],
      alternatives: [],
      disposalMethod: 'Check local guidelines',
      category: WasteCategory.unknown,
      keywords: [],
    );
  }

  /// Comprehensive waste decomposition database
  /// Based on environmental science research data
  static final Map<String, _WasteData> _wasteDatabase = {
    // Plastics
    'plastic bottle': _WasteData(
      decompositionTime: 450,
      unit: 'years',
      displayTime: '450 years',
      impact: EnvironmentalImpact.veryHigh,
      recyclable: true,
      biodegradable: false,
      hazardous: false,
      co2Kg: 0.08,
      tips: [
        '♻️ Recycle! Plastic bottles can become fabric, furniture, or new bottles',
        '💧 Rinse before recycling',
        '🚫 Remove cap and label if possible',
        '🌍 One recycled bottle saves enough energy to power a light bulb for 6 hours'
      ],
      alternatives: ['Reusable water bottle', 'Glass bottle', 'Aluminum can'],
      disposalMethod: 'Recycle in plastic bin (usually blue)',
      category: WasteCategory.plastic,
      keywords: ['bottle', 'pet', 'water bottle'],
    ),
    
    'plastic bag': _WasteData(
      decompositionTime: 500,
      unit: 'years',
      displayTime: '500+ years',
      impact: EnvironmentalImpact.veryHigh,
      recyclable: true,
      biodegradable: false,
      hazardous: false,
      co2Kg: 0.03,
      tips: [
        '🛍️ Use reusable shopping bags instead',
        '♻️ Return to grocery stores for recycling',
        '⚠️ Do NOT put in curbside recycling - clogs machines',
        '🌊 Plastic bags are major ocean pollutants'
      ],
      alternatives: ['Cloth bags', 'Paper bags', 'Reusable produce bags'],
      disposalMethod: 'Return to store recycling bin',
      category: WasteCategory.plastic,
      keywords: ['bag', 'poly', 'shopping bag'],
    ),
    
    'styrofoam': _WasteData(
      decompositionTime: 500,
      unit: 'years',
      displayTime: '500+ years (never fully)',
      impact: EnvironmentalImpact.extreme,
      recyclable: false,
      biodegradable: false,
      hazardous: true,
      co2Kg: 0.2,
      tips: [
        '🚫 Avoid styrofoam - it NEVER truly decomposes',
        '💔 Breaks into microplastics that harm wildlife',
        '🍽️ Use paper or compostable containers instead',
        '📦 Check for drop-off recycling locations'
      ],
      alternatives: ['Paper containers', 'Compostable packaging', 'Bamboo containers'],
      disposalMethod: 'Landfill (check for special recycling)',
      category: WasteCategory.plastic,
      keywords: ['foam', 'polystyrene', 'eps'],
    ),
    
    // Paper Products
    'paper': _WasteData(
      decompositionTime: 6,
      unit: 'weeks',
      displayTime: '2-6 weeks',
      impact: EnvironmentalImpact.low,
      recyclable: true,
      biodegradable: true,
      hazardous: false,
      co2Kg: 0.01,
      tips: [
        '♻️ Paper is easily recyclable!',
        '📄 Keep dry and clean for recycling',
        '🌳 Recycling 1 ton of paper saves 17 trees',
        '🌿 Can also be composted'
      ],
      alternatives: ['Digital documents', 'Recycled paper'],
      disposalMethod: 'Recycle or compost',
      category: WasteCategory.paper,
      keywords: ['paper', 'newspaper', 'magazine', 'document'],
    ),
    
    'cardboard': _WasteData(
      decompositionTime: 2,
      unit: 'months',
      displayTime: '2-3 months',
      impact: EnvironmentalImpact.low,
      recyclable: true,
      biodegradable: true,
      hazardous: false,
      co2Kg: 0.02,
      tips: [
        '📦 Flatten boxes to save space',
        '♻️ Remove tape and staples before recycling',
        '🌧️ Keep dry - wet cardboard can\'t be recycled',
        '🪴 Great for composting and mulching'
      ],
      alternatives: ['Reusable containers'],
      disposalMethod: 'Recycle or compost',
      category: WasteCategory.paper,
      keywords: ['cardboard', 'box', 'carton'],
    ),
    
    // Organic Waste
    'food waste': _WasteData(
      decompositionTime: 2,
      unit: 'weeks',
      displayTime: '1-4 weeks',
      impact: EnvironmentalImpact.medium,
      recyclable: false,
      biodegradable: true,
      hazardous: false,
      co2Kg: 0.05,
      tips: [
        '🌱 Compost food scraps for garden fertilizer',
        '♻️ Many cities offer food waste collection',
        '🍎 Reduces methane emissions from landfills',
        '💡 Plan meals to reduce food waste'
      ],
      alternatives: ['Composting', 'Food donation'],
      disposalMethod: 'Compost bin or organic waste collection',
      category: WasteCategory.organic,
      keywords: ['food', 'fruit', 'vegetable', 'leftover', 'organic'],
    ),
    
    'banana peel': _WasteData(
      decompositionTime: 2,
      unit: 'weeks',
      displayTime: '2-5 weeks',
      impact: EnvironmentalImpact.veryLow,
      recyclable: false,
      biodegradable: true,
      hazardous: false,
      co2Kg: 0.001,
      tips: [
        '🌿 Perfect for composting',
        '🪴 Great for garden soil',
        '🍌 High in potassium - good for plants',
        '💚 One of the most eco-friendly wastes'
      ],
      alternatives: [],
      disposalMethod: 'Compost',
      category: WasteCategory.organic,
      keywords: ['banana', 'peel', 'fruit peel'],
    ),
    
    // Glass
    'glass bottle': _WasteData(
      decompositionTime: 1000000,
      unit: 'years',
      displayTime: '1 million years',
      impact: EnvironmentalImpact.medium,
      recyclable: true,
      biodegradable: false,
      hazardous: false,
      co2Kg: 0.05,
      tips: [
        '♻️ Glass is 100% recyclable infinitely!',
        '🔄 Recycled glass uses 30% less energy',
        '🧹 Rinse before recycling',
        '💚 Much better than plastic for environment'
      ],
      alternatives: ['Reusable glass containers'],
      disposalMethod: 'Recycle in glass bin',
      category: WasteCategory.glass,
      keywords: ['glass', 'jar', 'bottle'],
    ),
    
    // Metal
    'aluminum can': _WasteData(
      decompositionTime: 200,
      unit: 'years',
      displayTime: '200-500 years',
      impact: EnvironmentalImpact.medium,
      recyclable: true,
      biodegradable: false,
      hazardous: false,
      co2Kg: 0.15,
      tips: [
        '♻️ Aluminum is infinitely recyclable!',
        '⚡ Recycling saves 95% of energy vs new aluminum',
        '🥫 Crushed cans save space',
        '💰 Some places pay for aluminum cans'
      ],
      alternatives: ['Reusable bottles'],
      disposalMethod: 'Recycle in metal bin',
      category: WasteCategory.metal,
      keywords: ['aluminum', 'can', 'soda can', 'beer can'],
    ),
    
    // E-Waste
    'battery': _WasteData(
      decompositionTime: 100,
      unit: 'years',
      displayTime: '100+ years',
      impact: EnvironmentalImpact.extreme,
      recyclable: true,
      biodegradable: false,
      hazardous: true,
      co2Kg: 0.5,
      tips: [
        '⚠️ NEVER throw in regular trash!',
        '☠️ Contains toxic heavy metals',
        '🔋 Take to designated e-waste collection',
        '♻️ Many stores accept old batteries'
      ],
      alternatives: ['Rechargeable batteries', 'Solar-powered devices'],
      disposalMethod: 'E-waste collection or battery recycling',
      category: WasteCategory.electronic,
      keywords: ['battery', 'cell', 'lithium'],
    ),
    
    'phone': _WasteData(
      decompositionTime: 1000,
      unit: 'years',
      displayTime: '1000+ years',
      impact: EnvironmentalImpact.extreme,
      recyclable: true,
      biodegradable: false,
      hazardous: true,
      co2Kg: 70,
      tips: [
        '📱 Donate working phones to charity',
        '♻️ Return to manufacturer for recycling',
        '⚠️ Contains toxic materials',
        '💰 Some stores offer trade-in value'
      ],
      alternatives: ['Refurbished phones', 'Longer phone usage'],
      disposalMethod: 'E-waste collection or manufacturer take-back',
      category: WasteCategory.electronic,
      keywords: ['phone', 'mobile', 'smartphone', 'electronic'],
    ),
    
    // Textiles
    'clothing': _WasteData(
      decompositionTime: 40,
      unit: 'years',
      displayTime: '1-200 years (varies)',
      impact: EnvironmentalImpact.high,
      recyclable: true,
      biodegradable: false,
      hazardous: false,
      co2Kg: 10,
      tips: [
        '👕 Donate wearable clothes',
        '♻️ Textile recycling bins available',
        '🧵 Repair instead of replacing',
        '🛒 Buy second-hand or sustainable fashion'
      ],
      alternatives: ['Second-hand clothing', 'Sustainable brands'],
      disposalMethod: 'Donation bin or textile recycling',
      category: WasteCategory.textile,
      keywords: ['clothes', 'shirt', 'pants', 'fabric', 'textile'],
    ),
    
    // Medical
    'diaper': _WasteData(
      decompositionTime: 500,
      unit: 'years',
      displayTime: '500+ years',
      impact: EnvironmentalImpact.veryHigh,
      recyclable: false,
      biodegradable: false,
      hazardous: true,
      co2Kg: 0.4,
      tips: [
        '🚼 Consider cloth diapers',
        '🌿 Look for biodegradable brands',
        '♻️ Some areas have diaper recycling',
        '⚠️ Dispose in general waste properly'
      ],
      alternatives: ['Cloth diapers', 'Biodegradable diapers'],
      disposalMethod: 'Landfill waste',
      category: WasteCategory.medical,
      keywords: ['diaper', 'nappy', 'sanitary'],
    ),
  };

  /// Category defaults for unmatched items
  static final Map<String, _WasteData> _categoryDefaults = {
    'plastic': _WasteData(
      decompositionTime: 400,
      unit: 'years',
      displayTime: '400+ years',
      impact: EnvironmentalImpact.high,
      recyclable: true,
      biodegradable: false,
      hazardous: false,
      co2Kg: 0.1,
      tips: ['Check recycling code', 'Reduce plastic usage'],
      alternatives: ['Reusable alternatives'],
      disposalMethod: 'Check recycling guidelines',
      category: WasteCategory.plastic,
      keywords: ['plastic', 'poly', 'pvc', 'hdpe', 'ldpe'],
    ),
    'metal': _WasteData(
      decompositionTime: 200,
      unit: 'years',
      displayTime: '50-500 years',
      impact: EnvironmentalImpact.medium,
      recyclable: true,
      biodegradable: false,
      hazardous: false,
      co2Kg: 0.2,
      tips: ['Most metals are recyclable'],
      alternatives: [],
      disposalMethod: 'Metal recycling',
      category: WasteCategory.metal,
      keywords: ['metal', 'steel', 'iron', 'tin'],
    ),
    'organic': _WasteData(
      decompositionTime: 4,
      unit: 'weeks',
      displayTime: '1-4 weeks',
      impact: EnvironmentalImpact.low,
      recyclable: false,
      biodegradable: true,
      hazardous: false,
      co2Kg: 0.02,
      tips: ['Compost organic waste'],
      alternatives: [],
      disposalMethod: 'Compost or organic waste',
      category: WasteCategory.organic,
      keywords: ['organic', 'food', 'plant', 'leaf', 'wood'],
    ),
  };
}

/// Internal waste data model
class _WasteData {
  final int decompositionTime;
  final String unit;
  final String displayTime;
  final EnvironmentalImpact impact;
  final bool recyclable;
  final bool biodegradable;
  final bool hazardous;
  final double co2Kg;
  final List<String> tips;
  final List<String> alternatives;
  final String disposalMethod;
  final WasteCategory category;
  final List<String> keywords;

  _WasteData({
    required this.decompositionTime,
    required this.unit,
    required this.displayTime,
    required this.impact,
    required this.recyclable,
    required this.biodegradable,
    required this.hazardous,
    required this.co2Kg,
    required this.tips,
    required this.alternatives,
    required this.disposalMethod,
    required this.category,
    required this.keywords,
  });
}

/// Environmental impact levels
enum EnvironmentalImpact {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
  extreme,
  unknown,
}

/// Waste categories
enum WasteCategory {
  plastic,
  paper,
  glass,
  metal,
  organic,
  electronic,
  textile,
  medical,
  hazardous,
  unknown,
}

/// Decomposition prediction result
class DecompositionResult {
  final String wasteType;
  final int decompositionTime;
  final String decompositionUnit;
  final String displayTime;
  final EnvironmentalImpact environmentalImpact;
  final bool isRecyclable;
  final bool isBiodegradable;
  final bool isHazardous;
  final double co2Equivalent;
  final List<String> ecoTips;
  final List<String> alternatives;
  final String disposalMethod;
  final WasteCategory category;

  DecompositionResult({
    required this.wasteType,
    required this.decompositionTime,
    required this.decompositionUnit,
    required this.displayTime,
    required this.environmentalImpact,
    required this.isRecyclable,
    required this.isBiodegradable,
    required this.isHazardous,
    required this.co2Equivalent,
    required this.ecoTips,
    required this.alternatives,
    required this.disposalMethod,
    required this.category,
  });

  /// Get impact color
  String get impactEmoji {
    switch (environmentalImpact) {
      case EnvironmentalImpact.veryLow:
        return '🟢';
      case EnvironmentalImpact.low:
        return '🟢';
      case EnvironmentalImpact.medium:
        return '🟡';
      case EnvironmentalImpact.high:
        return '🟠';
      case EnvironmentalImpact.veryHigh:
        return '🔴';
      case EnvironmentalImpact.extreme:
        return '⛔';
      case EnvironmentalImpact.unknown:
        return '⚪';
    }
  }

  /// Get impact text
  String get impactText {
    switch (environmentalImpact) {
      case EnvironmentalImpact.veryLow:
        return 'Very Low Impact';
      case EnvironmentalImpact.low:
        return 'Low Impact';
      case EnvironmentalImpact.medium:
        return 'Medium Impact';
      case EnvironmentalImpact.high:
        return 'High Impact';
      case EnvironmentalImpact.veryHigh:
        return 'Very High Impact';
      case EnvironmentalImpact.extreme:
        return 'Extreme Impact';
      case EnvironmentalImpact.unknown:
        return 'Unknown Impact';
    }
  }

  /// Get category emoji
  String get categoryEmoji {
    switch (category) {
      case WasteCategory.plastic:
        return '🥤';
      case WasteCategory.paper:
        return '📄';
      case WasteCategory.glass:
        return '🍾';
      case WasteCategory.metal:
        return '🥫';
      case WasteCategory.organic:
        return '🍎';
      case WasteCategory.electronic:
        return '📱';
      case WasteCategory.textile:
        return '👕';
      case WasteCategory.medical:
        return '💊';
      case WasteCategory.hazardous:
        return '☣️';
      case WasteCategory.unknown:
        return '❓';
    }
  }

  /// Generate human lifetime comparison
  String get lifetimeComparison {
    const avgLifespan = 80; // years
    
    if (decompositionUnit == 'years') {
      final lifetimes = decompositionTime / avgLifespan;
      if (lifetimes >= 1) {
        return '${lifetimes.toStringAsFixed(1)} human lifetimes';
      } else {
        return '${(lifetimes * avgLifespan).toStringAsFixed(0)} years';
      }
    } else if (decompositionUnit == 'months') {
      return '$decompositionTime months';
    } else if (decompositionUnit == 'weeks') {
      return '$decompositionTime weeks';
    }
    return displayTime;
  }

  /// Generate tree equivalent for CO2
  String get treeEquivalent {
    // One tree absorbs ~21 kg CO2 per year
    if (co2Equivalent >= 21) {
      final trees = co2Equivalent / 21;
      return '${trees.toStringAsFixed(1)} trees needed to offset';
    } else {
      return '${(co2Equivalent * 1000).toStringAsFixed(0)}g CO2';
    }
  }
}
