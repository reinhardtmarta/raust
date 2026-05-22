import 'package:llamadart/llamadart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LlamaService {
  static LlamaEngine? _engine;
  static ChatSession? _session;
  static bool isInitialized = false;

  static Future<void> initialize() async {
    if (isInitialized) return;

    try {
      _engine = LlamaEngine(LlamaBackend());

      final dir = await getApplicationDocumentsDirectory();
      final modelPath = '${dir.path}/models/phi-3-mini-4k-instruct-q4_k_m.gguf';

      // Cria pasta se não existir
      final modelDir = Directory('${dir.path}/models');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      await _engine!.loadModel(modelPath);

      _session = ChatSession(
        _engine!,
        systemPrompt: """
Você é Raust, uma IA assistente de emergências e desastres.
Seja direta, prática e calma. Priorize informações úteis para salvar vidas.
Responda sempre em português do Brasil.
""",
      );

      isInitialized = true;
      print("✅ Raust IA inicializada com sucesso!");
    } catch (e) {
      print("Erro ao inicializar Llama: $e");
    }
  }

  static Stream<String> sendMessage(String message) async* {
    if (!isInitialized || _session == null) {
      yield "⚠️ IA ainda não foi carregada. Tente novamente em alguns segundos.";
      return;
    }

    try {
      await for (final chunk in _session!.generate(message)) {
        yield chunk.choices.first.delta.content ?? '';
      }
    } catch (e) {
      yield "Erro ao gerar resposta: $e";
    }
  }

  static Future<void> dispose() async {
    await _engine?.dispose();
  }
}
