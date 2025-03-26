// import 'package:flutter/material.dart';
// import 'package:fab/services/task_services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class Addrotinelistscreen extends StatefulWidget {
//   final List<Map<String, dynamic>> habits;
//   final List<Map<String, dynamic>> updateHabits;
//   final String email;
//   final VoidCallback onHabitUpdate;

//   const Addrotinelistscreen(
//       {super.key,
//       required this.habits,
//       required this.updateHabits,
//       required this.email,
//       required this.onHabitUpdate});

//   @override
//   State<Addrotinelistscreen> createState() => _AddrotinelistscreenState();
// }

// class _AddrotinelistscreenState extends State<Addrotinelistscreen> {
//   int taskCount = 0; // Variable to store habit count
//   List<Map<String, dynamic>> sublist = []; // Sublist to store user habits

//   // Method to fetch the task count
//   Future<void> updateTaskCount() async {
//     int count = await TaskServices().getTotalUserHabits(widget.email);
//     setState(() {
//       taskCount = count;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     updateTaskCount(); // Initial task count fetch
//     // setState(() {
//     //   sublist=widget.updateHabits;
//     // });
//     TaskServices().getUserHabits(widget.email).then((userHabits) {
//       setState(() {
//         sublist = userHabits;
//       });
//     });
//   }

//   // Future to get habits data
//   Future<List<Map<String, dynamic>>> getData() async {
//     try {
//       // Fetching the habits data
//       return await TaskServices().getHabits();
//     } catch (e) {
//       print('Error fetching habits: $e');
//       return [];
//     }
//   }

//   // Method to check if a habit is already added by the user
//   bool isHabitAdded(String habitId) {
//     return sublist.any((habit) => habit['objectId'] == habitId);
//   }

//   // Method to toggle habit (add/remove)
//   // void toggleHabit(String habitId) {
//   //   if (isHabitAdded(habitId)) {
//   //     // Remove habit logic
//   //     TaskServices().removeHabit(habitId,widget.email);
//   //     setState(() {
//   //       sublist.removeWhere((habit) => habit['objectId'] == habitId);
//   //       taskCount= sublist.length;

//   //     });
//   //     widget.onHabitUpdate();
//   //   } else {
//   //     // Add habit logic
//   //     TaskServices().addHabits(widget.email, habitId);
//   //     setState(() {
//   //       sublist.add({'objectId': habitId});
//   //       taskCount= sublist.length;
//   //     });
//   //   }
//   // }

//   void toggleHabit(String habitId) {
//     if (isHabitAdded(habitId)) {
//       // Optimistically update the UI by removing the habit immediately
//       setState(() {
//         sublist.removeWhere((habit) => habit['objectId'] == habitId);
//         taskCount = sublist.length;
//       });

//       // Perform the async task in the background
//       TaskServices().removeHabit(habitId, widget.email).then((_) {
//         widget.onHabitUpdate(); // Update parent widget
//       }).catchError((error) {
//         // Revert UI changes if the async task fails
//         setState(() {
//           sublist.add({'objectId': habitId});
//           taskCount = sublist.length;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to remove habit: $error')),
//         );
//       });
//     } else {
//       // Optimistically update the UI by adding the habit immediately
//       setState(() {
//         sublist.add({'objectId': habitId});
//         taskCount = sublist.length;
//       });

//       // Perform the async task in the background
//       TaskServices().addHabits(widget.email, habitId).then((_) {
//         // Optionally handle success (e.g., call widget.onHabitUpdate())
//       }).catchError((error) {
//         // Revert UI changes if the async task fails
//         setState(() {
//           sublist.removeWhere((habit) => habit['objectId'] == habitId);
//           taskCount = sublist.length;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add habit: $error')),
//         );
//       });
//     }
//   }

//   Color colorFromString(String colorString) {
//     try {
//       String hexColor = colorString.replaceAll('#', '');
//       if (hexColor.length == 6) {
//         return Color(int.parse('0xFF$hexColor'));
//       }
//     } catch (e) {
//       print("Invalid color string: $e");
//     }
//     return Colors.orange; // Default to orange on error
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Row(
//               children: [
//                 const Icon(
//                   Icons.dashboard_sharp,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(width: 40),
//                 Text(
//                   '$taskCount habits', // Displaying the updated habit count
//                   style: const TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             const Row(
//               children: [
//                 Icon(Icons.alarm, size: 32, color: Colors.white),
//                 SizedBox(width: 40),
//                 Text("None",
//                     style: TextStyle(color: Colors.white, fontSize: 18)),
//               ],
//             ),
//           ],
//         ),
//         toolbarHeight: 166,
//         flexibleSpace: Stack(
//           children: [
//             const Image(
//               image: AssetImage('assets/images/RoutinesList.png'),
//               width: double.infinity,
//               fit: BoxFit.fill,
//             ),
//             Container(
//               color: Colors.black.withOpacity(0.2),
//               width: double.infinity,
//               height: double.infinity,
//             ),
//           ],
//         ),
//         backgroundColor: Colors.transparent,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: getData(), // Fetching the habits data
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//             return ListView(
//               children: snapshot.data!.map<Widget>((document) {
//                 String habitId = document['objectId']; // Habit ID
//                 String iconPath = document['iconUrl'] ?? '';
//                 bool isAdded = isHabitAdded(habitId);

//                 return Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           SvgPicture.network(
//                             iconPath,
//                             width: 24,
//                             height: 24,
//                             color: isAdded
//                                 ? colorFromString(document["color"])
//                                 : Colors.grey,
//                           ),
//                           const SizedBox(width: 20),
//                           Expanded(
//                               child: Text(document['name'],
//                                   textAlign: TextAlign.start)),
//                           TextButton(
//                             onPressed: () {
//                               toggleHabit(habitId);
//                             },
//                             child: Text(
//                               isAdded ? 'REMOVE' : 'ADD',
//                               style: TextStyle(
//                                 color: isAdded ? Colors.red : Colors.green,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             );
//           } else {
//             return const Center(child: Text('No habits found.'));
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fab/services/task_services.dart';

class Addrotinelistscreen extends StatefulWidget {
  final List<Map<String, dynamic>> habits;
  final List<Map<String, dynamic>> updateHabits;
  final String email;
  final VoidCallback onHabitUpdate;

  const Addrotinelistscreen({
    super.key,
    required this.habits,
    required this.updateHabits,
    required this.email,
    required this.onHabitUpdate,
  });

  @override
  State<Addrotinelistscreen> createState() => _AddRoutineListScreenState();
}

class _AddRoutineListScreenState extends State<Addrotinelistscreen> {
  int taskCount = 0; // Total habits added by the user
  List<Map<String, dynamic>> allHabits = []; // All habits from the database
  List<Map<String, dynamic>> sublist = []; // Habits added by the user

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data on initialization
  }

  // Fetch all habits and user habits
  Future<void> fetchData() async {
    try {
      final habits = await TaskServices().getHabits(); // Get all habits
      final userHabits =
          await TaskServices().getUserHabits(widget.email); // Get user habits

      setState(() {
        allHabits = habits;
        sublist = userHabits;
        taskCount = userHabits.length; // Update task count
      });
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  // Check if a habit is added by the user
  bool isHabitAdded(String habitId) {
    return sublist.any((habit) => habit['objectId'] == habitId);
  }

  // Toggle habit addition/removal
  void toggleHabit(String habitId) {
    if (isHabitAdded(habitId)) {
      // Remove habit
      setState(() {
        sublist.removeWhere((habit) => habit['objectId'] == habitId);
        taskCount = sublist.length;
      });

      TaskServices().removeHabit(habitId, widget.email).then((_) {
        widget.onHabitUpdate();
      }).catchError((error) {
        setState(() {
          sublist.add({'objectId': habitId});
          taskCount = sublist.length;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove habit: $error')),
        );
      });
    } else {
      // Add habit
      setState(() {
        sublist.add({'objectId': habitId});
        taskCount = sublist.length;
      });

      TaskServices().addHabits(widget.email, habitId).then((_) {
        widget.onHabitUpdate();
      }).catchError((error) {
        setState(() {
          sublist.removeWhere((habit) => habit['objectId'] == habitId);
          taskCount = sublist.length;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add habit: $error')),
        );
      });
    }
  }

  // Convert string to color
  Color colorFromString(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('0xFF$hexColor'));
      }
    } catch (e) {
      print("Invalid color string: $e");
    }
    return Colors.orange; // Default color
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const Icon(
                  Icons.dashboard_sharp,
                  color: Colors.white,
                ),
                const SizedBox(width: 40),
                Text(
                  '$taskCount habits', // Displaying the updated habit count
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.alarm, size: 32, color: Colors.white),
                SizedBox(width: 40),
                Text("None",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ],
        ),
        toolbarHeight: 166,
        flexibleSpace: Stack(
          children: [
            const Image(
              image: AssetImage('assets/images/RoutinesList.png'),
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              width: double.infinity,
              height: double.infinity,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: allHabits.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allHabits.length,
              itemBuilder: (context, index) {
                final habit = allHabits[index];
                final habitId = habit['objectId'];
                final iconPath = habit['iconUrl'] ?? '';
                final isAdded = isHabitAdded(habitId);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SvgPicture.network(
                              iconPath,
                              width: 24,
                              height: 24,
                              color: isAdded
                                  ? colorFromString(habit['color'])
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 20),
                            // Text(habit['name']),
                            Expanded(
                              child: Text(
                                habit['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            // Expanded(
                            //     child: Text(habit['name'],
                            //         textAlign: TextAlign.start)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => toggleHabit(habitId),
                        child: Text(
                          isAdded ? 'REMOVE' : 'ADD',
                          style: TextStyle(
                            color: isAdded ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
