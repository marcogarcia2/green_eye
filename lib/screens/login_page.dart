import 'package:flutter/material.dart';
import '../main.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;

  Future<void> _login(BuildContext context) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer login: $e'), duration: const Duration(seconds: 3)),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color.fromARGB(255, 38, 100, 40)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.eco, size: 80, color: Colors.green),
                  ),
                  const SizedBox(height: 40),
                  const Text('GreenEye', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  const Text('Monitoramento Inteligente de Estufas', style: TextStyle(fontSize: 16, color: Colors.white, letterSpacing: 0.5)),
                  const SizedBox(height: 60),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    elevation: 4,
                    child: InkWell(
                      onTap: _loading ? null : () => _login(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: _loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.login, color: Colors.green, size: 24),
                                  const SizedBox(width: 12),
                                  const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
