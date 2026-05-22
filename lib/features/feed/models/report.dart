import 'package:uuid/uuid.dart';

enum ReportType {
  flood, fire, landslide, accident, power_outage, road_block, other
}

class Report {
  final String id;
  final String userId;
  final String title;
  final String description;
  final ReportType type;
  final double latitude;
  final double longitude;
  final String? imagePath;
  final DateTime timestamp;
  final int likes;
  final bool verified; // Pode ser usado pela IA depois

  Report({
    String? id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.imagePath,
    DateTime? timestamp,
    this.likes = 0,
    this.verified = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  String get typeLabel {
    switch (type) {
      case ReportType.flood: return "🌊 Enchente";
      case ReportType.fire: return "🔥 Incêndio";
      case ReportType.landslide: return "⛰️ Deslizamento";
      case ReportType.accident: return "🚑 Acidente";
      case ReportType.power_outage: return "⚡ Falta de Energia";
      case ReportType.road_block: return "🛑 Bloqueio de Via";
      case ReportType.other: return "📢 Outro";
    }
  }
}
