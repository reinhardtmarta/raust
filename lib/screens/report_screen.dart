import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();
  ReportType _selectedType = ReportType.traffic;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_descController.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final firebase = Provider.of<FirebaseService>(context, listen: false);
      final loc = await LocationService().getCurrentLocation();
      final userId = await firebase.getDeviceId();

      final report = Report(
        id: '',
        userId: userId,
        description: _descController.text,
        tags: _tagsController.text.split('-').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        latitude: loc.latitude,
        longitude: loc.longitude,
        timestamp: DateTime.now(),
        type: _selectedType,
      );

      await firebase.addReport(report);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Report")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<ReportType>(
                value: _selectedType,
                items: ReportType.values.map((t) => DropdownMenuItem(
                  value: t, child: Text(t.toString().split('.').last.toUpperCase())
                )).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
                decoration: const InputDecoration(labelText: "Tipo de Alerta"),
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Descrição curta"),
                maxLength: 100,
              ),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: "Tags (separadas por hífen)",
                  hintText: "agua-subindo-charqueadas",
                ),
              ),
              const SizedBox(height: 30),
              _isSubmitting 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("ENVIAR REPORT ANÔNIMO"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
