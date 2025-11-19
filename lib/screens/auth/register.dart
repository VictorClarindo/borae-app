import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Chave para o nosso formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para cada campo de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Tipo de usuário: 'participant' ou 'organizer'
  String _userType = 'participant';

  @override
  void dispose() {
    // É importante limpar os controladores para liberar memória
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Função para lidar com a lógica de cadastro usando BLoC
  void _register() {
    // Executa a validação de todos os campos do formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dispara o evento de cadastro no AuthBloc
    context.read<AuthBloc>().add(
          AuthSignUpRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            userType: _userType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Sucesso no cadastro
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Cadastro realizado com sucesso! Bem-vindo ao BoraÊ!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushReplacementNamed(AppRoutes.HOME);
          }

          // Erro no cadastro
          if (state is AuthError) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.inputBackground,
                title: const Text(
                  'Erro no Cadastro',
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
                const SizedBox(height: 32),

                // Campo Nome Completo
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Nome completo'),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O nome é obrigatório.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo E-mail
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        !value.contains('@') ||
                        !value.contains('.')) {
                      return 'Insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Senha
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(hintText: 'Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'A senha deve ter no mínimo 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Confirmar Senha
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(hintText: 'Confirmar senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Seleção de tipo de usuário
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de conta',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Participante',
                          style: TextStyle(color: AppColors.white),
                        ),
                        subtitle: const Text(
                          'Quero comprar ingressos e participar de eventos',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12),
                        ),
                        value: 'participant',
                        groupValue: _userType,
                        activeColor: AppColors.primaryRed,
                        onChanged: (value) {
                          setState(() => _userType = value!);
                        },
                      ),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Organizador',
                          style: TextStyle(color: AppColors.white),
                        ),
                        subtitle: const Text(
                          'Quero criar e gerenciar eventos',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12),
                        ),
                        value: 'organizer',
                        groupValue: _userType,
                        activeColor: AppColors.primaryRed,
                        onChanged: (value) {
                          setState(() => _userType = value!);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Botão Finalizar Cadastro com BLoC
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _register,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.white)
                            : const Text('Finalizar cadastro'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Link para voltar ao Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já possui uma conta?',
                      style: TextStyle(color: AppColors.textHint, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Faça o login',
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