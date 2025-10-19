import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/widgets/custom_button.dart';

import '../../services/setting_service.dart';

class SetLocationPage extends StatefulWidget {
  const SetLocationPage({super.key});

  @override
  State<SetLocationPage> createState() => _SetLocationPageState();
}

class _SetLocationPageState extends State<SetLocationPage> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
  }

  Future<void> _checkPermissionAndGetLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar('Please enable location services');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar(
            'Location permission permanently denied. Please enable in settings.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          selectedLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error getting location: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  Future<void> _setLocation(double latitude, double longitude) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    final service = SettingService();
    final result =
        await service.setLocation(latitude: latitude, longitude: longitude);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (result['success']) {
      Fluttertoast.showToast(
          msg: result['message'] ?? 'Lokasi berhasil diatur');
      Navigator.pushReplacementNamed(context, '/settings');
    } else {
      Fluttertoast.showToast(msg: result['message'] ?? 'Gagal mengatur lokasi');
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;

    return Scaffold(
      body: Stack(
        children: [
          selectedLocation == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryDark,
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation!,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  onTap: (LatLng position) {
                    setState(() {
                      selectedLocation = position;
                    });
                  },
                  markers: {
                    if (selectedLocation != null)
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: selectedLocation!,
                        draggable: true,
                        onDragEnd: (newPosition) {
                          setState(() {
                            selectedLocation = newPosition;
                          });
                        },
                      ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                  compassEnabled: true,
                ),
          Container(
            height: screenHeight * 0.15,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2],
              ),
            ),
          ),
          Positioned(
            top: padding.top + screenHeight * 0.02,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryDark,
                      size: screenWidth * 0.055,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Atur Lokasi Prakerin',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: padding.bottom + screenHeight * 0.04,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Column(
              children: [
                if (selectedLocation != null)
                  Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.primaryDark,
                          size: screenWidth * 0.06,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Latitude: ',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.038,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  Text(
                                    selectedLocation!.latitude
                                        .toStringAsFixed(6),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.038,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.008),
                              Row(
                                children: [
                                  Text(
                                    'Longitude: ',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.038,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  Text(
                                    selectedLocation!.longitude
                                        .toStringAsFixed(6),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.038,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.primaryDark,
                        )
                      : CustomButton(
                          text: 'Simpan Lokasi',
                          backgroundColor: AppColors.primaryDark,
                          color: AppColors.white,
                          onPressed: () async {
                            await _setLocation(selectedLocation!.latitude,
                                selectedLocation!.longitude);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
