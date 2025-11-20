import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/ticket/ticket_bloc.dart';
import '../../bloc/ticket/ticket_event.dart';
import '../../bloc/ticket/ticket_state.dart';
import '../../models/event.dart';
// import '../../models/ticket.dart'; // não usado após refatoração
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int _ticketQuantity = 1;
  Event? event;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    event = ModalRoute.of(context)?.settings.arguments as Event?;
  }
  
  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: const Center(
          child: Text(
            'Erro: evento não encontrado',
            style: TextStyle(color: AppColors.white),
          ),
        ),
      );
    }

    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Navegar para tela de sucesso
          Navigator.of(context).pushReplacementNamed(AppRoutes.PURCHASE_SUCCESS);
        }
        if (state is TicketError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildEventImage(),
                    _buildEventTitle(),
                    _buildEventDetails(),
                    _buildEventDescription(),
                    _buildTicketsSection(),
                    _buildTicketSelector(),
                    const SizedBox(height: 80), // Espaço para o botão flutuante
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildPurchaseButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: 72,
      decoration: const BoxDecoration(color: AppColors.black),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Expanded(
            child: Text(
              'Detalhes do Evento',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SplineSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEventImage() {
    final imageUrl = event!.imageUrl ?? '';
    
    return Container(
      width: double.infinity,
      height: 250,
      decoration: const BoxDecoration(
        color: AppColors.inputBackground,
      ),
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryRed,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.event,
                color: AppColors.textHint,
                size: 80,
              ),
            )
          : const Icon(
              Icons.event,
              color: AppColors.textHint,
              size: 80,
            ),
    );
  }

  Widget _buildEventTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        event!.name,
        style: const TextStyle(
          fontFamily: 'SplineSans',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: AppColors.white,
          height: 1.27,
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    final dateFormat = DateFormat('dd/MM/yyyy · HH:mm');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
                dateFormat.format(event!.date),
                style: const TextStyle(
                  fontFamily: 'SplineSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFBA9C9C),
                  height: 1.5,
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
                  event!.location,
                  style: const TextStyle(
                    fontFamily: 'SplineSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFFBA9C9C),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Categoria
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              event!.type,
              style: const TextStyle(
                fontFamily: 'SplineSans',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: AppColors.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Text(
        event!.description,
        style: const TextStyle(
          fontFamily: 'SplineSans',
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: AppColors.white,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTicketsSection() {
    final available = event!.availableTickets;
    final total = event!.totalTickets;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ingressos',
            style: TextStyle(
              fontFamily: 'SplineSans',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.white,
              height: 1.28,
            ),
          ),
          Text(
            '$available/$total disponíveis',
            style: TextStyle(
              fontFamily: 'SplineSans',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: available > 0 ? Colors.green : Colors.red,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSelector() {
    final maxTickets = event!.availableTickets < 10 
        ? event!.availableTickets 
        : 10; // Limite máximo de 10 ingressos por compra
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresso Pista',
                style: TextStyle(
                  fontFamily: 'SplineSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.white,
                  height: 1.5,
                ),
              ),
              Text(
                'R\$ ${event!.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'SplineSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFBA9C9C),
                  height: 1.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildQuantityButton('-', () {
                if (_ticketQuantity > 1) {
                  setState(() {
                    _ticketQuantity--;
                  });
                }
              }),
              const SizedBox(width: 8),
              Text(
                '$_ticketQuantity',
                style: const TextStyle(
                  fontFamily: 'SplineSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              _buildQuantityButton('+', () {
                if (_ticketQuantity < maxTickets) {
                  setState(() {
                    _ticketQuantity++;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Máximo de $maxTickets ingressos disponíveis'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF382929),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'SplineSans',
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: AppColors.white,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    final totalPrice = event!.price * _ticketQuantity;
    final isAvailable = event!.availableTickets >= _ticketQuantity;
    
    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        final isLoading = state is TicketLoading;
        
        return Container(
          width: MediaQuery.of(context).size.width - 32,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ElevatedButton(
            onPressed: isAvailable && !isLoading ? _handlePurchase : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable 
                  ? AppColors.primaryRed 
                  : AppColors.textHint,
              disabledBackgroundColor: AppColors.textHint,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isAvailable
                        ? 'Comprar · R\$ ${totalPrice.toStringAsFixed(2)}'
                        : 'Esgotado',
                    style: const TextStyle(
                      fontFamily: 'SplineSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.white,
                      height: 1.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _handlePurchase() {
    final authState = context.read<AuthBloc>().state;
    
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para comprar ingressos'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pushNamed(AppRoutes.LOGIN);
      return;
    }

    // Disparar requisição de compra agrupada
    context.read<TicketBloc>().add(
      TicketPurchaseRequest(
        event: event!,
        user: authState.user,
        quantity: _ticketQuantity,
      ),
    );
  }
}
