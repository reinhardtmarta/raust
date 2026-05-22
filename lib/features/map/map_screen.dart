import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../feed/models/report.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  // Exemplo de reports (depois vamos pegar da lista global)
  final List<Report> _reports = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ative a localização")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );

    _addReportMarkers();
  }

  void _addReportMarkers() {
    _markers.clear();
    
    for (var report in _reports) {
      _markers.add(
        Marker(
          markerId: MarkerId(report.id),
          position: LatLng(report.latitude, report.longitude),
          infoWindow: InfoWindow(
            title: report.title,
            snippet: report.typeLabel,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getColorForType(report.type),
          ),
        ),
      );
    }
    setState(() {});
  }

  double _getColorForType(ReportType type) {
    switch (type) {
      case ReportType.flood: return BitmapDescriptor.hueBlue;
      case ReportType.fire: return BitmapDescriptor.hueRed;
      case ReportType.landslide: return BitmapDescriptor.hueOrange;
      case ReportType.accident: return BitmapDescriptor.hueYellow;
      default: return BitmapDescriptor.hueViolet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Raust Mapa - Alertas ao Vivo"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aqui podemos abrir o Feed ou criar novo alerta
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Abra a aba Feed para criar alertas")),
          );
        },
        child: const Icon(Icons.add_alert),
      ),
    );
  }
}
