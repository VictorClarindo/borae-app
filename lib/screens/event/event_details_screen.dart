import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int _ticketQuantity = 1;
  Map<String, String>? eventData;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    eventData = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ],
              ),
            ),
          ),
          _buildPurchaseButton(),
        ],
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
    return Container(
      width: double.infinity,
      height: 218,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
      ),
      child: const Icon(
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
        eventData?['title'] ?? 'Festa do Calouro 2024',
        style: const TextStyle(
          fontFamily: 'SplineSans',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: AppColors.white,
          height: 1.27,
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Text(
        eventData?['location'] ?? '22 de março · 20:00 · Espaço Cultural',
        style: const TextStyle(
          fontFamily: 'SplineSans',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xFFBA9C9C),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildEventDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: const Text(
        'Prepare-se para a maior festa do ano! A Festa do Calouro 2024 promete muita música, dança e diversão. Garanta seu ingresso e celebre o início de uma nova jornada.',
        style: TextStyle(
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: const Text(
        'Ingressos',
        style: TextStyle(
          fontFamily: 'SplineSans',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.white,
          height: 1.28,
        ),
      ),
    );
  }

  Widget _buildTicketSelector() {
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
              const Text(
                'R\$ 50,00',
                style: TextStyle(
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
                setState(() {
                  _ticketQuantity++;
                });
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF382929),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'SplineSans',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: AppColors.white,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.PURCHASE_SUCCESS);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text(
          'Comprar',
          style: TextStyle(
            fontFamily: 'SplineSans',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.white,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}