import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/presentation/providers/admin_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class CreateExpenseScreen extends ConsumerStatefulWidget {
  const CreateExpenseScreen({super.key});
  @override
  ConsumerState<CreateExpenseScreen> createState() =>
      _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends ConsumerState<CreateExpenseScreen> {
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _dueDate = DateTime.now();

  @override
  void dispose() {
    _emailController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(expenseActionProvider.notifier).execute({
      'email': _emailController.text.trim(),
      'title': _titleController.text.trim(),
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'date': _dueDate,
    });
    if (mounted && !ref.read(expenseActionProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('¡Expensa Cargada!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseActionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cargar Expensa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email del Residente',
                    prefixIcon: Icon(Iconsax.user))),
            const SizedBox(height: 16),
            TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Título (ej. Expensa Diciembre)',
                    prefixIcon: Icon(Iconsax.text))),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                  labelText: 'Monto (ej. 350.50)',
                  prefixIcon: Icon(Iconsax.money)),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
            ),
            const SizedBox(height: 20),
            Text(
                'Fecha de Vencimiento: ${DateFormat('dd/MM/yyyy').format(_dueDate)}'),
            ElevatedButton(
              child: const Text('Seleccionar Fecha'),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            if (state.hasError)
              Text("Error: ${state.error.toString()}",
                  style: TextStyle(color: Colors.red)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: state.isLoading ? null : _submit,
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Cargar Expensa'),
            ),
          ],
        ),
      ),
    );
  }
}
