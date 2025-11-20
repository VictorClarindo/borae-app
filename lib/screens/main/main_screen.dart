import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/event/event_bloc.dart';
import '../../bloc/event/event_event.dart';
import '../../bloc/event/event_state.dart';
import '../../bloc/ticket/ticket_bloc.dart';
import '../../bloc/ticket/ticket_event.dart';
import '../../bloc/ticket/ticket_state.dart';
import '../../models/event.dart';
import '../../models/ticket.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../events/events_list_screen.dart';
import '../profile/profile_screen.dart';

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

                // Página 1: Lista real de eventos (dinâmica via BLoC)
                const EventsListScreen(),

                // Página 2: Ingressos (sem o bottom bar próprio)
                _TicketsContent(),

                // Página 3: Perfil
                const ProfileScreen(showBottomNav: false),
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

class _HomeContentState extends State<_HomeContent>
    with AutomaticKeepAliveClientMixin {
  bool _isCalendarExpanded = false;
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, int> _eventCounts = {}; // índice de eventos por dia

  @override
  void initState() {
    super.initState();
    // Carregar eventos ao iniciar Home
    context.read<EventBloc>().add(const EventLoadAll());
  }

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
                // Upcoming Section
                _buildUpcomingSection(),
                // Highlights Section (Destaques)
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
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          List events = [];
          if (state is EventLoaded) {
            events = state.events;
          } else if (state is EventDetailLoaded) {
            events = [state.event];
          }

          // Reindexar mapa de contagem
          _eventCounts = {};
          for (final e in events) {
            final dateKey = DateTime(e.date.year, e.date.month, e.date.day);
            _eventCounts.update(dateKey, (v) => v + 1, ifAbsent: () => 1);
          }

          return Column(
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
          );
        },
      ),
    );
  }

  Widget _buildMonthControls() {
    final monthYear =
        '${_getMonthName(_selectedDate.month)} - ${_selectedDate.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.white,
              size: 18,
            ),
            onPressed: () {
              setState(() {
                if (!_isCalendarExpanded)
                  return; // não navegar meses quando colapsado
                // preserva o dia ao voltar mês; se não existir (ex: 31 -> fevereiro) ajusta para último dia
                final prevMonth = _selectedDate.month - 1;
                final year = _selectedDate.year + (prevMonth == 0 ? -1 : 0);
                final month = prevMonth == 0 ? 12 : prevMonth;
                final desiredDay = _selectedDate.day;
                final lastDayPrevMonth = DateTime(year, month + 1, 0).day;
                final day = desiredDay > lastDayPrevMonth
                    ? lastDayPrevMonth
                    : desiredDay;
                _selectedDate = DateTime(year, month, day);
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
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.white,
              size: 18,
            ),
            onPressed: () {
              setState(() {
                if (!_isCalendarExpanded)
                  return; // não navegar meses quando colapsado
                // preserva o dia ao avançar mês; ajusta para último dia se necessário
                final nextMonth = _selectedDate.month + 1;
                final year = _selectedDate.year + (nextMonth == 13 ? 1 : 0);
                final month = nextMonth == 13 ? 1 : nextMonth;
                final desiredDay = _selectedDate.day;
                final lastDayNextMonth = DateTime(year, month + 1, 0).day;
                final day = desiredDay > lastDayNextMonth
                    ? lastDayNextMonth
                    : desiredDay;
                _selectedDate = DateTime(year, month, day);
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
                // Ao colapsar, sempre retornar para mês/semana atual (hoje)
                if (!_isCalendarExpanded) {
                  final now = DateTime.now();
                  _selectedDate = DateTime(now.year, now.month, now.day);
                }
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
    final startWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 48, height: 48));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final isToday =
          day == DateTime.now().day &&
          _selectedDate.month == DateTime.now().month &&
          _selectedDate.year == DateTime.now().year;

      final dayDate = DateTime(_selectedDate.year, _selectedDate.month, day);
      final count = _eventCounts[dayDate] ?? 0;
      dayWidgets.add(_buildDayCell(day, isToday, count));
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
    // Ao estar colapsado, exibir a semana que contém a data selecionada (semana atual ao iniciar)
    if (!_isCalendarExpanded && weeks.isNotEmpty) {
      // Se mês visível for o atual, usar a semana do "hoje" sempre.
      final now = DateTime.now();
      final referenceDay =
          (_selectedDate.month == now.month && _selectedDate.year == now.year)
          ? now.day
          : _selectedDate.day;
      final selectedDayPosition = startWeekday + (referenceDay - 1);
      final weekIndex = selectedDayPosition ~/ 7;
      if (weekIndex >= 0 && weekIndex < weeks.length) {
        return weeks[weekIndex];
      }
      return weeks.first; // fallback
    }

    return Column(children: weeks);
  }

  Widget _buildDayCell(int day, bool isHighlighted, int count) {
    return Stack(
      children: [
        Container(
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
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHighlightsSection() {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        List<Event> events = [];
        if (state is EventLoaded) {
          events = state.events;
        }

        final now = DateTime.now();
        // futuros (>= hoje) ordenados por totalTickets desc
        final highlights =
            events
                .where(
                  (e) =>
                      !e.date.isBefore(DateTime(now.year, now.month, now.day)),
                )
                .toList()
              ..sort((a, b) => b.totalTickets.compareTo(a.totalTickets));
        final top = highlights.take(4).toList();

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
              if (top.isEmpty)
                const Text(
                  'Nenhum evento futuro encontrado.',
                  style: TextStyle(
                    fontFamily: 'SplineSans',
                    fontSize: 14,
                    color: Color(0xFFBA9C9C),
                  ),
                )
              else
                _buildEventGridFromEvents(top),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingSection() {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        List<Event> events = [];
        if (state is EventLoaded) events = state.events;
        final now = DateTime.now();
        final upcoming = events.where((e) => e.date.isAfter(now)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        final nextTwo = upcoming.take(2).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 8),
                child: Text(
                  'Próximos',
                  style: TextStyle(
                    fontFamily: 'SplineSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (nextTwo.isEmpty)
                const Text(
                  'Nenhum evento futuro encontrado.',
                  style: TextStyle(
                    fontFamily: 'SplineSans',
                    fontSize: 14,
                    color: Color(0xFFBA9C9C),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildEventCardFromEvent(nextTwo[0])),
                    const SizedBox(width: 12),
                    if (nextTwo.length > 1)
                      Expanded(child: _buildEventCardFromEvent(nextTwo[1]))
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventGridFromEvents(List<Event> events) {
    // organiza em linhas de dois
    List<Widget> rows = [];
    for (int i = 0; i < events.length; i += 2) {
      final first = events[i];
      final second = (i + 1 < events.length) ? events[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildEventCardFromEvent(first)),
              const SizedBox(width: 12),
              Expanded(
                child: second != null
                    ? _buildEventCardFromEvent(second)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildEventCardFromEvent(Event e) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.EVENT_DETAILS, arguments: e);
      },
      child: Column(
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
              child: const Icon(
                Icons.event,
                color: AppColors.textHint,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            e.name,
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
            e.description,
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
          const SizedBox(height: 4),
          Text(
            '${e.date.day.toString().padLeft(2, '0')}/${e.date.month.toString().padLeft(2, '0')} · ${e.location}',
            style: const TextStyle(
              fontFamily: 'SplineSans',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF6E6E6E),
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${e.totalTickets} ingressos',
            style: const TextStyle(
              fontFamily: 'SplineSans',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6E6E6E),
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

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

/// Conteúdo dos Ingressos (extraído da TicketsScreen)
class _TicketsContent extends StatefulWidget {
  @override
  State<_TicketsContent> createState() => _TicketsContentState();
}

class _TicketsContentState extends State<_TicketsContent>
    with AutomaticKeepAliveClientMixin {
  // Nenhum controle de abas interno aqui; usa bottom nav principal da MainScreen

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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: BlocBuilder<TicketBloc, TicketState>(
              builder: (context, state) {
                final authState = context.read<AuthBloc>().state;
                if (authState is! AuthAuthenticated) {
                  return _buildNotLogged();
                }
                if (state is TicketLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  );
                }
                if (state is TicketError) {
                  return _buildError(state.message);
                }
                if (state is TicketLoaded) {
                  if (state.tickets.isEmpty) {
                    return _buildEmpty();
                  }
                  final now = DateTime.now();
                  final upcoming = state.tickets
                      .where(
                        (t) => t.eventDate.isAfter(now) && t.status == 'active',
                      )
                      .toList();
                  final past = state.tickets
                      .where(
                        (t) =>
                            t.eventDate.isBefore(now) || t.status != 'active',
                      )
                      .toList();
                  return RefreshIndicator(
                    onRefresh: () async => _loadTickets(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (upcoming.isNotEmpty)
                            _buildSectionTitle('Próximos'),
                          ...upcoming.map(_buildTicketCard),
                          if (past.isNotEmpty) _buildSectionTitle('Passados'),
                          ...past.map(_buildTicketCard),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
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

  Widget _buildNotLogged() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.lock_outline, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            'Entre para ver seus ingressos',
            style: TextStyle(color: AppColors.textHint, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textHint)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTickets,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
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
            style: TextStyle(color: AppColors.textHint, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.HOME),
            child: const Text('Explorar Eventos'),
          ),
        ],
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(ticket.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusText(ticket.status),
                          style: TextStyle(
                            color: _statusColor(ticket.status),
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

  Color _statusColor(String status) {
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

  String _statusText(String status) {
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
}

/// Conteúdo de Eventos
// Removido _EventsPlaceholder estático e substituído por tela dinâmica `EventsListScreen`.
