import 'package:codify/provider/streak_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class StreakDisplay extends StatefulWidget {
  const StreakDisplay({Key? key}) : super(key: key);

  @override
  State<StreakDisplay> createState() => _StreakDisplayState();
}

class _StreakDisplayState extends State<StreakDisplay>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final GlobalKey _streakDisplayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _showOverlay(BuildContext context) {
    if (_isOverlayVisible) return;

    final overlay = Overlay.of(context);

    final RenderBox? renderBox =
        _streakDisplayKey.currentContext?.findRenderObject() as RenderBox?;
    Offset? position;
    if (renderBox != null) {
      position = renderBox.localToGlobal(Offset.zero);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(children: [
        Positioned.fill(
            child: GestureDetector(
          onTap: () {
            _hideOverlay();
          },
          child: Container(color: Colors.transparent),
        )),
        Positioned(
          top: position?.dy ?? 0 + kToolbarHeight,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: _buildOverlayContent(context),
            ),
          ),
        ),
      ]),
    );

    overlay.insert(_overlayEntry!);
    _isOverlayVisible = true;
    _animationController.forward();
  }

  void _hideOverlay() {
    if (_overlayEntry != null && _isOverlayVisible) {
      _animationController.reverse().then((_) {
        _overlayEntry!.remove();
        _overlayEntry = null;
        _isOverlayVisible = false;
      });
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    final streakProvider = Provider.of<StreakProvider>(context, listen: false);

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Current Streak",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _hideOverlay();
                  },
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  streakProvider.streak?.currentStreak != null &&
                          streakProvider.streak!.currentStreak > 0
                      ? Icons.local_fire_department
                      : Icons.local_fire_department_outlined,
                  color: streakProvider.streak?.currentStreak != null &&
                          streakProvider.streak!.currentStreak > 0
                      ? Colors.orange
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  "${streakProvider.streak?.currentStreak ?? 0} days",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Progress Calendar",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            _buildCalendar(streakProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(StreakProvider streakProvider) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: DateTime.now(),
      selectedDayPredicate: (day) => false,
      calendarFormat: CalendarFormat.month,
      eventLoader: (day) {
        return streakProvider.getEventsForDay(day);
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            return Positioned(
              child: Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return const SizedBox();
        },
        dowBuilder: (context, day) {
          return Center(
            child: Text(
              DateFormat('EEE').format(day),
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          );
        },
        defaultBuilder: (context, date, events) {
          return Center(
            child: Text(
              date.day.toString(),
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          );
        },
        todayBuilder: (context, date, events) {
          bool isStreakDay = streakProvider.getEventsForDay(date).isNotEmpty;
          return Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isStreakDay ? Colors.orange : Colors.blue[200],
              ),
              padding: const EdgeInsets.all(3),
              child: Text(
                date.day.toString(),
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideOverlay();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streakProvider = Provider.of<StreakProvider>(context);

    return GestureDetector(
      key: _streakDisplayKey,
      onTap: () {
        if (_isOverlayVisible) {
          _hideOverlay();
        } else {
          _showOverlay(context);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Icon(
                streakProvider.streak?.currentStreak != null &&
                        streakProvider.streak!.currentStreak > 0
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                color: streakProvider.streak?.currentStreak != null &&
                        streakProvider.streak!.currentStreak > 0
                    ? Colors.orange
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                "${streakProvider.streak?.currentStreak ?? 0} days",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
