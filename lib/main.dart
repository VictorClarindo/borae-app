import 'package:flutter/material.dart';

import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/home/home.dart';
import 'utils/app_colors.dart';
import 'utils/app_routes.dart';

// A função main() é onde tudo começa.
void main() {
  runApp(const BoraEApp());
}

// O widget principal que encapsula todo o seu aplicativo.
class BoraEApp extends StatelessWidget {
  const BoraEApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp é o widget raiz que fornece funcionalidades essenciais
    // como navegação, temas e muito mais.
    return MaterialApp(
      title: 'BoraÊ',
      debugShowCheckedModeBanner:
          false, // Remove a faixa "Debug" no canto da tela
      // 2. CONFIGURAÇÃO DO TEMA GLOBAL
      // Todas as cores, fontes e estilos definidos aqui serão aplicados
      // em todo o aplicativo, garantindo consistência visual.
      theme: ThemeData(
        fontFamily:
            'SplineSans', // Lembre-se de configurar a fonte no pubspec.yaml
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.black,

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.header,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'SplineSans',
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBackground,
          hintStyle: const TextStyle(color: AppColors.textHint),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // Esta linha define a cor de fundo de todos os botões elevados
            backgroundColor: AppColors.primaryRed, // <--- AQUI!
            // E esta, a cor do texto
            foregroundColor: AppColors.white,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: const TextStyle(
              fontFamily: 'SplineSans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // 3. CONFIGURAÇÃO DAS ROTAS DE NAVEGAÇÃO
      // A 'initialRoute' define qual rota (e consequentemente qual tela)
      // será carregada quando o app iniciar.
      initialRoute: AppRoutes.LOGIN,

      // O 'routes' é um mapa que liga o nome de uma rota a um widget de tela.
      // Isso permite navegar entre telas de forma organizada.
      routes: {
        AppRoutes.LOGIN: (context) => const LoginScreen(),
        AppRoutes.REGISTER: (context) =>
            const RegisterScreen(), // Crie este arquivo com um esqueleto
        AppRoutes.HOME: (context) =>
            const HomeScreen(), // Crie este arquivo também
      },
    );
  }
}
