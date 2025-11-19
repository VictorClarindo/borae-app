import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/event/event_bloc.dart';
import 'bloc/ticket/ticket_bloc.dart';
import 'data/auth_data_provider.dart';
import 'data/event_data_provider.dart';
import 'data/ticket_data_provider.dart';
import 'firebase_options.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/event/create_event_screen.dart';
import 'screens/event/event_details_screen.dart';
import 'screens/event/purchase_success_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/tickets/tickets_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_routes.dart';

// A função main() é onde tudo começa.
void main() async {
  // Garantir que o Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const BoraEApp());
}

// O widget principal que encapsula todo o seu aplicativo.
class BoraEApp extends StatelessWidget {
  const BoraEApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider fornece os BLoCs para toda a aplicação
    return MultiBlocProvider(
      providers: [
        // BLoC de Autenticação
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authDataProvider: AuthDataProvider(),
          )..add(const AuthCheckRequested()),
        ),
        // BLoC de Eventos
        BlocProvider<EventBloc>(
          create: (context) => EventBloc(
            eventDataProvider: EventDataProvider(),
          ),
        ),
        // BLoC de Ingressos
        BlocProvider<TicketBloc>(
          create: (context) => TicketBloc(
            ticketDataProvider: TicketDataProvider(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'BoraÊ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'SplineSans',
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
              backgroundColor: AppColors.primaryRed,
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
        initialRoute: AppRoutes.LOGIN,
        routes: {
          AppRoutes.LOGIN: (context) => const LoginScreen(),
          AppRoutes.REGISTER: (context) => const RegisterScreen(),
          AppRoutes.HOME: (context) => const MainScreen(),
          AppRoutes.TICKETS: (context) => const TicketsScreen(),
          AppRoutes.CREATE_EVENT: (context) => const CreateEventScreen(),
          AppRoutes.EVENT_DETAILS: (context) => const EventDetailsScreen(),
          AppRoutes.PURCHASE_SUCCESS: (context) =>
              const PurchaseSuccessScreen(),
        },
      ),
    );
  }
}
