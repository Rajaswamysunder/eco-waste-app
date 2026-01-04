import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFB9F6CA);
  
  // Accent Colors
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentPurple = Color(0xFF7C4DFF);
  
  // Waste Type Colors
  static const Color organicColor = Color(0xFF4CAF50);
  static const Color recyclableColor = Color(0xFF2196F3);
  static const Color ewasteColor = Color(0xFF9C27B0);
  static const Color hazardousColor = Color(0xFFFF5722);
  static const Color generalColor = Color(0xFF9E9E9E);
  
  // Status Colors
  static const Color pendingColor = Color(0xFFFFA726);
  static const Color confirmedColor = Color(0xFF42A5F5);
  static const Color assignedColor = Color(0xFF42A5F5);
  static const Color inProgressColor = Color(0xFFAB47BC);
  static const Color completedColor = Color(0xFF66BB6A);
  static const Color cancelledColor = Color(0xFFEF5350);

  // Helper methods
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingColor;
      case 'confirmed':
        return confirmedColor;
      case 'assigned':
        return assignedColor;
      case 'in_progress':
        return inProgressColor;
      case 'completed':
        return completedColor;
      case 'cancelled':
        return cancelledColor;
      default:
        return generalColor;
    }
  }

  static Color getWasteTypeColor(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'organic':
        return organicColor;
      case 'recyclable':
        return recyclableColor;
      case 'e-waste':
        return ewasteColor;
      case 'hazardous':
        return hazardousColor;
      default:
        return generalColor;
    }
  }
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF1DE9B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF6D00), Color(0xFFFFAB00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Glass Decoration
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.3)),
  );

  // ============ LIGHT THEME ============
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: accentBlue,
      surface: Colors.white,
      background: const Color(0xFFF5F7FA),
      error: Colors.red[400]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1A1C1E),
      onBackground: const Color(0xFF1A1C1E),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    cardColor: Colors.white,
    dividerColor: Colors.grey[200],
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F7FA),
      foregroundColor: Color(0xFF1A1C1E),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1A1C1E)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1C1E),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryGreen.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: primaryGreen, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red[400]!, width: 1),
      ),
      labelStyle: TextStyle(color: Colors.grey[600]),
      hintStyle: TextStyle(color: Colors.grey[400]),
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xFF2D3436)),
      bodyMedium: TextStyle(color: Color(0xFF636E72)),
    ),
  );

  // ============ DARK THEME ============
  // Following Material Design dark theme guidelines:
  // - Background: Pure black (#000000) 
  // - Cards/Surfaces: Elevated gray (#1E1E1E to #2D2D2D) - MUST be lighter than background
  // - Text: White on dark surfaces
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryGreen,
      secondary: accentBlue,
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      error: Colors.red[400]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212), // Dark background (like Firebase)
    cardColor: const Color(0xFF1E1E1E), // Elevated card color (lighter than background)
    dividerColor: const Color(0xFF3D3D3D),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.white54,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
      labelLarge: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.white),
      labelSmall: TextStyle(color: Colors.white70),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF2D2D2D),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(color: Colors.white),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Colors.white,
      iconColor: Colors.white70,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(primaryGreen),
      trackColor: MaterialStateProperty.all(primaryGreen.withOpacity(0.5)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(primaryGreen),
      checkColor: MaterialStateProperty.all(Colors.white),
    ),
  );

  // Get card color based on theme
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  // Get background color based on theme
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  // Get text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : const Color(0xFF1A1A2E);
  }

  // Get secondary text color based on theme
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white70 
        : Colors.grey[600]!;
  }
}

// Custom Widgets
class GradientButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final IconData? icon;
  final bool isLoading;

  const GradientButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.gradient = AppTheme.primaryGradient,
    this.icon,
    this.isLoading = false,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed != null ? gradient : null,
        color: onPressed == null ? Colors.grey[300] : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : child ?? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = AppTheme.pendingColor;
        icon = Icons.schedule;
        break;
      case 'confirmed':
        color = AppTheme.confirmedColor;
        icon = Icons.check;
        break;
      case 'assigned':
        color = AppTheme.assignedColor;
        icon = Icons.person_add;
        break;
      case 'in_progress':
        color = AppTheme.inProgressColor;
        icon = Icons.local_shipping;
        break;
      case 'completed':
        color = AppTheme.completedColor;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = AppTheme.cancelledColor;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class WasteTypeChip extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback? onTap;

  const WasteTypeChip({
    super.key,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String emoji;
    String label;
    Color color;

    switch (type) {
      case 'organic':
        emoji = '🥬';
        label = 'Organic';
        color = AppTheme.organicColor;
        break;
      case 'recyclable':
        emoji = '♻️';
        label = 'Recyclable';
        color = AppTheme.recyclableColor;
        break;
      case 'hazardous':
        emoji = '☢️';
        label = 'Hazardous';
        color = AppTheme.hazardousColor;
        break;
      default:
        emoji = '🗑️';
        label = 'General';
        color = AppTheme.generalColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final LinearGradient? gradient;

  const AnimatedStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(20),
        border: gradient == null
            ? Border.all(color: color.withOpacity(0.3))
            : null,
        boxShadow: gradient != null
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: gradient != null
                  ? Colors.white.withOpacity(0.2)
                  : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: gradient != null ? Colors.white : color,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: gradient != null ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: gradient != null
                  ? Colors.white.withOpacity(0.9)
                  : color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class PickupCard extends StatelessWidget {
  final String wasteType;
  final String userName;
  final String userPhone;
  final String address;
  final String street;
  final DateTime scheduledDate;
  final String timeSlot;
  final String status;
  final String? collectorName;
  final String? notes;
  final VoidCallback? onTap;
  final Widget? actionButton;

  const PickupCard({
    super.key,
    required this.wasteType,
    required this.userName,
    required this.userPhone,
    required this.address,
    required this.street,
    required this.scheduledDate,
    required this.timeSlot,
    required this.status,
    this.collectorName,
    this.notes,
    this.onTap,
    this.actionButton,
  });

  String get wasteTypeDisplay {
    switch (wasteType) {
      case 'organic':
        return '🥬 Organic Waste';
      case 'recyclable':
        return '♻️ Recyclable';
      case 'hazardous':
        return '☢️ Hazardous';
      default:
        return '🗑️ General Waste';
    }
  }

  Color get wasteColor {
    switch (wasteType) {
      case 'organic':
        return AppTheme.organicColor;
      case 'recyclable':
        return AppTheme.recyclableColor;
      case 'hazardous':
        return AppTheme.hazardousColor;
      default:
        return AppTheme.generalColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Header with waste type
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: wasteColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: wasteColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            wasteType == 'organic'
                                ? '🥬'
                                : wasteType == 'recyclable'
                                    ? '♻️'
                                    : wasteType == 'hazardous'
                                        ? '☢️'
                                        : '🗑️',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wasteTypeDisplay.split(' ').skip(1).join(' '),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: wasteColor,
                              ),
                            ),
                            Text(
                              '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    StatusBadge(status: status),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.person_outline, userName),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.phone_outlined, userPhone),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.location_on_outlined, address),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.map_outlined, 'Street: $street'),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.access_time,
                      timeSlot == 'morning'
                          ? '🌅 Morning (6AM - 10AM)'
                          : timeSlot == 'afternoon'
                              ? '☀️ Afternoon (12PM - 4PM)'
                              : '🌆 Evening (4PM - 8PM)',
                    ),
                    if (collectorName != null) ...[
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        Icons.person_pin_outlined,
                        'Collector: $collectorName',
                      ),
                    ],
                    if (notes != null && notes!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.notes_outlined, notes!),
                    ],
                    if (actionButton != null) ...[
                      const SizedBox(height: 16),
                      actionButton!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
