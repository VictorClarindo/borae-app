import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  int _selectedTab = 2; // Ingressos está selecionado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          // Header com botão de voltar
          _buildHeader(),

          // Body com scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seção Próximos
                  _buildSectionTitle('Próximos'),
                  _buildUpcomingTickets(),

                  // Seção Passados
                  _buildSectionTitle('Passados'),
                  _buildPastTickets(),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  /// Header com botão voltar e título
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.black,
      ),
      child: Row(
        children: [
          // Botão voltar
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),

          // Título centralizado
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 48), // Compensa o botão voltar
              child: Text(
                'Meus Ingressos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SplineSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Título de seção
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'SplineSans',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: AppColors.white,
        ),
      ),
    );
  }

  /// Lista de ingressos próximos
  Widget _buildUpcomingTickets() {
    final upcomingTickets = [
      {
        'title': 'Festa do Calouro 2024',
        'date': '22 de março',
        'time': '20:00',
        'location': 'Espaço Cultural',
        'image': 'assets/images/ticket1.png',
      },
      {
        'title': 'Show de Talentos da Engenharia',
        'date': '15 de abril',
        'time': '19:00',
        'location': 'Auditório Central',
        'image': 'assets/images/ticket2.png',
      },
    ];

    return Column(
      children: upcomingTickets
          .map((ticket) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildTicketCard(ticket),
              ))
          .toList(),
    );
  }

  /// Lista de ingressos passados
  Widget _buildPastTickets() {
    final pastTickets = [
      {
        'title': 'Semana da Informática',
        'date': '10 de fevereiro',
        'time': '09:00',
        'location': 'Bloco A',
        'image': 'assets/images/ticket3.png',
      },
    ];

    return Column(
      children: pastTickets
          .map((ticket) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildTicketCard(ticket),
              ))
          .toList(),
    );
  }

  /// Card de ingresso individual
  Widget _buildTicketCard(Map<String, String> ticket) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações do ingresso
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label "Ingresso"
                const Text(
                  'Ingresso',
                  style: TextStyle(
                    fontFamily: 'SplineSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFFBA9C9C),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 4),

                // Título do evento
                Text(
                  ticket['title']!,
                  style: const TextStyle(
                    fontFamily: 'SplineSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.white,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Detalhes (data, hora, local)
                Text(
                  '${ticket['date']} · ${ticket['time']} · ${ticket['location']}',
                  style: const TextStyle(
                    fontFamily: 'SplineSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFFBA9C9C),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Imagem do evento
          Container(
            width: 130,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number,
              color: AppColors.textHint,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.header,
        border: Border(
          top: BorderSide(color: Color(0xFFBA9C9C), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Início'),
              _buildNavItem(1, Icons.calendar_today, 'Eventos'),
              _buildNavItem(2, Icons.confirmation_number, 'Ingressos'),
              _buildNavItem(3, Icons.person, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  /// Item individual da navigation bar
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
        
        // Navegar de volta para home se clicar em Início
        if (index == 0) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: isSelected ? AppColors.white : const Color(0xFFBA9C9C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
