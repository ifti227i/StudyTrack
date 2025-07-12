import 'package:flutter/material.dart';

class StudentProfileScreen extends StatefulWidget {
  final String email;
  final VoidCallback onLogout;

  const StudentProfileScreen({
    super.key,
    required this.email,
    required this.onLogout,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String _userName = 'Student';
  String? _section;
  final bool _isCR = false;
  final bool _isCoCR = false;
  bool _requestSent = false;
  bool _autoJoined = false;
  int _sectionCount = 0; // Simulate section size for demo

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
                          ? 'Student'
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

  void _showSectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Join Section'),
        content: _section == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _section,
                    items: ['CSE-66C', 'EEE-54D', 'PHY-71C']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _section = val;
                        _sectionCount = 20; // Simulate section size
                        _autoJoined = _sectionCount < 25;
                        _requestSent = !_autoJoined;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Section'),
                  ),
                  const SizedBox(height: 16),
                  if (_section != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _autoJoined
                            ? () {
                                setState(() {
                                  _section = _section;
                                });
                                Navigator.of(context).pop();
                              }
                            : _requestSent
                            ? null
                            : () {
                                setState(() {
                                  _requestSent = true;
                                });
                                Navigator.of(context).pop();
                              },
                        child: Text(
                          _autoJoined
                              ? 'Join Now'
                              : _requestSent
                              ? 'Request Sent'
                              : 'Send Request',
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Joined: $_section'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _section = null;
                        _requestSent = false;
                        _autoJoined = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Leave Section'),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.blue.shade700,
              child: Icon(Icons.person, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.email,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF23232A),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '12',
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
                        '3',
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
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              decoration: BoxDecoration(
                color: const Color(0xFF23232A),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.group, color: Colors.white),
                    title: const Text(
                      'Sections',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onTap: _showSectionDialog,
                  ),
                ],
              ),
            ),
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
      ),
    );
  }
}
