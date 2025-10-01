import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCalendarExpanded = false;
  DateTime _selectedDate = DateTime.now();
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Body com scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar Section
                  _buildCalendarSection(),

                  // Highlights Section
                  _buildHighlightsSection(),
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

  /// Header fixo no topo
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: const BoxDecoration(color: AppColors.header),
      child: const Center(
        child: Text(
          'BoraÊ',
          style: TextStyle(
            fontFamily: 'SplineSans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  /// Seção do calendário com expansão
  Widget _buildCalendarSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.white, width: 1),
          bottom: BorderSide(color: AppColors.white, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Controles do mês
          _buildMonthControls(),

          const SizedBox(height: 8),

          // Dias da semana
          _buildWeekDays(),

          const SizedBox(height: 2),

          // Grid de dias (sempre mostra pelo menos a primeira semana)
          _buildDaysGrid(),

          // Grid expandido (se expandido, mostra resto)
          if (_isCalendarExpanded) ...[],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Controles de navegação do mês
  Widget _buildMonthControls() {
    final monthYear =
        '${_getMonthName(_selectedDate.month)} - ${_selectedDate.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão anterior
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.white,
              size: 18,
            ),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
            },
          ),

          // Mês e ano
          Text(
            monthYear,
            style: const TextStyle(
              fontFamily: 'SplineSans',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.white,
            ),
          ),

          // Botão próximo
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.white,
              size: 18,
            ),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
              });
            },
          ),

          // Botão expandir/recolher
          IconButton(
            icon: Icon(
              _isCalendarExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.white,
              size: 18,
            ),
            onPressed: () {
              setState(() {
                _isCalendarExpanded = !_isCalendarExpanded;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Cabeçalho com dias da semana
  Widget _buildWeekDays() {
    const weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: weekDays
          .map(
            (day) => Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'SplineSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF6E6E6E),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// Grid com os dias do mês
  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7; // Domingo = 0

    List<Widget> dayWidgets = [];

    // Espaços vazios antes do primeiro dia
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 48, height: 48));
    }

    // Dias do mês
    for (int day = 1; day <= daysInMonth; day++) {
      final isToday =
          day == DateTime.now().day &&
          _selectedDate.month == DateTime.now().month &&
          _selectedDate.year == DateTime.now().year;

      dayWidgets.add(_buildDayCell(day, isToday));
    }

    // Completar a última semana com espaços vazios
    while (dayWidgets.length % 7 != 0) {
      dayWidgets.add(const SizedBox(width: 48, height: 48));
    }

    // Organizar em semanas (linhas de 7 dias)
    List<Widget> weeks = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      weeks.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(7, (index) {
              final widgetIndex = i + index;
              if (widgetIndex < dayWidgets.length) {
                return Expanded(child: dayWidgets[widgetIndex]);
              }
              return const Expanded(child: SizedBox(width: 48, height: 48));
            }),
          ),
        ),
      );
    }

    // Se não expandido, mostrar apenas a primeira semana
    if (!_isCalendarExpanded && weeks.isNotEmpty) {
      return weeks.first;
    }

    // Se expandido, mostrar todas as semanas
    return Column(children: weeks);
  }

  /// Célula individual de um dia
  Widget _buildDayCell(int day, bool isHighlighted) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primaryRed : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '$day',
        style: const TextStyle(
          fontFamily: 'SplineSans',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: AppColors.white,
        ),
      ),
    );
  }

  /// Seção de destaques (eventos)
  Widget _buildHighlightsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              'Destaques',
              style: TextStyle(
                fontFamily: 'SplineSans',
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.white,
              ),
            ),
          ),

          // Grid de eventos
          _buildEventsGrid(),
        ],
      ),
    );
  }

  /// Grid com os cards de eventos
  Widget _buildEventsGrid() {
    final events = [
      {
        'title': 'Festa de Boas-Vindas',
        'description': 'Celebre o início do semestre',
        'image': 'assets/images/event1.png',
      },
      {
        'title': 'Workshop de Fotografia',
        'description': 'Aprenda técnicas com um profissional',
        'image': 'assets/images/event2.png',
      },
      {
        'title': 'Palestra sobre Inovação',
        'description': 'Descubra novas tendências',
        'image': 'assets/images/event3.png',
      },
      {
        'title': 'Show Acústico',
        'description': 'Uma noite de música ao vivo',
        'image': 'assets/images/event4.png',
      },
    ];

    return Column(
      children: [
        // Primeira linha
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildEventCard(events[0])),
              const SizedBox(width: 12),
              Expanded(child: _buildEventCard(events[1])),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Segunda linha
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildEventCard(events[2])),
              const SizedBox(width: 12),
              Expanded(child: _buildEventCard(events[3])),
            ],
          ),
        ),
      ],
    );
  }

  /// Card individual de evento
  Widget _buildEventCard(Map<String, String> event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        // Imagem do evento
        AspectRatio(
          aspectRatio: 150 / 97,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event, color: AppColors.textHint, size: 40),
          ),
        ),

        const SizedBox(height: 8),

        // Título
        Text(
          event['title']!,
          style: const TextStyle(
            fontFamily: 'SplineSans',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: AppColors.white,
            height: 1.6,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 2),

        // Descrição
        Text(
          event['description']!,
          style: const TextStyle(
            fontFamily: 'SplineSans',
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: Color(0xFFBA9C9C),
            height: 1.6,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.header,
        border: Border(top: BorderSide(color: Color(0xFFBA9C9C), width: 1)),
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

  /// Helper para obter nome do mês
  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }
}
