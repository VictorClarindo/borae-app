// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
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
  bool _isLoading = false;

  // Limpa os controladores quando o widget é descartado para evitar vazamento de memória
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Função assíncrona para lidar com a lógica de login
  Future<void> _login() async {
    // Primeiro, valida o formulário. Se não for válido, a função para aqui.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Altera o estado para mostrar o indicador de carregamento
    setState(() {
      _isLoading = true;
    });

    // Simula uma chamada de rede (ex: para o Firebase) com 2 segundos de atraso
    await Future.delayed(const Duration(seconds: 2));

    // --- LÓGICA DE AUTENTICAÇÃO SIMULADA ---
    // Em um app real, aqui você chamaria o Firebase Auth
    if (_emailController.text == 'contato@borae.com' && _passwordController.text == '123456') {
      
      // Interação com Usuário: SnackBar em caso de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navega para a tela principal após o sucesso
      Navigator.of(context).pushReplacementNamed(AppRoutes.HOME);

    } else {
      
      // Interação com Usuário: Dialog em caso de erro
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.inputBackground,
          title: const Text('Falha no Login', style: TextStyle(color: AppColors.white)),
          content: const Text('E-mail ou senha incorretos. Tente novamente.', style: TextStyle(color: AppColors.textHint)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK', style: TextStyle(color: AppColors.primaryRed)),
            ),
          ],
        ),
      );
    }
    // --- FIM DA LÓGICA SIMULADA ---

    // Altera o estado para esconder o indicador de carregamento
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BoraÊ'),
      ),
      body: SingleChildScrollView(
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
                  if (value == null || value.trim().isEmpty || !value.contains('@')) {
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

              // Botão de Entrar com indicador de loading
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login, // Desabilita o botão durante o loading
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text('Entrar'),
                ),
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
    );
  }
}