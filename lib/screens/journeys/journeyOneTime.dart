import 'package:fab/models/skill.dart';
import 'package:fab/models/skillTrack.dart';
import 'package:fab/screens/journeys/journeysecondlevel.dart';
import 'package:fab/services/journey_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class JourneyOneTime extends StatelessWidget {
  final JourneyService _journeyService = JourneyService();

  final Map oneTimeData;
  final Skill skill;
  final String email;
  final skillTrack skilltrack;

  JourneyOneTime({
    super.key,
    required this.oneTimeData,
    required this.skill,
    required this.email,
    required this.skilltrack,
  });

  Future<String> fetchContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body; // Return the raw HTML content
      } else {
        return 'Failed to load content';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Color colorFromString(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('0xFF$hexColor'));
      }
    } catch (e) {
      // Default to black if color string is invalid
      return Colors.black;
    }
    throw FormatException('Invalid color string format');
  }

  void markComplete() {}

  @override
  Widget build(BuildContext context) {
    print(oneTimeData);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorFromString(skill.color),
        title: Text(
          'Action',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.06, // Responsive font size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align to start (left)
              children: [
                Container(
                  height: screenHeight * 0.3, // Responsive height
                  color: colorFromString(skill.color),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth *
                            0.04), // Add padding for left alignment
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Vertically center the content
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Left align the content title
                      children: [
                        Text(
                          oneTimeData['contentTitle'] ?? 'No Title',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                screenWidth * 0.07, // Responsive font size
                          ),
                        ),
                        SizedBox(
                            height: screenHeight *
                                0.02), // Responsive spacing between title and next widget
                        // Check if the task is completed
                        if (oneTimeData["isCompleted"])
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Center the "COMPLETED" text horizontally
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Centering the icon and text
                                children: [
                                  Icon(
                                    Icons.check_circle, // Tick icon
                                    color: Colors.white,
                                    size: screenWidth *
                                        0.06, // Responsive icon size
                                  ),
                                  SizedBox(
                                      width: screenWidth *
                                          0.02), // Space between the icon and the text
                                  Text(
                                    'Action Completed!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth *
                                          0.05, // Responsive font size
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          // If not completed, show the button
                          Container(
                            width: double
                                .infinity, // Button stretches from left to right
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth *
                                    0.04), // Same padding as content title
                            child: ElevatedButton(
                              onPressed: () {
                                // Define the button action here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorFromString(skill
                                    .color), // Same background color as content title
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight *
                                        0.02), // Increased vertical padding for button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15), // Rounded corners for the button
                                ),
                                elevation:
                                    10, // Add elevation for the elevated effect
                                shadowColor: Colors.black.withOpacity(
                                    0.8), // Shadow color for better depth
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center the content horizontally
                                children: [
                                  Icon(
                                    Icons
                                        .touch_app, // You can replace this with any icon you prefer
                                    color: Colors.white,
                                    size: screenWidth *
                                        0.06, // Responsive icon size
                                  ),
                                  SizedBox(
                                      width: screenWidth *
                                          0.02), // Space between the icon and the text
                                  Text(
                                    'REMIND ME TO DO THIS', // Button label
                                    style: TextStyle(
                                      fontSize: screenWidth *
                                          0.05, // Responsive font size
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Responsive spacing
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Text(
                    "Why?",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: colorFromString(skill.color),
                    ),
                    textAlign: TextAlign.left, // Ensure left alignment
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: FutureBuilder<String>(
                    future: fetchContent(oneTimeData['contentUrl'] ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return Html(
                          data: snapshot.data ?? '<p>No content available</p>',
                          style: {
                            "html": Style(
                              fontSize: FontSize(screenWidth * 0.05),
                              lineHeight: LineHeight(1.6),
                              color: Colors.black87,
                            ),
                            "p": Style(
                              fontSize: FontSize(screenWidth * 0.05),
                              color: Colors.black87,
                              textAlign:
                                  TextAlign.left, // Ensure left alignment
                            ),
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(
                    height: screenHeight * 0.1), // Responsive bottom spacing
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 10, // Set elevation for shadow
              shadowColor:
                  Colors.black.withOpacity(0.6), // Shadow color and opacity
              child: Container(
                color:
                    Colors.grey.shade300, // Grey background for the bottom bar
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight *
                      0.02, // Adjust vertical padding for responsiveness
                  horizontal: screenWidth * 0.04, // Adjust horizontal padding
                ),
                child: Container(
                  width: double.infinity, // Stretch button from left to right
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth * 0.04, // Same padding as other button
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Update the isCompleted value
                      oneTimeData["isCompleted"] = true;

                      // Call the updateOneTime function from the service
                      bool isUpdated = await _journeyService.updateOneTime(
                          true,
                          oneTimeData["objectId"],
                          email,
                          skill.objectId,
                          skilltrack.objectId);

                      if (isUpdated) {
                        // If the update is successful, navigate to the next screen
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => Journeysecondlevel(
                        //       skill: skill,
                        //       email: email,
                        //       skilltrack: skilltrack,
                        //     ),
                        //   ),
                        // );
                        int count = 0;
                        Navigator.popUntil(
                          context,
                          (route) {
                            count++;
                            return count > 1; // Stop popping after 2 routes
                          },
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Journeysecondlevel(
                              skill: skill,
                              email: email,
                              skilltrack: skilltrack,
                            ),
                          ),
                        );
                      } else {
                        // Handle failure case if needed
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Failed to update task. Please try again.'),
                        ));
                      }
                      // Define the button action here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 13, 173, 32), // Button color
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight *
                              0.02), // Increased vertical padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                      ),
                      elevation: 10, // Add elevation for shadow effect
                      shadowColor:
                          Colors.black.withOpacity(0.8), // Shadow color
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center the content horizontally
                      children: [
                        Icon(
                          Icons.arrow_forward, // Icon for the button
                          color: Colors.white,
                          size: screenWidth * 0.06, // Responsive icon size
                        ),
                        SizedBox(
                            width: screenWidth *
                                0.02), // Space between icon and text
                        Text(
                          'Done! What Next', // Button label
                          style: TextStyle(
                            fontSize:
                                screenWidth * 0.05, // Responsive font size
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
