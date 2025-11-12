import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/role_service.dart';
import '../widgets/custom_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> _roles = [];
  String? _selectedRole;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await RoleService().getAllRoles();
      setState(() {
        _roles = roles.map((r) => r.name).toList();
        _selectedRole = _roles.isNotEmpty ? _roles.first : null;
      });
    } catch (e) {
      setState(() => _error = 'Error al cargar roles');
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService().signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole != null ? [_selectedRole!] : [],
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              CustomInput(
                controller: _emailController,
                label: 'Email',
                validator: (v) =>
                v!.isEmpty ? 'Ingresa tu email' : null,
              ),
              CustomInput(
                controller: _passwordController,
                label: 'Contraseña',
                obscure: true,
                validator: (v) =>
                v!.isEmpty ? 'Ingresa tu contraseña' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedRole = value),
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
