import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/presentation/providers/admin_provider.dart';
import 'package:iconsax/iconsax.dart';

class ManageRolesScreen extends ConsumerStatefulWidget {
  const ManageRolesScreen({super.key});
  @override
  ConsumerState<ManageRolesScreen> createState() => _ManageRolesScreenState();
}

class _ManageRolesScreenState extends ConsumerState<ManageRolesScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(assignRoleActionProvider.notifier).execute({
      'email': _emailController.text.trim(),
    });
    if (mounted) {
      final state = ref.read(assignRoleActionProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${state.error.toString()}'),
              backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('¡Rol de Guardia Asignado!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assignRoleActionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Rol de Guardia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
                'Escribe el email del usuario (previamente registrado) que deseas promover a Guardia.'),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: 'Email del Usuario',
                  prefixIcon: Icon(Iconsax.user_edit)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: state.isLoading ? null : _submit,
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Promover a Guardia'),
            ),
          ],
        ),
      ),
    );
  }
}
