import 'package:flutter/material.dart';

void main() {
  runApp(const BoraEApp());
}

class BoraEApp extends StatelessWidget {
  const BoraEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoraÊ Login',
      theme: ThemeData(
        // Definindo a fonte padrão para o app.
        // Lembre-se de adicionar o arquivo da fonte 'Spline Sans' ao seu projeto.
        fontFamily: 'SplineSans',
        brightness: Brightness.dark, // Define o tema geral como escuro
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o Scaffold como a estrutura base da nossa tela.
    return Scaffold(
      backgroundColor: Colors.black, // Cor de fundo principal da tela
      // O AppBar corresponde ao cabeçalho superior.
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C0000), // Cor do header
        title: const Text(
          'BoraÊ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0, // Remove a sombra padrão do AppBar
      ),
      // SingleChildScrollView evita que o conteúdo quebre quando o teclado aparecer.
      body: SingleChildScrollView(
        // Padding para dar o espaçamento lateral padrão de 16px.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20), // Espaçamento superior
              
              // Seção "Bem-vindo de volta" com o ícone de voltar
              Row(
                children: [
                  // Ícone de voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      // Ação para voltar para a tela anterior
                      // Navigator.pop(context); // Descomente se houver uma tela anterior
                    },
                  ),
                  // Usamos Expanded para que o texto ocupe o espaço restante e possa ser centralizado corretamente.
                  const Expanded(
                    child: Text(
                      'Bem-vindo de volta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Adicionamos um SizedBox para balancear o espaço do IconButton e manter o título centralizado
                   const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24), // Espaçamento

              // Campo de texto para E-mail
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  hintStyle: const TextStyle(color: Color(0xFFBA9C9C)),
                  filled: true,
                  fillColor: const Color(0xFF382929),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // Sem borda visível
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24), // Espaçamento

              // Campo de texto para Senha
              TextField(
                style: const TextStyle(color: Colors.white),
                obscureText: true, // Esconde o texto da senha
                decoration: InputDecoration(
                  hintText: 'Senha',
                  hintStyle: const TextStyle(color: Color(0xFFBA9C9C)),
                  filled: true,
                  fillColor: const Color(0xFF382929),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24), // Espaçamento

              // Botão Entrar
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para o login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF20D0D), // Cor do botão
                    foregroundColor: Colors.white, // Cor do texto
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12), // Espaçamento

              // Texto "Esqueceu a senha?"
              TextButton(
                 onPressed: () {
                   // Lógica para recuperar a senha
                 },
                 child: const Text(
                  'Esqueceu a senha?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFBA9C9C),
                    fontSize: 14,
                  ),
                ),
              ),
              
              // Texto "Não tem uma conta? Cadastre-se"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não tem uma conta?',
                    style: TextStyle(
                      color: Color(0xFFBA9C9C),
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Lógica para navegar para a tela de cadastro
                    },
                    // Removemos o padding padrão do TextButton para um alinhamento melhor
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(
                        color: Colors.white, // Dando um destaque para a parte clicável
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