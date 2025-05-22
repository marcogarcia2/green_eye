import 'package:flutter/material.dart'; // Importa o pacote principal do Flutter para criar interfaces gráficas.
import 'screens/login_page.dart';       // Importa a tela de login personalizada.
import 'screens/estufas_page.dart';     // Importa a tela das estufas.
import 'screens/configuracoes_page.dart'; // Importa a tela de configurações.

import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa o pacote que permite o uso de variáveis de ambiente (.env).
import 'package:greeneye/firebase_config.dart'; // Classe FirebaseConfig
import 'package:firebase_core/firebase_core.dart'; // Firebase Core, é essencial


void main() async {
  // Garante que o Flutter esteja completamente inicializado antes de executar código assíncrono.
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente definidas no arquivo ".env".
  await dotenv.load(fileName: ".env");

  // Aguarda o Firebase conectar para prosseguir.
  await Firebase.initializeApp(
    options: await FirebaseConfig.currentPlatform,
  );

  // Executa o app.
  runApp(const GreenEyeApp());
}

class GreenEyeApp extends StatelessWidget {
  const GreenEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove a faixa de debug do app.
      title: 'Monitoramento de Estufas', // Título do app (útil para Android).
      theme: ThemeData( // Define o tema visual do aplicativo.
        useMaterial3: true, // Ativa o Material Design 3.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), // Define esquema de cores baseado em verde.
        scaffoldBackgroundColor: Colors.white, // Cor de fundo padrão das telas.

        appBarTheme: const AppBarTheme( // Estilização da AppBar.
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        textTheme: const TextTheme( // Define estilos padrão para textos.
          bodyLarge: TextStyle(color: Color(0xFF424242), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFF424242), fontSize: 14),
          titleLarge: TextStyle(
            color: Color(0xFF424242),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData( // Estilo da barra inferior.
          selectedItemColor: Colors.green,
          unselectedItemColor: Color(0xFF757575),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData( // Estilo do botão flutuante (se usado).
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),

      home: const LoginPage(), // Define a tela inicial como a tela de login.
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Controla qual aba está selecionada.

  // Lista de páginas que serão alternadas na navegação inferior.
  final List<Widget> _pages = [const EstufasPage(), const ConfiguracoesPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Exibe a página atual com base no índice selecionado.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Índice atual da navegação.
        onTap: (index) { // Atualiza o índice quando o usuário toca em um item.
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Estufas'), // Aba 1
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'), // Aba 2
        ],
      ),
    );
  }
}
