import 'package:llamadart/llamadart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LlamaService {
  static LlamaEngine? _engine;
  static ChatSession? _session;
  static bool isInitialized = false;

  static Future<void> initialize() async {
    if (isInitialized) return;

    _engine = LlamaEngine(LlamaBackend());

    final dir = await getApplicationDocumentsDirectory();
    final modelPath = '${dir.path}/models/phi-3-mini-4k-instruct-q4_k_m.gguf';

    // Baixar modelo pequeno (recomendado para celular)
    await _downloadModelIfNeeded(modelPath);

    await _engine!.loadModel(modelPath);

    _session = ChatSession(
      _engine!,
      systemPrompt: "Você é Raust, um assistente útil, direto e amigável.",
    );

    isInitialized = true;
  }

  static Future<void> _downloadModelIfNeeded(String path) async {
    final file = File(path);
    if (await file.exists()) return;

    // Aqui você pode adicionar download de um modelo leve
    // Exemplo: Phi-3 mini 4bit (roda bem em celulares medianos)
    print("Modelo não encontrado. Baixe manualmente primeiro.");
  }

  static Stream<String> sendMessage(String message) async* {
    if (_session == null) {
      yield "IA ainda não foi inicializada.";
      return;
    }

    await for (final chunk in _session!.generate(message)) {
      yield chunk.choices.first.delta.content ?? '';
    }
  }

  static Future<void> dispose() async {
    await _engine?.dispose();
  }
}
