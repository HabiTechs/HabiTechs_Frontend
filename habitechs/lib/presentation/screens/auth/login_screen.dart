import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/presentation/providers/auth_provider.dart';
import 'package:lottie/lottie.dart';

// 1. Usamos ConsumerStatefulWidget para manejar los text controllers
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- El Método de Login (Acto 3) ---
  Future<void> _login() async {
    // 1. Estado: Cargando
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 2. La Llamada (al Cerebro)
    final error = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    // 3. Estados: Éxito o Error
    if (mounted) {
      // Asegurarse que la pantalla sigue "viva"
      setState(() {
        _isLoading = false;
        _errorMessage = error; // Será null si fue exitoso
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- RECURSO GRÁFICO (Como pediste) ---
              SizedBox(
                width: 250,
                height: 250,
                // (Asume que descargaste una anim de "casa" o "login")
                child: Lottie.asset('assets/animations/login_building.json'),
              ),
              const SizedBox(height: 20),

              Text(
                'Bienvenido a HabiTechs',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 30),

              // --- Formulario ---
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  errorText: _errorMessage, // ¡Muestra el error de la API aquí!
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // --- Botón de Login (con estado de carga) ---
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _login,
                      child: const Text('Ingresar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
