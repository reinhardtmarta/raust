import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/llama_service.dart';
import '../feed/models/report.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Exemplo: você pode passar um report aqui para a IA analisar
  Future<void> _sendMessage([Report? reportToAnalyze]) async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty && reportToAnalyze == null) return;

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();

    String prompt = userMessage;

    // Se veio um report para análise
    if (reportToAnalyze != null) {
      prompt = """
Analise este alerta de desastre e dê um feedback útil:

Tipo: ${reportToAnalyze.typeLabel}
Título: ${reportToAnalyze.title}
Descrição: ${reportToAnalyze.description}
Localização: ${reportToAnalyze.latitude}, ${reportToAnalyze.longitude}

Responda de forma clara:
- Gravidade estimada
- Sugestões de segurança
- Se precisa de mais informação
- Como melhorar o alerta
""";
    }

    String response = "";

    await for (final chunk in LlamaService.sendMessage(prompt)) {
      response += chunk;
      setState(() {
        // Atualiza a última mensagem da IA
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.last.text = response;
        } else {
          _messages.add(ChatMessage(text: response, isUser: false));
        }
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Raust IA - Assistente de Emergência"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Olá! Eu sou a Raust.\n\n"
                        "Posso analisar alertas, dar conselhos de segurança "
                        "e ajudar durante emergências.\n\n"
                        "Experimente mandar uma mensagem ou analisar um alerta.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Align(
                        alignment: msg.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? Colors.deepPurple
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: MarkdownBody(
                            data: msg.text,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(color: msg.isUser ? Colors.white : null),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Digite sua mensagem ou peça ajuda...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
