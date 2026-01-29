import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import 'report_screen.dart';
import 'tags_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(-29.9547, -51.6253); // Charqueadas
  WeatherData? _weather;
  final Set<String> _pendingValidations = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final loc = await LocationService().getCurrentLocation();
    final weather = await WeatherService().fetchWeather(loc.latitude, loc.longitude);
    setState(() {
      _currentCenter = loc;
      _weather = weather;
    });
    _mapController.move(loc, 13);
  }

  // Simulação de lógica de validação (Mock de Cloud Function/Timer Local)
  void _startValidationTimer(Report report) {
    if (_pendingValidations.contains(report.id)) return;
    
    _pendingValidations.add(report.id);
    Timer(const Duration(minutes: 2), () {
      if (mounted) {
        _showValidationDialog(report);
      }
    });
  }

  void _showValidationDialog(Report report) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Validação Comunitária"),
        content: Text("O alerta de '${report.type.name}' em ${report.description} ainda está assim?"),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<FirebaseService>(context, listen: false).validateReport(report.id, false);
              Navigator.pop(context);
            },
            child: const Text("X NÃO", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<FirebaseService>(context, listen: false).validateReport(report.id, true);
              Navigator.pop(context);
            },
            child: const Text("√ SIM"),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(ReportType type) {
    switch (type) {
      case ReportType.traffic: return Icons.traffic;
      case ReportType.flood: return Icons.flood;
      case ReportType.danger: return Icons.warning;
      case ReportType.other: return Icons.info;
    }
  }

  Color _getColorForType(ReportType type) {
    switch (type) {
      case ReportType.traffic: return Colors.orange;
      case ReportType.flood: return Colors.blue;
      case ReportType.danger: return Colors.red;
      case ReportType.other: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebase = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("RAUST - Radar RS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TagsScreen())),
          ),
          if (_weather != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text("${_weather!.temperature.toInt()}°C | ${_weather!.rainProbability.toInt()}% Chuva", 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Report>>(
            stream: firebase.getReports(),
            builder: (context, snapshot) {
              List<Marker> markers = [];
              if (snapshot.hasData) {
                for (var report in snapshot.data!) {
                  // Lógica de threshold para validação mock
                  if (report.type == ReportType.traffic && report.confirmationCount >= 1) {
                     _startValidationTimer(report);
                  } else if (report.type == ReportType.flood && report.confirmationCount >= 5) {
                     _startValidationTimer(report);
                  }

                  markers.add(Marker(
                    point: LatLng(report.latitude, report.longitude),
                    width: 45,
                    height: 45,
                    child: GestureDetector(
                      onTap: () => _showReportDetails(report),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getColorForType(report.type).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForType(report.type),
                          color: _getColorForType(report.type),
                          size: 30,
                        ),
                      ),
                    ),
                  ));
                }
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentCenter,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.raust.app',
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              heroTag: "driving_mode",
              onPressed: () => _toggleDrivingMode(),
              backgroundColor: Colors.black87,
              child: const Icon(Icons.drive_eta, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              heroTag: "add_report",
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen())),
              label: const Text("REPORTAR"),
              icon: const Icon(Icons.add_location_alt),
              backgroundColor: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleDrivingMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Modo Dirigindo Ativado: Ícones grandes e alertas por voz (TTS Mock)")),
    );
  }

  void _showReportDetails(Report report) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(report.type.name.toUpperCase(), 
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getColorForType(report.type))),
                Text(DateFormat('HH:mm').format(report.timestamp), style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            Text(report.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              children: report.tags.map((t) => Chip(
                label: Text("#$t", style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue.withOpacity(0.1),
              )).toList(),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Provider.of<FirebaseService>(context, listen: false).validateReport(report.id, true),
                  icon: const Icon(Icons.thumb_up),
                  label: Text("Confirma (${report.confirmationCount})"),
                ),
                OutlinedButton.icon(
                  onPressed: () => Provider.of<FirebaseService>(context, listen: false).validateReport(report.id, false),
                  icon: const Icon(Icons.thumb_down),
                  label: Text("Negar (${report.rejectionCount})"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
