import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/app_theme.dart';

class LocationPickerScreen extends StatefulWidget {
  final String? initialAddress;
  
  const LocationPickerScreen({super.key, this.initialAddress});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  double _latitude = 10.7905; // Default: Trichy
  double _longitude = 78.7047;
  String _selectedAddress = '';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  
  // Predefined locations for quick selection
  final List<Map<String, dynamic>> _popularLocations = [
    {'name': 'Trichy Main', 'lat': 10.7905, 'lng': 78.7047, 'address': 'Tiruchirappalli, Tamil Nadu'},
    {'name': 'Srirangam', 'lat': 10.8627, 'lng': 78.6895, 'address': 'Srirangam, Trichy'},
    {'name': 'Woraiyur', 'lat': 10.8231, 'lng': 78.6827, 'address': 'Woraiyur, Trichy'},
    {'name': 'Thillai Nagar', 'lat': 10.8050, 'lng': 78.6919, 'address': 'Thillai Nagar, Trichy'},
    {'name': 'KK Nagar', 'lat': 10.7844, 'lng': 78.7137, 'address': 'KK Nagar, Trichy'},
    {'name': 'Cantonment', 'lat': 10.8154, 'lng': 78.7048, 'address': 'Cantonment, Trichy'},
    {'name': 'Anna Nagar', 'lat': 10.7761, 'lng': 78.7144, 'address': 'Anna Nagar, Trichy'},
    {'name': 'Thennur', 'lat': 10.7975, 'lng': 78.7017, 'address': 'Thennur, Trichy'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _selectedAddress = widget.initialAddress!;
    }
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          if (_selectedAddress.isEmpty) {
            _selectedAddress = 'Tiruchirappalli, Tamil Nadu';
          }
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoading = false;
        if (_selectedAddress.isEmpty) {
          _selectedAddress = 'Lat: ${_latitude.toStringAsFixed(4)}, Lng: ${_longitude.toStringAsFixed(4)}';
        }
      });
      
      _mapController.move(LatLng(_latitude, _longitude), 16.0);
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (_selectedAddress.isEmpty) {
          _selectedAddress = 'Tiruchirappalli, Tamil Nadu';
        }
      });
    }
  }

  void _selectLocation(Map<String, dynamic> location) {
    setState(() {
      _latitude = location['lat'];
      _longitude = location['lng'];
      _selectedAddress = location['address'];
    });
    _mapController.move(LatLng(_latitude, _longitude), 16.0);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _latitude = point.latitude;
      _longitude = point.longitude;
      _selectedAddress = 'Lat: ${_latitude.toStringAsFixed(4)}, Lng: ${_longitude.toStringAsFixed(4)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text(
          'Select Location',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.my_location, color: Colors.white),
            tooltip: 'Get current location',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Map View
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(_latitude, _longitude),
                        initialZoom: 14.0,
                        onTap: _onMapTap,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.smartwaste.smart_waste_app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(_latitude, _longitude),
                              width: 60,
                              height: 60,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryGreen.withOpacity(0.4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Map Attribution
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '© OpenStreetMap contributors',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    // Tap instruction
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tap on map to select location',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Section
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected Location Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: AppTheme.primaryGreen,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Selected Location',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedAddress.isEmpty ? 'Tap on map...' : _selectedAddress,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildCoordChip('Lat: ${_latitude.toStringAsFixed(4)}'),
                                const SizedBox(width: 8),
                                _buildCoordChip('Lng: ${_longitude.toStringAsFixed(4)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Manual Address Entry
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Or enter address manually...',
                            prefixIcon: const Icon(Icons.edit_location_alt, color: AppTheme.primaryGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            setState(() => _selectedAddress = value);
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Quick Select Locations
                      const Text(
                        'Quick Select',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _popularLocations.map((loc) {
                          final isSelected = _selectedAddress == loc['address'];
                          return GestureDetector(
                            onTap: () => _selectLocation(loc),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryGreen : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: isSelected ? Colors.white : AppTheme.primaryGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    loc['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Confirm Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: GradientButton(
              text: 'Confirm Location',
              icon: Icons.check,
              onPressed: _selectedAddress.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context, {
                        'address': _selectedAddress,
                        'latitude': _latitude,
                        'longitude': _longitude,
                      });
                    },
            ),
          ),
          
          // Loading
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryGreen),
                    SizedBox(height: 16),
                    Text('Getting your location...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoordChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
      ),
    );
  }
}
