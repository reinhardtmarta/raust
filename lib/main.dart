import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/llama_service.dart';
import 'features/chat/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a IA local (Llama)
  await LlamaService.initialize();

  runApp(const RaustApp());
}

class RaustApp extends StatelessWidget {
  const RaustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Podemos adicionar mais providers depois
        Provider<LlamaService>(create: (_) => LlamaService()),
      ],
      child: MaterialApp(
        title: 'Raust',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.deepPurple,
        ),
        themeMode: ThemeMode.system,
        home: const ChatScreen(),   // Tela principal agora é o chat com IA
      ),
    );
  }
}
