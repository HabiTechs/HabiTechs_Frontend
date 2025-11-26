import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/presentation/screens/home/inicio_screen.dart';

// El administrador ve EXACTAMENTE lo mismo que el residente
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const InicioBody(); // Mismo dashboard que residente
  }
}
