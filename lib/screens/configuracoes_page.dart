import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});
  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool _notificacoesAtivas = true;

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.eco, size: 28),
              SizedBox(width: 8),
              Text('GreenEye', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              color: Colors.green,
              child: const TabBar(
                tabs: [Tab(text: 'Perfil'), Tab(text: 'Sistema')],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_buildPerfilTab(), _buildSistemaTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfilTab() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'usuario@exemplo.com';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text('Usuário', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair da Conta', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }



  Widget _buildSistemaTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Notificações'),
            subtitle: const Text('Receber alertas sobre suas estufas'),
            value: _notificacoesAtivas,
            onChanged: (value) => setState(() => _notificacoesAtivas = value),
          ),
          const Divider(),
          ListTile(
            title: const Text('Sobre'),
            subtitle: const Text('Versão 1.0.0'),
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'GreenEye',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.eco, size: 50, color: Colors.green),
                children: const [
                  Text('GreenEye é um aplicativo para monitoramento inteligente de estufas.'),
                ],
              );
            },
          ),
        ],
      );
}
