import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../services/firebase_service.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebase = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Feed de Alertas")),
      body: StreamBuilder<List<Report>>(
        stream: firebase.getReports(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final reports = snapshot.data!;
          final criticalAlerts = reports.where((r) => 
            (r.type == ReportType.flood && r.confirmationCount >= 10) ||
            (r.type == ReportType.traffic && r.confirmationCount >= 2)
          ).toList();

          return ListView(
            children: [
              if (criticalAlerts.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("ALERTAS CRÍTICOS", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                ...criticalAlerts.map((r) => _buildAlertTile(r, isCritical: true)),
                const Divider(),
              ],
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("TAGS ATIVAS (Últimas 24h)", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...reports.map((r) => _buildAlertTile(r)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertTile(Report r, {bool isCritical = false}) {
    final timeStr = DateFormat('HH:mm').format(r.timestamp);
    return ListTile(
      leading: Icon(
        isCritical ? Icons.report_problem : Icons.tag,
        color: isCritical ? Colors.red : Colors.blue,
      ),
      title: Text(r.tags.join(' #')),
      subtitle: Text("${r.description} - $timeStr"),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text("${r.confirmationCount}", style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
