import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

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

  // Variável para controlar o estado de carregamento
  bool _isLoading = false;

  @override
  void dispose() {
    // É importante limpar os controladores para liberar memória
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Função para lidar com a lógica de cadastro
  Future<void> _register() async {
    // Executa a validação de todos os campos do formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Simula uma chamada de API para o Firebase com 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    // --- LÓGICA DE CADASTRO SIMULADA ---
    // Aqui você chamaria o método para criar um usuário no Firebase Auth
    
    // Simulação de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cadastro realizado com sucesso! Faça o login para continuar.'),
        backgroundColor: Colors.green,
      ),
    );

    // Após o sucesso, voltamos para a tela de login
    if (mounted) { // Verifica se o widget ainda está na tela
      Navigator.of(context).pop();
    }
    // --- FIM DA LÓGICA SIMULADA ---

    // Apenas para o caso de a tela não ser removida após a lógica
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        // A seta de voltar é adicionada automaticamente pelo Flutter ao navegar
      ),
      body: SingleChildScrollView(
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
                  if (value == null || !value.contains('@') || !value.contains('.')) {
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
                  // Validação crucial: verifica se o valor é igual ao do campo de senha
                  if (value != _passwordController.text) {
                    return 'As senhas não coincidem.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botão Finalizar Cadastro
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text('Finalizar cadastro'),
                ),
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
                      // Simplesmente volta para a tela anterior (Login)
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
    );
  }
}