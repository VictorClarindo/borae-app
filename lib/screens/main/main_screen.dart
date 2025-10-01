import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Tela principal que gerencia a navegação entre as abas com animação
class MainScreen extends StatefulWidget {
  final int initialPage;
  
  const MainScreen({super.key, this.initialPage = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          // Conteúdo das páginas com animação
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                // Página 0: Home (sem o bottom bar próprio)
                _HomeContent(),
                
                // Página 1: Eventos (placeholder por enquanto)
                _EventsPlaceholder(),
                
                // Página 2: Ingressos (sem o bottom bar próprio)
                _TicketsContent(),
                
                // Página 3: Perfil (placeholder por enquanto)
                _ProfilePlaceholder(),
              ],
            ),
          ),
          
          // Bottom Navigation Bar compartilhado
          _buildBottomNavBar(),
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
    final isSelected = _currentPage == index;

    return InkWell(
      onTap: () => _onNavItemTapped(index),
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

/// Conteúdo da Home (extraído da HomeScreen original)
class _HomeContent extends StatefulWidget {
  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> with AutomaticKeepAliveClientMixin {
  bool _isCalendarExpanded = false;
  DateTime _selectedDate = DateTime.now();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Column(
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
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.header,
      ),
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
          _buildMonthControls(),
          const SizedBox(height: 8),
          _buildWeekDays(),
          const SizedBox(height: 2),
          _buildDaysGrid(),
          if (_isCalendarExpanded) ...[],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMonthControls() {
    final monthYear = '${_getMonthName(_selectedDate.month)} - ${_selectedDate.year}';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.white, size: 18),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
              });
            },
          ),
          Text(
            monthYear,
            style: const TextStyle(
              fontFamily: 'SplineSans',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.white, size: 18),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
              });
            },
          ),
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

  Widget _buildWeekDays() {
    const weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: weekDays.map((day) => Expanded(
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
      )).toList(),
    );
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7;
    
    List<Widget> dayWidgets = [];
    
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 48, height: 48));
    }
    
    for (int day = 1; day <= daysInMonth; day++) {
      final isToday = day == DateTime.now().day && 
                      _selectedDate.month == DateTime.now().month &&
                      _selectedDate.year == DateTime.now().year;
      
      dayWidgets.add(_buildDayCell(day, isToday));
    }
    
    while (dayWidgets.length % 7 != 0) {
      dayWidgets.add(const SizedBox(width: 48, height: 48));
    }
    
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
    
    if (!_isCalendarExpanded && weeks.isNotEmpty) {
      return weeks.first;
    }
    
    return Column(children: weeks);
  }

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

  Widget _buildHighlightsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _buildEventsGrid(),
        ],
      ),
    );
  }

  Widget _buildEventsGrid() {
    final events = [
      {'title': 'Festa de Boas-Vindas', 'description': 'Celebre o início do semestre'},
      {'title': 'Workshop de Fotografia', 'description': 'Aprenda técnicas com um profissional'},
      {'title': 'Palestra sobre Inovação', 'description': 'Descubra novas tendências'},
      {'title': 'Show Acústico', 'description': 'Uma noite de música ao vivo'},
    ];
    
    return Column(
      children: [
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

  Widget _buildEventCard(Map<String, String> event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
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

  String _getMonthName(int month) {
    const months = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
                    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
    return months[month - 1];
  }
}

/// Conteúdo dos Ingressos (extraído da TicketsScreen)
class _TicketsContent extends StatefulWidget {
  @override
  State<_TicketsContent> createState() => _TicketsContentState();
}

class _TicketsContentState extends State<_TicketsContent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Próximos'),
                _buildUpcomingTickets(),
                _buildSectionTitle('Passados'),
                _buildPastTickets(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: const BoxDecoration(color: AppColors.header),
      child: const Center(
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

  Widget _buildUpcomingTickets() {
    final tickets = [
      {'title': 'Festa do Calouro 2024', 'date': '22 de março', 'time': '20:00', 'location': 'Espaço Cultural'},
      {'title': 'Show de Talentos da Engenharia', 'date': '15 de abril', 'time': '19:00', 'location': 'Auditório Central'},
    ];

    return Column(
      children: tickets.map((ticket) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildTicketCard(ticket),
      )).toList(),
    );
  }

  Widget _buildPastTickets() {
    final tickets = [
      {'title': 'Semana da Informática', 'date': '10 de fevereiro', 'time': '09:00', 'location': 'Bloco A'},
    ];

    return Column(
      children: tickets.map((ticket) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildTicketCard(ticket),
      )).toList(),
    );
  }

  Widget _buildTicketCard(Map<String, String> ticket) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ingresso', style: TextStyle(fontFamily: 'SplineSans', fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFFBA9C9C), height: 1.5)),
              const SizedBox(height: 4),
              Text(ticket['title']!, style: const TextStyle(fontFamily: 'SplineSans', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.white, height: 1.25), maxLines: 2),
              const SizedBox(height: 4),
              Text('${ticket['date']} · ${ticket['time']} · ${ticket['location']}', style: const TextStyle(fontFamily: 'SplineSans', fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFFBA9C9C), height: 1.5), maxLines: 2),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 130,
          height: 90,
          decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.confirmation_number, color: AppColors.textHint, size: 40),
        ),
      ],
    );
  }
}

/// Placeholder para Eventos
class _EventsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: const BoxDecoration(color: AppColors.header),
          child: const Center(
            child: Text('Eventos', style: TextStyle(fontFamily: 'SplineSans', fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.white)),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('Em breve...', style: TextStyle(fontFamily: 'SplineSans', fontSize: 18, color: AppColors.textHint)),
          ),
        ),
      ],
    );
  }
}

/// Placeholder para Perfil
class _ProfilePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: const BoxDecoration(color: AppColors.header),
          child: const Center(
            child: Text('Perfil', style: TextStyle(fontFamily: 'SplineSans', fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.white)),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('Em breve...', style: TextStyle(fontFamily: 'SplineSans', fontSize: 18, color: AppColors.textHint)),
          ),
        ),
      ],
    );
  }
}
