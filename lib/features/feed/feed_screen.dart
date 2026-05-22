import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../models/report.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Report> _reports = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _createNewReport() async {
    // Pega localização
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Escolher tipo de alerta
    ReportType? type = await showDialog<ReportType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tipo de Alerta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReportType.values.map((t) {
            return ListTile(
              title: Text(t.typeLabel),
              onTap: () => Navigator.pop(context, t),
            );
          }).toList(),
        ),
      ),
    );

    if (type == null) return;

    // Pegar foto (opcional)
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    // Abrir formulário simples
    String? title = await _showTextDialog("Título do Alerta");
    String? description = await _showTextDialog("Descreva o que está acontecendo");

    if (title == null || description == null) return;

    final newReport = Report(
      userId: "usuario_atual", // depois vamos pegar do login
      title: title,
      description: description,
      type: type,
      latitude: position.latitude,
      longitude: position.longitude,
      imagePath: image?.path,
    );

    setState(() {
      _reports.insert(0, newReport); // mais novo no topo
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Alerta publicado!")),
    );
  }

  Future<String?> _showTextDialog(String title) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: title.contains("Descreva") ? 4 : 1,
          decoration: const InputDecoration(hintText: "Digite aqui..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Raust - Alertas"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewReport,
        icon: const Icon(Icons.add_alert),
        label: const Text("Novo Alerta"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _reports.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Nenhum alerta ainda\nSeja o primeiro a reportar!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Text(report.typeLabel, style: const TextStyle(fontSize: 24)),
                        title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(report.timestamp.toString().substring(0, 16)),
                      ),
                      if (report.imagePath != null)
                        Image.file(File(report.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(report.description),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.thumb_up),
                            label: Text("${report.likes}"),
                            onPressed: () {},
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.share),
                            label: const Text("Compartilhar"),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
