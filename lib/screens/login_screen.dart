import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Login failed')),
      );
      return;
    }

    final user = authProvider.currentUser;
    if (user == null) return;

    if (user.role == 'admin') {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return LoadingOverlay(
          isLoading: authProvider.isLoading,
          child: Scaffold(
            appBar: AppBar(title: const Text('Login')),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) => value != null && value.contains('@')
                              ? null
                              : 'Enter valid email',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                          validator: (value) =>
                              value != null && value.length >= 6
                                  ? null
                                  : 'Minimum 6 characters',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            child: const Text('Login'),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.register,
                          ),
                          child: const Text('Create account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
