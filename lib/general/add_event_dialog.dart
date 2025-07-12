import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class AddEventDialog extends StatelessWidget {
  final DateTime selectedDate;
  final Map<String, Color> eventTypesWithColors;
  final void Function(String eventType) onEventTypeSelected;

  const AddEventDialog({
    super.key,
    required this.selectedDate,
    required this.eventTypesWithColors,
    required this.onEventTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    String? dropdownValue;
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
              horizontal: 24,
              vertical: 24,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32), // For symmetry
                      Expanded(
                        child: Text(
                          'Add Event',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).iconTheme.color,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DateFormat('EEEE, MMMM d').format(selectedDate),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  StatefulBuilder(
                    builder: (context, setState) {
                      // Add 'general' to the event types
                      final eventTypes = [
                        'general',
                        ...eventTypesWithColors.keys.where(
                          (k) => k != 'general',
                        ),
                      ];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: dropdownValue,
                            isExpanded: true,
                            hint: const Text(
                              'Select event type',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                              ),
                            ),
                            dropdownColor: Colors.black,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            items: eventTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: type == 'general'
                                            ? Colors.grey
                                            : eventTypesWithColors[type],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      type,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                Navigator.of(context).pop();
                                onEventTypeSelected(value);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
