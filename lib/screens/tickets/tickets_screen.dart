import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/ticket/ticket_bloc.dart';
import '../../bloc/ticket/ticket_event.dart';
import '../../bloc/ticket/ticket_state.dart';
import '../../models/ticket.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  int _selectedTab = 2;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TicketBloc>().add(
            TicketLoadUserTickets(userId: authState.user.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is TicketOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _loadTickets();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<TicketBloc, TicketState>(
                builder: (context, state) {
                  if (state is TicketLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                      ),
                    );
                  }

                  if (state is TicketError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(color: AppColors.textHint),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadTickets,
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is TicketLoaded) {
                    if (state.tickets.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.confirmation_number_outlined,
                              size: 64,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Você ainda não tem ingressos',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.HOME);
                              },
                              child: const Text('Explorar Eventos'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Separar tickets em próximos e passados
                    final now = DateTime.now();
                    final upcomingTickets = state.tickets
                        .where((ticket) =>
                            ticket.eventDate.isAfter(now) &&
                            ticket.status == 'active')
                        .toList();
                    final pastTickets = state.tickets
                        .where((ticket) =>
                            ticket.eventDate.isBefore(now) ||
                            ticket.status != 'active')
                        .toList();

                    return RefreshIndicator(
                      onRefresh: () async {
                        _loadTickets();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (upcomingTickets.isNotEmpty) ...[
                              _buildSectionTitle('Próximos'),
                              ...upcomingTickets
                                  .map((ticket) => _buildTicketCard(ticket)),
                            ],
                            if (pastTickets.isNotEmpty) ...[
                              _buildSectionTitle('Passados'),
                              ...pastTickets
                                  .map((ticket) => _buildTicketCard(ticket)),
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.black,
      ),
      child: Row(
        children: [
          IconButton(
            icon:
                const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 48),
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

  Widget _buildTicketCard(Ticket ticket) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isActive = ticket.status == 'active';
    final isPast = ticket.eventDate.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF382929),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do ingresso
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive && !isPast
                    ? AppColors.primaryRed
                    : const Color(0xFF5A4444),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_number,
                    color: AppColors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ticket.eventName,
                      style: const TextStyle(
                        fontFamily: 'SplineSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Informações do ingresso
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data e hora
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(ticket.eventDate),
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Local
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ticket.eventLocation,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Status e preço
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ticket.status).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(ticket.status),
                          style: TextStyle(
                            color: _getStatusColor(ticket.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'R\$ ${ticket.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'used':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textHint;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'used':
        return 'Usado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
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
            _buildNavItem(2, Icons.confirmation_number, 'Ingressos', null),
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
