import 'package:flutter/material.dart';

class TeacherProfileScreen extends StatefulWidget {
  final String email;
  final VoidCallback onLogout;

  const TeacherProfileScreen({
    super.key,
    required this.email,
    required this.onLogout,
  });

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  String _userName = 'Teacher';
  final List<Map<String, String>> _sections = [
    {'dept': 'CSE', 'section': '66-C'},
    {'dept': 'EEE', 'section': '54-D'},
  ]; // Mock: teacher manages multiple sections

  final int _totalEvents = 12; // Mock data
  final int _upcomingEvents = 3; // Mock data

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
                          ? 'Teacher'
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

  void _showSectionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Your Sections',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 300,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _sections.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white24),
            itemBuilder: (context, idx) {
              final sec = _sections[idx];
              return ListTile(
                leading: const Icon(Icons.class_, color: Colors.white),
                title: Text(
                  '${sec['dept']} - ${sec['section']}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
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
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _showEditProfileSheet,
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 64, color: Colors.white54),
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
              '@${widget.email}',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
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
                    onTap: _showSectionsDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatCard('Total Events', _totalEvents),
                const SizedBox(width: 24),
                _buildStatCard('Upcoming', _upcomingEvents),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.onLogout,
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
