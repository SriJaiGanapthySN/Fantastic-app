import 'package:fab/screens/nacScreen.dart';
import 'package:fab/services/journey_service.dart';
import 'package:flutter/material.dart';

class Journeyplayscreen extends StatelessWidget {
  final String email;
  final Map<String, dynamic> data;

  const Journeyplayscreen({super.key, required this.email, required this.data});

  @override
  Widget build(BuildContext context) {
    final JourneyService journeyService = JourneyService();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Extract data from the passed 'data' map
    final String backgroundImage =
        data['bigImageUrl'] ?? 'https://via.placeholder.com/400';
    final String title = data['title'] ?? 'No Title';
    final String rawDescription =
        data['chapterDescription'] ?? 'No Description';
    final String description =
        rawDescription.replaceAll('{{NAME}}', 'Rudraksh');
    final String ctaColor = data['ctaColor'] ?? '#FFA500'; // Default to orange
    final String objId = data['objectId'];

    /// Converts Hex String to Color
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

    Future<void> updateJourney(String email) async {
      // Run the journey update logic in the background
      Future(() async {
        try {
          final data = await journeyService.fetchUnreleaseJourney(email);
          final userJourneys = await journeyService.fetchUserJourneys(email);

          if (data != null) {
            final String docId = data['objectId'];
            await journeyService.updateIsReleased(email, docId);
          }

          if (userJourneys.isNotEmpty) {
            final isDocIdPresent =
                userJourneys.any((journey) => journey['objectId'] == objId);

            if (isDocIdPresent) {
              await journeyService.updateIsReleased(email, objId);
              print(
                  'Journey with docId $objId is already present in userJourneys.');
            } else {
              await journeyService.addSkillTrack(objId, email);
              final skills = await journeyService.addSkills(objId, email);
              if (skills.isNotEmpty) {
                final goals =
                    await journeyService.addSkillLevel(skills, email);
                print('Skill levels added!');
                if (goals.isNotEmpty) {
                  await journeyService.addSkillGoals(goals, email);
                  print('Goals added!');
                } else {
                  print('No goals found to add.');
                }
              } else {
                print('No skills found to add levels.');
              }
            }
          }
        } catch (e) {
          print('Error updating journey: $e');
        }
      });

      // Navigate to the next screen immediately
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(
            email: email,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark overlay for better text visibility
          Container(
            height: screenHeight,
            width: screenWidth,
            color: Colors.black.withOpacity(0.4),
          ),

          // Content: Title, "In Which", Description
          Positioned(
            top: screenHeight * 0.20, // 20% from the top
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.12,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black54,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // "In which" text
                Text(
                  "In which",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.075,
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Description text
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.065,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Play Button
          Positioned(
            bottom: screenHeight * 0.1, // 10% from the bottom
            left: (screenWidth - screenWidth * 0.25) / 2, // Center horizontally
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: SizedBox(
                        height: 580,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/sample3.jpg',
                              height: 170,
                              width: 350,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Text(
                                'Rolling the dice randomly selects a ?',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Text(
                                'remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum .e ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 110),
                              child: Column(
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      await updateJourney(email);
                                    },
                                    child: Text(
                                      'SWITCH JOURNEY',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 36, 173, 173),
                                          fontSize: 20),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'DONT SWITCH',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 156, 149, 149),
                                          fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                print('Play button tapped!');
              },
              child: Container(
                height: screenWidth * 0.25,
                width: screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: colorFromString(ctaColor),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: screenWidth * 0.15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
