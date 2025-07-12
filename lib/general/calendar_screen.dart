import 'package:flutter/material.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'add_event_dialog.dart';
import 'event_text_editor_dialog.dart';
import 'event_model.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

class CalendarScreen extends StatefulWidget {
  final GoogleSignInAccount user;
  final VoidCallback? onLogout;
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;
  final String accountType;
  const CalendarScreen({
    super.key,
    required this.user,
    required this.accountType,
    this.onLogout,
    this.onThemeToggle,
    this.isDarkMode = true,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _currentIndex = 0;
  DateTime? _selectedDay;
  DateTime _calendarInitialDate = DateTime.now();

  String? _userName;

  // Example event data: Map<DateTime, List<String>>
  final Map<DateTime, List<String>> _events = {
    DateTime(2025, 7, 7): ['Quiz'],
    DateTime(2025, 7, 16): ['Assignment'],
    DateTime(2025, 7, 22): ['Presentation', 'Finalexam'],
    DateTime(2025, 7, 6): ['Midexam'],
    DateTime(2025, 8, 20): ['Assignment'],
  };

  // Unified event type to color mapping for consistency everywhere
  static const Map<String, Color> eventTypeColors = {
    'general': Colors.grey,
    'quiz': Colors.green,
    'assignment': Colors.blue,
    'presentation': Colors.deepPurple,
    'midexam': Colors.orange,
    'finalexam': Colors.purple,
  };

  // Backend API URL - COMMENTED OUT FOR FRONTEND DEVELOPMENT
  // static const String backendUrl = "http://192.168.56.1:8080/api/events";

  // Mock data for frontend development - REMOVE ALL DEFAULT TASKS
  final Map<DateTime, List<EventModel>> _mockEventCache = {};

  // Local cache of events: Map<DateTime, List<EventModel>>
  final Map<DateTime, List<EventModel>> _eventCache = {};

  // Placeholder user info (replace with actual user info from login/profile)
  // final String currentUser = 'John Doe';
  // final String email = 'john.doe@example.com';
  // final String accountType = 'Student';

  bool _isLoadingEvents = false;
  bool _isSavingEvent = false;
  String? _errorMessage;

  Timer? _pollingTimer;

  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  // Save event to backend - COMMENTED OUT FOR FRONTEND DEVELOPMENT
  Future<void> _saveEventToBackend(EventModel event) async {
    if (!mounted) return;
    setState(() {
      _isSavingEvent = true;
      _errorMessage = null;
    });

    // Mock save operation - simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // COMMENTED OUT BACKEND CALL
      /*
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final saved = EventModel.fromJson(jsonDecode(response.body));
        await _loadEventsForDate(saved.date);
      } else {
        throw Exception('Failed to save event');
      }
      */

      // Mock: Add to local cache
      final dateKey = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      if (!_mockEventCache.containsKey(dateKey)) {
        _mockEventCache[dateKey] = [];
      }
      _mockEventCache[dateKey]!.add(event);

      // Update UI
      _updateEventsFromMock();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to save event: $e';
      });
      rethrow;
    } finally {
      if (!mounted) return;
      setState(() {
        _isSavingEvent = false;
      });
    }
  }

  // Load events for a date - COMMENTED OUT FOR FRONTEND DEVELOPMENT
  Future<void> _loadEventsForDate(DateTime date) async {
    if (!mounted) return;
    setState(() {
      _isLoadingEvents = true;
      _errorMessage = null;
      _eventCache.clear();
      _events.clear();
    });

    // Mock load operation - simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // COMMENTED OUT BACKEND CALL
      /*
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http.get(Uri.parse('$backendUrl?date=$dateStr'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final events = data.map((e) => EventModel.fromJson(e)).toList();
        if (!mounted) return;
        setState(() {
          final dateKey = DateTime(date.year, date.month, date.day);
          _eventCache[dateKey] = events.cast<EventModel>();
          _events[dateKey] = events.map((e) => e.type).toList();
        });
      } else {
        throw Exception('Failed to load events');
      }
      */

      // Mock: Load from mock cache
      _updateEventsFromMock();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load events: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingEvents = false;
      });
    }
  }

  // Helper method to update events from mock data
  void _updateEventsFromMock() {
    if (!mounted) return;
    setState(() {
      _eventCache.clear();
      _events.clear();

      // Copy mock data to actual cache
      for (final entry in _mockEventCache.entries) {
        _eventCache[entry.key] = entry.value;
        _events[entry.key] = entry.value.map((e) => e.type).toList();
      }
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onAddEvent() async {
    if (_selectedDay == null) return;
    await showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        selectedDate: _selectedDay!,
        eventTypesWithColors: eventTypeColors,
        onEventTypeSelected: (type) async {
          await showDialog(
            context: context,
            builder: (context) => EventTextEditorDialog(
              eventName: type,
              currentUser: widget.user.displayName ?? '',
              onSave: (details) async {
                final event = EventModel(
                  date: DateTime(
                    _selectedDay!.year,
                    _selectedDay!.month,
                    _selectedDay!.day,
                  ),
                  type: type,
                  details: details,
                  editedBy: widget.user.displayName ?? '',
                );
                try {
                  await _saveEventToBackend(event);
                  _scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Event saved!')),
                  );
                } catch (e) {
                  _scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Failed to save event: $e')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        // Jump to current month
        _calendarInitialDate = DateTime.now();
      }
    });
  }

  // Polling disabled for frontend development
  void _startPolling() {
    // _pollingTimer?.cancel();
    // _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
    //   if (_selectedDay != null) {
    //     _loadEventsForDate(_selectedDay!);
    //   }
    // });
  }

  void _stopPolling() {
    // _pollingTimer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _userName = widget.user.displayName ?? 'User';
    _selectedDay = DateTime.now();
    _loadEventsForDate(_selectedDay!);
    _startPolling();
  }

  void _showEditProfileSheet() {
    final controller = TextEditingController(text: _userName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _userName = controller.text.trim().isEmpty
                          ? 'User'
                          : controller.text.trim();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Use _scaffoldMessenger here if needed, but avoid showing UI in dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String topBarText;
    if (_selectedDay != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selected = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );
      if (selected == today) {
        topBarText = 'Today';
      } else {
        topBarText =
            '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';
      }
    } else {
      topBarText = 'Today';
    }

    Widget bodyContent;
    if (_currentIndex == 0) {
      bodyContent = Stack(
        children: [
          PagedVerticalCalendar(
            minDate: DateTime(DateTime.now().year - 1, DateTime.now().month),
            maxDate: DateTime(DateTime.now().year + 1, DateTime.now().month),
            initialDate: _calendarInitialDate,
            invisibleMonthsThreshold: 1,
            monthBuilder: (context, month, year) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: Text(
                    '${_monthName(month)} $year',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              );
            },
            dayBuilder: (context, date) {
              final isToday = _isSameDay(date, DateTime.now());
              final isSelected =
                  _selectedDay != null && _isSameDay(date, _selectedDay!);
              final events = _getEventsForDay(date);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = date;
                  });
                  _loadEventsForDate(date);
                  _startPolling();
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blueGrey.withOpacity(0.3)
                        : isToday
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected || isToday
                              ? Colors.white
                              : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (events.isNotEmpty)
                        Positioned(
                          bottom: 6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: events.take(3).map((event) {
                              final type = event.toLowerCase();
                              Color color;
                              switch (type) {
                                case 'general':
                                  color = Colors.grey;
                                  break;
                                case 'quiz':
                                  color = eventTypeColors['quiz']!;
                                  break;
                                case 'assignment':
                                  color = eventTypeColors['assignment']!;
                                  break;
                                case 'presentation':
                                  color = eventTypeColors['presentation']!;
                                  break;
                                case 'midexam':
                                  color = eventTypeColors['midexam']!;
                                  break;
                                case 'finalexam':
                                  color = eventTypeColors['finalexam']!;
                                  break;
                                default:
                                  color = Colors.grey;
                              }
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.5,
                                ),
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isLoadingEvents || _isSavingEvent)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          if (_errorMessage != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.red[900],
                padding: const EdgeInsets.all(12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    } else if (_currentIndex == 1) {
      // Gather all upcoming events (today and future), sorted by date
      final now = DateTime.now();
      final allEvents =
          _eventCache.entries
              .expand((entry) => entry.value)
              .where(
                (event) => !event.date.isBefore(
                  DateTime(now.year, now.month, now.day),
                ),
              )
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      // Event type to icon and color mapping (only allowed types)
      IconData getIcon(String type) {
        switch (type.toLowerCase()) {
          case 'general':
            return Icons.label_important;
          case 'quiz':
            return Icons.help_outline;
          case 'assignment':
            return Icons.check_circle;
          case 'presentation':
            return Icons.mic;
          case 'midexam':
            return Icons.star;
          case 'finalexam':
            return Icons.school;
          default:
            return Icons.event;
        }
      }

      Color getColor(String type) {
        return eventTypeColors[type.toLowerCase()] ?? Colors.grey;
      }

      // Filter only allowed event types
      final filteredEvents = allEvents.where((event) {
        final t = event.type.toLowerCase();
        return t == 'general' ||
            t == 'quiz' ||
            t == 'assignment' ||
            t == 'presentation' ||
            t == 'midexam' ||
            t == 'finalexam';
      }).toList();
      // Sort so that 'general' events always come first
      filteredEvents.sort((a, b) {
        if (a.type.toLowerCase() == 'general' &&
            b.type.toLowerCase() != 'general') {
          return -1;
        }
        if (a.type.toLowerCase() != 'general' &&
            b.type.toLowerCase() == 'general') {
          return 1;
        }
        return a.date.compareTo(b.date);
      });

      bodyContent = Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: filteredEvents.isEmpty
                ? const Center(
                    child: Text(
                      'No upcoming tasks',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      final icon = getIcon(event.type);
                      final color = getColor(event.type);
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(icon, color: color),
                                            const SizedBox(width: 8),
                                            Text(
                                              event.type,
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.titleLarge?.color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          event.details,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            // Placeholder logic for author title
                                            // In a real app, this should come from event data
                                            _getAuthorTitle(event.editedBy),
                                            style: TextStyle(
                                              color: Colors.grey.withOpacity(
                                                0.5,
                                              ),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      color: Theme.of(context).iconTheme.color,
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: color, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.15),
                              child: Icon(icon, color: color, size: 28),
                            ),
                            title: Text(
                              event.type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Text(
                              event.details,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Text(
                              '${event.date.day}/${event.date.month}/${event.date.year}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    } else {
      // Profile tab UI
      bodyContent = SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with Google photo if available
            const SizedBox(height: 24),
            widget.user.photoUrl != null
                ? CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(widget.user.photoUrl!),
                  )
                : const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 64, color: Colors.white54),
                  ),
            const SizedBox(height: 16),
            Text(
              _userName ?? 'User',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@${widget.user.email}',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            // Add two icons (theme toggle and edit profile) under the email
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 28),
                  onPressed: _showEditProfileSheet,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Functional statistics card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Color(0xFF23232A),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_getUserTotalEvents()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total Events',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_getUserUpcomingEvents()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Upcoming',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Remove Status/Sections card and previous option buttons
            // Only keep the new options card below statistics
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              decoration: BoxDecoration(
                color: Color(0xFF23232A),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  // Only show Sections ListTile for Student and Teacher accounts
                  if (widget.accountType != 'Personal')
                    ListTile(
                      leading: const Icon(Icons.group, color: Colors.white),
                      title: const Text(
                        'Sections',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => _SectionRequestDialog(),
                        );
                      },
                    ),
                  // Remove Dark/Bright Mode and Edit Profile ListTiles
                ],
              ),
            ),
            // Remove the two option buttons (Section, Edit Profile) below the ListTiles options card, but keep the Logout button
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: widget.onLogout,
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _currentIndex == 2
              ? 'Profile'
              : _currentIndex == 1
              ? 'Events'
              : 'Today',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: Icon(
                Icons.add,
                size: 28,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: _selectedDay != null ? _onAddEvent : null,
              tooltip: 'Add Event',
            ),
        ],
      ),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Helper methods for statistics
  int _getUserTotalEvents() {
    int count = 0;
    for (final events in _eventCache.values) {
      count += events
          .where((e) => e.editedBy == (widget.user.displayName ?? ''))
          .length;
    }
    return count;
  }

  int _getUserUpcomingEvents() {
    final now = DateTime.now();
    int count = 0;
    for (final events in _eventCache.values) {
      count += events
          .where(
            (e) =>
                e.editedBy == (widget.user.displayName ?? '') &&
                e.date.isAfter(now),
          )
          .length;
    }
    return count;
  }

  String _getAuthorTitle(String editedBy) {
    // Example logic: you can expand this as needed
    if (editedBy.toLowerCase().contains('cr')) return 'CR';
    if (editedBy.toLowerCase().contains('co-cr')) return 'Co-CR';
    if (editedBy.toLowerCase().contains('teacher')) return 'Teacher';
    return 'Author';
  }
}

class _SectionRequestDialog extends StatefulWidget {
  @override
  State<_SectionRequestDialog> createState() => _SectionRequestDialogState();
}

class _SectionRequestDialogState extends State<_SectionRequestDialog> {
  // Mock user role and enrolled sections
  final String userRole = 'student'; // or 'teacher'
  final List<Map<String, String>> enrolledSections = [
    // For student: one section, for teacher: multiple
    // Uncomment one of the following for testing
    // {'dept': 'CSE', 'section': '66-C'}, // Student example
    {'dept': 'CSE', 'section': '66-C'},
    {'dept': 'EEE', 'section': '54-D'}, // Teacher example (multiple)
  ];

  // Mock data
  final List<Map<String, dynamic>> departments = [
    {'name': 'Computer Science & Engineering', 'short': 'CSE'},
    {'name': 'Electrical & Electronic Engineering', 'short': 'EEE'},
    {'name': 'Software Engineering', 'short': 'SEW'},
    {'name': 'English', 'short': 'ENG'},
    {'name': 'Civil Engineering', 'short': 'CE'},
    {'name': 'Physics', 'short': 'PHY'},
  ];
  final Map<String, List<String>> sectionsByDept = {
    'CSE': ['66-C', '66-D', '66-E', '66-F', '66-G'],
    'EEE': ['54-C', '54-D', '54-E', '54-F', '54-G'],
    'SEW': ['44-C', '44-D', '44-E', '44-F', '44-G'],
    'ENG': ['5-C', '5-D', '5-E', '5-F', '5-G'],
    'CE': ['4-C', '4-D', '4-E', '4-F', '4-G'],
    'PHY': ['71-C', '71-D', '71-E', '71-F', '71-G'],
  };

  String? selectedDeptShort;
  String? selectedSection;
  bool requestSent = false;

  @override
  Widget build(BuildContext context) {
    final hasSection = enrolledSections.isNotEmpty;
    return Dialog(
      backgroundColor: const Color(0xFF23232A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 340,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sections',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 24),
              if (hasSection)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23232A),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (final sec in enrolledSections)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '${sec['section']}, ${sec['dept']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (!hasSection) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedDeptShort,
                        dropdownColor: const Color(0xFF23232A),
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: departments
                            .map(
                              (dept) => DropdownMenuItem<String>(
                                value: dept['short'],
                                child: Text(
                                  dept['short'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDeptShort = value;
                            selectedSection = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSection,
                        dropdownColor: const Color(0xFF23232A),
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items:
                            (selectedDeptShort != null
                                    ? sectionsByDept[selectedDeptShort] ?? []
                                    : <String>[])
                                .map(
                                  (section) => DropdownMenuItem<String>(
                                    value: section,
                                    child: Text(
                                      section,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSection = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (selectedDeptShort != null && selectedSection != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23232A),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          '66-C, CSE, Student',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Enrolled Students: 50',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          'Enrolled Teachers: 5',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          'CR: John Doe',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          'Co-CR: Jane Smith',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: requestSent ? Colors.grey : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        (selectedDeptShort != null &&
                            selectedSection != null &&
                            !requestSent)
                        ? () {
                            setState(() {
                              requestSent = true;
                            });
                          }
                        : null,
                    child: Text(
                      requestSent ? 'Request Sent' : 'Send Request',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
