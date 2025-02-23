// For handling asynchronous operations.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fab/services/task_services.dart';

class Routinelist extends StatefulWidget {
  Routinelist({super.key, required this.habit, required this.email});

  List<Map<String, dynamic>> habit;
  final String email;

  @override
  State<Routinelist> createState() => _RoutinelistState();
}

class _RoutinelistState extends State<Routinelist> {
  Color colorFromString(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('0xFF$hexColor'));
      }
    } catch (e) {
      print("Invalid color string: $e");
    }
    return Colors.orange; // Default to orange on error
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView(
        children: widget.habit.map<Widget>((document) {
          bool isChecked = document['isCompleted'] ?? false;
          String iconPath = document['iconUrl'] ?? '';

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SvgPicture.network(
                          iconPath,
                          width: 24,
                          height: 24,
                          color: isChecked
                              ? colorFromString(document["color"])
                              : Colors.black,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            document['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isChecked,
                    activeColor: Colors.green,
                    onChanged: (bool? value) async {
                      if (value != null) {
                        // Optimistically update the UI
                        setState(() {
                          document['isCompleted'] = value;
                        });

                        // Update the backend asynchronously
                        try {
                          await TaskServices().updateHabitStatus(
                              value, document['objectId'], widget.email);
                        } catch (e) {
                          // Revert the change if the backend update fails
                          setState(() {
                            document['isCompleted'] = !value;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update habit: $e'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        }).toList(),
      ),
    );
  }
}