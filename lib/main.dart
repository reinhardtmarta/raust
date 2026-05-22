import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/llama_service.dart';
import 'features/chat/chat_screen.dart';
import 'features/feed/feed_screen.dart';
import 'features/map/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa a IA local
  await LlamaService.initialize();

  runApp(const RaustApp());
}

class RaustApp extends StatelessWidget {
  const RaustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LlamaService>(create: (_) => LlamaService()),
      ],
      child: MaterialApp(
        title: 'Raust',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.deepPurple,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapScreen(),      // Aba 1 - Principal para motoristas
    const FeedScreen(),     // Aba 2 - Alertas e reports
    const ChatScreen(),     // Aba 3 - IA Raust
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy),
            label: 'Raust IA',
          ),
        ],
      ),
    );
  }
}
