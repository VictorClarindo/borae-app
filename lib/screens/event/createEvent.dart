import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedType = 'Tipo';
  int _selectedNavIndex = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == 'Tipo') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um tipo de evento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evento criado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.HOME);
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField(
                        controller: _nameController,
                        hint: 'Nome do Evento',
                      ),
                      _buildInputField(
                        controller: _dateController,
                        hint: 'Data',
                      ),
                      _buildInputField(
                        controller: _locationController,
                        hint: 'Local',
                      ),
                      _buildTypeDropdown(),
                      _buildInputField(
                        controller: _quantityController,
                        hint: 'Quantidade',
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        controller: _priceController,
                        hint: 'Preço',
                        keyboardType: TextInputType.number,
                      ),
                      _buildCreateButton(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: 72,
      color: AppColors.black,
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
              'Criar Evento',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SplineSans',
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.28,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 160,
          maxWidth: 480,
        ),
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF382929),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'SplineSans',
            color: AppColors.white,
            fontSize: 16,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'SplineSans',
              color: Color(0xFFBA9C9C),
              fontSize: 16,
              height: 1.5,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
            filled: false,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor, preencha este campo.';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 160,
          maxWidth: 480,
        ),
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF382929),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedType,
          dropdownColor: const Color(0xFF382929),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFBA9C9C), size: 24),
          style: const TextStyle(
            fontFamily: 'SplineSans',
            color: Color(0xFFBA9C9C),
            fontSize: 16,
            height: 1.5,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          items: ['Tipo', 'Show', 'Festival', 'Teatro', 'Esporte', 'Outro']
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 84,
          maxWidth: 480,
        ),
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _createEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Criar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SplineSans',
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Início'),
            const SizedBox(width: 8),
            _buildNavItem(1, Icons.event, 'Eventos'),
            const SizedBox(width: 8),
            _buildNavItem(2, Icons.confirmation_number_outlined, 'Ingressos'),
            const SizedBox(width: 8),
            _buildNavItem(3, Icons.person_outline, 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _navigateToTab(index),
        borderRadius: BorderRadius.circular(27),
        child: Container(
          height: 54,
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 24,
                height: 32,
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.white : const Color(0xFFBA9C9C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SplineSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: isSelected ? AppColors.white : const Color(0xFFBA9C9C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}