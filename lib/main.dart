import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nota: Para rodar localmente, o Firebase precisa estar configurado
  // No MVP, se não houver firebase_options.dart, o app pode falhar no init
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase não inicializado - certifique-se de seguir o guia de setup: $e");
  }
  
  runApp(const RaustApp());
}

class RaustApp extends StatelessWidget {
  const RaustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(create: (_) => FirebaseService()),
      ],
      child: MaterialApp(
        title: 'RAUST',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: const MapScreen(),
      ),
    );
  }
}
