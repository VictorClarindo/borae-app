import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBottomNav;
  
  const ProfileScreen({super.key, this.showBottomNav = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isEditing = false;
  int _selectedTab = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          // Se não estiver autenticado, redirecionar para login usando post frame e checando mounted
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed(AppRoutes.LOGIN);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        
        // Preencher controllers com dados atuais
        if (_nameController.text.isEmpty) {
          _nameController.text = user.name;
          _emailController.text = user.email;
        }

        return Scaffold(
          backgroundColor: AppColors.black,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildProfileHeader(user),
                          const SizedBox(height: 32),
                          _buildProfileForm(user),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.showBottomNav) _buildBottomNavBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.black,
        border: Border(
          bottom: BorderSide(color: Color(0xFFBA9C9C), width: 1),
        ),
      ),
      child: const Text(
        'Meu Perfil',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'SplineSans',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Nome
        Text(
          user.name,
          style: const TextStyle(
            fontFamily: 'SplineSans',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        
        // Tipo de usuário
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.userType == 'organizer' ? 'Organizador' : 'Participante',
            style: const TextStyle(
              fontFamily: 'SplineSans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.primaryRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm(User user) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome
          const Text(
            'Nome',
            style: TextStyle(
              fontFamily: 'SplineSans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            enabled: _isEditing,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Digite seu nome',
              hintStyle: const TextStyle(color: AppColors.textHint),
              filled: true,
              fillColor: _isEditing 
                  ? AppColors.inputBackground 
                  : AppColors.inputBackground.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                Icons.person,
                color: AppColors.textHint,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira seu nome';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Email (não editável)
          const Text(
            'Email',
            style: TextStyle(
              fontFamily: 'SplineSans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            enabled: false,
            style: const TextStyle(color: AppColors.textHint),
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: const TextStyle(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.inputBackground.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                Icons.email,
                color: AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Informação sobre email
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textHint,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'O email não pode ser alterado',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botão Editar/Salvar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (_isEditing) {
                if (_formKey.currentState!.validate()) {
                  // TODO: Implementar atualização do perfil
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade de edição em desenvolvimento'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  setState(() {
                    _isEditing = false;
                  });
                }
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isEditing 
                  ? Colors.green 
                  : AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isEditing ? 'Salvar Alterações' : 'Editar Perfil',
              style: const TextStyle(
                fontFamily: 'SplineSans',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        
        if (_isEditing) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Restaurar valores originais
                  final state = context.read<AuthBloc>().state;
                  if (state is AuthAuthenticated) {
                    _nameController.text = state.user.name;
                  }
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textHint),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'SplineSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 24),
        const Divider(color: AppColors.textHint),
        const SizedBox(height: 24),
        
        // Botão Sair
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              _showLogoutDialog();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Sair da Conta',
              style: TextStyle(
                fontFamily: 'SplineSans',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.inputBackground,
          title: const Text(
            'Sair da Conta',
            style: TextStyle(color: AppColors.white),
          ),
          content: const Text(
            'Tem certeza que deseja sair?',
            style: TextStyle(color: AppColors.textHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Color(0xFF2C0000),
        border: Border(
          top: BorderSide(color: Color(0xFFBA9C9C), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, 'Home', AppRoutes.HOME),
            _buildNavItem(1, Icons.add_circle, 'Criar', AppRoutes.CREATE_EVENT),
            _buildNavItem(2, Icons.confirmation_number, 'Ingressos', AppRoutes.TICKETS),
            _buildNavItem(3, Icons.person, 'Perfil', null),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, String? route) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (route != null) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
        borderRadius: BorderRadius.circular(27),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryRed : Colors.transparent,
            borderRadius: BorderRadius.circular(27),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.white : const Color(0xFFBA9C9C),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SplineSans',
                  color:
                      isSelected ? AppColors.white : const Color(0xFFBA9C9C),
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
