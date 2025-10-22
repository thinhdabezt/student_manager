import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/sinhvien.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  final SinhVien sinhVien;
  final bool isAdmin;

  const MapScreen({super.key, required this.sinhVien, this.isAdmin = false});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    if (widget.sinhVien.latitude != null && widget.sinhVien.longitude != null) {
      _currentPosition =
          LatLng(widget.sinhVien.latitude!, widget.sinhVien.longitude!);
    } else {
      _convertAddressToLatLng();
    }
  }

  Future<void> _convertAddressToLatLng() async {
    try {
      final locations = await locationFromAddress(widget.sinhVien.diaChi);
      if (locations.isNotEmpty) {
        setState(() {
          _currentPosition =
              LatLng(locations.first.latitude, locations.first.longitude);
        });
      } else {
        // No location found, use default location (Vietnam center)
        _useDefaultLocation();
      }
    } catch (e) {
      debugPrint('Không thể chuyển đổi địa chỉ: $e');
      // Use default location on error
      _useDefaultLocation();
      
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Không thể tìm vị trí từ địa chỉ. Hiển thị vị trí mặc định.',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Đóng',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _useDefaultLocation() {
    // Use Vietnam center as default (Hanoi)
    setState(() {
      _currentPosition = const LatLng(21.0285, 105.8542);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = widget.sinhVien.latitude != null && 
                           widget.sinhVien.longitude != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Vị trí: ${widget.sinhVien.ten}'),
        actions: [
          if (!hasCoordinates)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: const Text(
                  'Vị trí ước tính',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
                backgroundColor: Colors.orange[100],
              ),
            ),
        ],
      ),
      body: _currentPosition == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Đang tải vị trí...'),
                  if (!hasCoordinates) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Địa chỉ: ${widget.sinhVien.diaChi}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('student'),
                  position: _currentPosition!,
                  infoWindow:
                      InfoWindow(title: widget.sinhVien.ten, snippet: widget.sinhVien.diaChi),
                )
              },
              myLocationEnabled: widget.isAdmin,
              onTap: widget.isAdmin
                  ? (pos) {
                      setState(() {
                        _currentPosition = pos;
                      });
                    }
                  : null,
            ),
      bottomSheet: widget.isAdmin && !hasCoordinates
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chạm vào bản đồ để đặt vị trí chính xác',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.save),
              label: const Text('Lưu vị trí'),
              onPressed: () async {
                if (_currentPosition == null) return;
                
                // Try to get address from coordinates (reverse geocoding)
                try {
                  final placemarks = await placemarkFromCoordinates(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  );
                  
                  if (placemarks.isNotEmpty) {
                    final place = placemarks.first;
                    // Build address from placemark
                    final addressParts = [
                      if (place.street?.isNotEmpty == true) place.street,
                      if (place.subLocality?.isNotEmpty == true) place.subLocality,
                      if (place.locality?.isNotEmpty == true) place.locality,
                      if (place.administrativeArea?.isNotEmpty == true) place.administrativeArea,
                      if (place.country?.isNotEmpty == true) place.country,
                    ];
                    final address = addressParts.join(', ');
                    
                    // Return both coordinates and address
                    Navigator.pop(context, {
                      'coordinates': _currentPosition,
                      'address': address.isNotEmpty ? address : null,
                    });
                  } else {
                    // No address found, return only coordinates
                    Navigator.pop(context, {
                      'coordinates': _currentPosition,
                      'address': null,
                    });
                  }
                } catch (e) {
                  debugPrint('Reverse geocoding failed: $e');
                  // If reverse geocoding fails, return only coordinates
                  Navigator.pop(context, {
                    'coordinates': _currentPosition,
                    'address': null,
                  });
                }
              },
            )
          : null,
      floatingActionButtonLocation: widget.isAdmin 
          ? FloatingActionButtonLocation.endFloat 
          : null,
    );
  }
}
