import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Carbon Footprint Calculator Service
/// Tracks user's waste management and calculates environmental impact
/// 
/// Research Paper Reference:
/// - Algorithm: Waste Weight × CO2 Factor → Cumulative Tracking
/// - Features: CO2 saved, trees equivalent, energy savings
/// - Uses EPA and environmental research data for calculations
class CarbonFootprintService {
  static bool _isInitialized = false;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize the service
  static Future<bool> initialize() async {
    _isInitialized = true;
    return true;
  }

  /// Calculate carbon footprint saved from recycling
  static Future<CarbonFootprintResult> calculateForUser(String userId) async {
    if (!_isInitialized) await initialize();

    try {
      // Get user's completed pickups
      final pickups = await _firestore
          .collection('pickups')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      double totalRecycledKg = 0;
      double totalCO2SavedKg = 0;
      double totalEnergySavedKwh = 0;
      double totalWaterSavedLiters = 0;
      
      Map<String, double> wasteBreakdown = {};

      for (final doc in pickups.docs) {
        final data = doc.data();
        final wasteType = (data['wasteType'] ?? 'mixed').toString().toLowerCase();
        final weightKg = (data['weightKg'] ?? 5.0).toDouble();

        totalRecycledKg += weightKg;
        wasteBreakdown[wasteType] = (wasteBreakdown[wasteType] ?? 0) + weightKg;

        // Calculate CO2 savings based on waste type
        final factors = _co2Factors[wasteType] ?? _co2Factors['mixed']!;
        totalCO2SavedKg += weightKg * factors.co2PerKg;
        totalEnergySavedKwh += weightKg * factors.energyPerKg;
        totalWaterSavedLiters += weightKg * factors.waterPerKg;
      }

      // Calculate equivalents
      final treesEquivalent = totalCO2SavedKg / 21; // 21kg CO2/tree/year
      final carMilesAvoided = totalCO2SavedKg / 0.411; // 0.411 kg CO2/mile
      final lightBulbHours = totalEnergySavedKwh * 83; // 60W bulb = 0.012kWh/hr
      final showersEquivalent = totalWaterSavedLiters / 65; // 65L per shower

      return CarbonFootprintResult(
        totalRecycledKg: totalRecycledKg,
        totalCO2SavedKg: totalCO2SavedKg,
        totalEnergySavedKwh: totalEnergySavedKwh,
        totalWaterSavedLiters: totalWaterSavedLiters,
        treesEquivalent: treesEquivalent,
        carMilesAvoided: carMilesAvoided,
        lightBulbHours: lightBulbHours,
        showersEquivalent: showersEquivalent,
        wasteBreakdown: wasteBreakdown,
        pickupCount: pickups.docs.length,
        ecoScore: _calculateEcoScore(totalCO2SavedKg, pickups.docs.length),
        rank: _getRank(totalCO2SavedKg),
      );
    } catch (e) {
      if (kDebugMode) {
        print('CarbonFootprint Error: $e');
      }
      return CarbonFootprintResult.empty();
    }
  }

  /// Calculate footprint for a single waste item
  static CarbonImpact calculateForWaste(String wasteType, double weightKg) {
    final type = wasteType.toLowerCase();
    final factors = _co2Factors[type] ?? _co2Factors['mixed']!;

    return CarbonImpact(
      wasteType: wasteType,
      weightKg: weightKg,
      co2SavedKg: weightKg * factors.co2PerKg,
      energySavedKwh: weightKg * factors.energyPerKg,
      waterSavedLiters: weightKg * factors.waterPerKg,
      description: factors.description,
    );
  }

  /// Calculate eco score (0-100)
  static int _calculateEcoScore(double co2Saved, int pickups) {
    // Score based on CO2 saved and consistency
    final co2Score = (co2Saved / 100 * 50).clamp(0, 50); // Max 50 from CO2
    final consistencyScore = (pickups * 2.5).clamp(0, 50); // Max 50 from pickups
    return (co2Score + consistencyScore).toInt().clamp(0, 100);
  }

  /// Get user rank based on impact
  static String _getRank(double co2Saved) {
    if (co2Saved >= 500) return '🌳 Eco Champion';
    if (co2Saved >= 200) return '🌱 Green Guardian';
    if (co2Saved >= 100) return '♻️ Recycling Hero';
    if (co2Saved >= 50) return '🌿 Earth Friend';
    if (co2Saved >= 20) return '🍃 Eco Starter';
    return '🌾 Beginner';
  }

  /// CO2 factors for different waste types
  /// Based on EPA and environmental research
  static final Map<String, _CO2Factor> _co2Factors = {
    'plastic': _CO2Factor(
      co2PerKg: 1.5, // kg CO2 saved per kg recycled
      energyPerKg: 5.0, // kWh saved
      waterPerKg: 50, // liters saved
      description: 'Recycling plastic saves oil and reduces ocean pollution',
    ),
    'paper': _CO2Factor(
      co2PerKg: 0.9,
      energyPerKg: 4.0,
      waterPerKg: 30,
      description: 'Recycling paper saves trees and reduces landfill',
    ),
    'cardboard': _CO2Factor(
      co2PerKg: 0.8,
      energyPerKg: 3.5,
      waterPerKg: 25,
      description: 'Cardboard recycling is very efficient',
    ),
    'glass': _CO2Factor(
      co2PerKg: 0.3,
      energyPerKg: 1.5,
      waterPerKg: 10,
      description: 'Glass is 100% recyclable infinitely',
    ),
    'metal': _CO2Factor(
      co2PerKg: 4.0,
      energyPerKg: 15.0,
      waterPerKg: 80,
      description: 'Metal recycling saves massive energy',
    ),
    'aluminum': _CO2Factor(
      co2PerKg: 9.0,
      energyPerKg: 35.0,
      waterPerKg: 100,
      description: 'Aluminum recycling saves 95% of production energy',
    ),
    'organic': _CO2Factor(
      co2PerKg: 0.5,
      energyPerKg: 0.5,
      waterPerKg: 5,
      description: 'Composting reduces methane from landfills',
    ),
    'electronic': _CO2Factor(
      co2PerKg: 15.0,
      energyPerKg: 50.0,
      waterPerKg: 200,
      description: 'E-waste contains valuable and toxic materials',
    ),
    'textile': _CO2Factor(
      co2PerKg: 3.0,
      energyPerKg: 10.0,
      waterPerKg: 100,
      description: 'Textile recycling reduces fashion industry impact',
    ),
    'mixed': _CO2Factor(
      co2PerKg: 1.0,
      energyPerKg: 3.0,
      waterPerKg: 30,
      description: 'Mixed waste recycling still helps the environment',
    ),
  };
}

/// CO2 factor model
class _CO2Factor {
  final double co2PerKg;
  final double energyPerKg;
  final double waterPerKg;
  final String description;

  _CO2Factor({
    required this.co2PerKg,
    required this.energyPerKg,
    required this.waterPerKg,
    required this.description,
  });
}

/// Single waste item carbon impact
class CarbonImpact {
  final String wasteType;
  final double weightKg;
  final double co2SavedKg;
  final double energySavedKwh;
  final double waterSavedLiters;
  final String description;

  CarbonImpact({
    required this.wasteType,
    required this.weightKg,
    required this.co2SavedKg,
    required this.energySavedKwh,
    required this.waterSavedLiters,
    required this.description,
  });

  String get co2Text => '${co2SavedKg.toStringAsFixed(2)} kg CO₂';
  String get energyText => '${energySavedKwh.toStringAsFixed(1)} kWh';
  String get waterText => '${waterSavedLiters.toStringAsFixed(0)} L';
}

/// Full carbon footprint result
class CarbonFootprintResult {
  final double totalRecycledKg;
  final double totalCO2SavedKg;
  final double totalEnergySavedKwh;
  final double totalWaterSavedLiters;
  final double treesEquivalent;
  final double carMilesAvoided;
  final double lightBulbHours;
  final double showersEquivalent;
  final Map<String, double> wasteBreakdown;
  final int pickupCount;
  final int ecoScore;
  final String rank;

  CarbonFootprintResult({
    required this.totalRecycledKg,
    required this.totalCO2SavedKg,
    required this.totalEnergySavedKwh,
    required this.totalWaterSavedLiters,
    required this.treesEquivalent,
    required this.carMilesAvoided,
    required this.lightBulbHours,
    required this.showersEquivalent,
    required this.wasteBreakdown,
    required this.pickupCount,
    required this.ecoScore,
    required this.rank,
  });

  factory CarbonFootprintResult.empty() {
    return CarbonFootprintResult(
      totalRecycledKg: 0,
      totalCO2SavedKg: 0,
      totalEnergySavedKwh: 0,
      totalWaterSavedLiters: 0,
      treesEquivalent: 0,
      carMilesAvoided: 0,
      lightBulbHours: 0,
      showersEquivalent: 0,
      wasteBreakdown: {},
      pickupCount: 0,
      ecoScore: 0,
      rank: '🌾 Beginner',
    );
  }

  // Formatted strings for UI
  String get recycledText => '${totalRecycledKg.toStringAsFixed(1)} kg';
  String get co2Text => '${totalCO2SavedKg.toStringAsFixed(1)} kg';
  String get energyText => '${totalEnergySavedKwh.toStringAsFixed(1)} kWh';
  String get waterText => '${totalWaterSavedLiters.toStringAsFixed(0)} L';
  String get treesText => '${treesEquivalent.toStringAsFixed(1)} trees';
  String get carText => '${carMilesAvoided.toStringAsFixed(0)} miles';
  String get bulbText => '${lightBulbHours.toStringAsFixed(0)} hours';
  String get showerText => '${showersEquivalent.toStringAsFixed(0)} showers';
}
