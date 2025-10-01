import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class PurchaseSuccessScreen extends StatelessWidget {
  const PurchaseSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                _buildSuccessMessage(),
                _buildSuccessDescription(),
                _buildEventInfo(),
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              'Ingressos',
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

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: const Text(
        'Obrigado pela sua compra!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'SplineSans',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: AppColors.white,
          height: 1.27,
        ),
      ),
    );
  }

  Widget _buildSuccessDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: const Text(
        'Seu pedido foi processado com sucesso. Você receberá um e-mail de confirmação em breve.',
        textAlign: TextAlign.center,
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

  Widget _buildEventInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Festa de Arromba',
                style: TextStyle(
                  fontFamily: 'SplineSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.white,
                  height: 1.5,
                ),
              ),
              const Text(
                'Sáb, 22 de Junho · 20:00',
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
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.HOME, 
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Voltar para o Início',
                style: TextStyle(
                  fontFamily: 'SplineSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Implementar compartilhamento
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade de compartilhamento em breve!'),
                    backgroundColor: AppColors.primaryRed,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF382929),
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Compartilhar',
                style: TextStyle(
                  fontFamily: 'SplineSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}