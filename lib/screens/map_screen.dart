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
  late GoogleMapController _mapController;
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
      }
    } catch (e) {
      debugPrint('Không thể chuyển đổi địa chỉ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vị trí: ${widget.sinhVien.ten}'),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
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
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: widget.isAdmin,
              onTap: widget.isAdmin
                  ? (pos) {
                      setState(() {
                        _currentPosition = pos;
                      });
                    }
                  : null,
            ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.save),
              label: const Text('Lưu vị trí'),
              onPressed: () {
                Navigator.pop(context, _currentPosition);
              },
            )
          : null,
    );
  }
}
