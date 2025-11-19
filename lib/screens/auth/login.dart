// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave para identificar e validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar o texto dos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variáveis de estado
  bool _rememberMe = false;

  // Limpa os controladores quando o widget é descartado para evitar vazamento de memória
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Função para lidar com a lógica de login usando BLoC
  void _login() {
    // Primeiro, valida o formulário. Se não for válido, a função para aqui.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dispara o evento de login no AuthBloc
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BoraÊ'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Sucesso no login
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login realizado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushReplacementNamed(AppRoutes.HOME);
          }
          
          // Erro no login
          if (state is AuthError) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.inputBackground,
                title: const Text(
                  'Falha no Login',
                  style: TextStyle(color: AppColors.white),
                ),
                content: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.textHint),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: AppColors.primaryRed),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Bem-vindo de volta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Campo de E-mail com Validação
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        !value.contains('@')) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de Senha com Validação
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(hintText: 'Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira sua senha.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Coleta de Informação: Checkbox
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Lembrar de mim',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                  value: _rememberMe,
                  onChanged: (newValue) {
                    setState(() {
                      _rememberMe = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primaryRed,
                  checkColor: AppColors.white,
                ),
                const SizedBox(height: 24),

                // Botão de Entrar com indicador de loading do BLoC
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.white)
                            : const Text('Entrar'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Links para "Esqueceu a senha?" e "Cadastre-se"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta?',
                      style: TextStyle(color: AppColors.textHint, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.REGISTER);
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}