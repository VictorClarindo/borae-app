import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/event/event_bloc.dart';
import '../../bloc/event/event_event.dart';
import '../../bloc/event/event_state.dart';
import '../../models/event.dart';
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
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _facultyController = TextEditingController();
  
  String _selectedType = 'Tipo';
  int _selectedNavIndex = 1;
  File? _selectedImage;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryRed,
              onPrimary: AppColors.white,
              surface: AppColors.inputBackground,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryRed,
                onPrimary: AppColors.white,
                surface: AppColors.inputBackground,
                onSurface: AppColors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (!mounted) return; // Garantir que contexto ainda está válido após awaits
      if (time != null) {
        final dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _selectedDate = dateTime;
          _dateController.text = 
              '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        });
      }
    }
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

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma data.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obter usuário atual do AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para criar eventos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = authState.user;

    // Criar objeto Event
    final event = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate!,
      location: _locationController.text.trim(),
      type: _selectedType,
      totalTickets: int.parse(_quantityController.text),
      availableTickets: int.parse(_quantityController.text),
      price: double.parse(_priceController.text),
      organizerId: user.id,
      organizerName: user.name,
      createdAt: DateTime.now(),
      faculty: _facultyController.text.trim().isEmpty 
          ? null 
          : _facultyController.text.trim(),
    );

    // Disparar evento no EventBloc
    context.read<EventBloc>().add(
      EventCreate(
        event: event,
        imageFile: _selectedImage,
      ),
    );
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
        Navigator.of(context).pushReplacementNamed(AppRoutes.TICKETS);
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Navegar para Home e recarregar eventos
            Navigator.of(context).pushReplacementNamed(AppRoutes.HOME);
          }
          
          if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
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
                          controller: _descriptionController,
                          hint: 'Descrição',
                        ),
                        _buildDateField(),
                        _buildInputField(
                          controller: _locationController,
                          hint: 'Local',
                        ),
                        _buildTypeDropdown(),
                        _buildInputField(
                          controller: _quantityController,
                          hint: 'Quantidade de Ingressos',
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: _priceController,
                          hint: 'Preço (R\$)',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                        _buildInputField(
                          controller: _facultyController,
                          hint: 'Faculdade (Opcional)',
                        ),
                        _buildImagePicker(),
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
          initialValue: _selectedType,
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

  Widget _buildDateField() {
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
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          style: const TextStyle(
            fontFamily: 'SplineSans',
            color: AppColors.white,
            fontSize: 16,
            height: 1.5,
          ),
          decoration: const InputDecoration(
            hintText: 'Data e Hora',
            hintStyle: TextStyle(
              fontFamily: 'SplineSans',
              color: Color(0xFFBA9C9C),
              fontSize: 16,
              height: 1.5,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFBA9C9C)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor, selecione a data.';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 160,
          maxWidth: 480,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF382929),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.image, color: Color(0xFFBA9C9C)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedImage != null
                        ? 'Imagem selecionada'
                        : 'Adicionar imagem do evento',
                    style: TextStyle(
                      color: _selectedImage != null
                          ? AppColors.white
                          : const Color(0xFFBA9C9C),
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_selectedImage != null)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          final isLoading = state is EventLoading;
          return Container(
            constraints: const BoxConstraints(
              minWidth: 160,
              maxWidth: 480,
            ),
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _createEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                disabledBackgroundColor: AppColors.primaryRed.withOpacity(0.5),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Criar Evento'),
            ),
          );
        },
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, 'Home'),
            _buildNavItem(1, Icons.add_circle, 'Criar'),
            _buildNavItem(2, Icons.confirmation_number, 'Ingressos'),
            _buildNavItem(3, Icons.person, 'Perfil'),
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
                  color: isSelected ? AppColors.white : const Color(0xFFBA9C9C),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
