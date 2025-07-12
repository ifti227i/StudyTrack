import 'package:flutter/material.dart';
import 'dart:ui';

class EventTextEditorDialog extends StatefulWidget {
  final String eventName;
  final String currentUser;
  final void Function(String details) onSave;

  const EventTextEditorDialog({
    super.key,
    required this.eventName,
    required this.currentUser,
    required this.onSave,
  });

  @override
  State<EventTextEditorDialog> createState() => _EventTextEditorDialogState();
}

class _EventTextEditorDialogState extends State<EventTextEditorDialog> {
  final TextEditingController _controller = TextEditingController();
  double _textBoxHeight = 120; // Add to your State class

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        Center(
          child: Dialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.eventName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Edited by (${widget.currentUser})',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.54),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: _textBoxHeight,
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: null,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter event details...',
                                hintStyle: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  _textBoxHeight += details.delta.dy;
                                  if (_textBoxHeight < 60) _textBoxHeight = 60;
                                  if (_textBoxHeight > 400) {
                                    _textBoxHeight = 400;
                                  }
                                });
                              },
                              child: Icon(
                                Icons.drag_handle,
                                color: Theme.of(
                                  context,
                                ).iconTheme.color?.withOpacity(0.54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              0,
                              29,
                              53,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () {
                            final text = _controller.text.trim();
                            if (text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Event text cannot be empty!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).pop();
                            widget.onSave(text);
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
