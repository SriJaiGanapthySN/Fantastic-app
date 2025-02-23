import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fab/models/skill.dart';
import 'package:fab/models/skillTrack.dart';
import 'package:fab/screens/journeys/journeysecondlevel.dart';
import 'package:fab/services/journey_service.dart';
import 'package:http/http.dart' as http;

class JourneyLetter extends StatelessWidget {
  final Map letterData;
  final Skill skill;
  final String email;
  final skillTrack skilltrack;

  JourneyLetter({
    super.key,
    required this.letterData,
    required this.skill,
    required this.skilltrack,
    required this.email,
  });

  final JourneyService _journeyService = JourneyService();

  // Fetch content from URL
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
      print("Invalid color string: $e");
    }
    return Colors.orange; // Default to orange on error
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorFromString(skill.color),
        elevation: 4,
        title: Text(
          'Journey Letter',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.network(
              letterData['headlineImageUrl'],
              fit: BoxFit.cover,
              height: screenHeight * 0.25, // Adjust this value as needed
              width: screenWidth,
            ),
          ),
          // Content Box (Starts from top, overlapping the image)
          // Content Box (Starts from top, overlapping the image)
          Positioned(
            top:
                130, // This ensures the content box starts at the top of the screen
            left: 0,
            right: 0,
            bottom: 0, // Stretches till the bottom
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: SingleChildScrollView(
                  // Make the content scrollable
                  child: FutureBuilder<String>(
                    future: fetchContent(letterData['contentUrl']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.red,
                          ),
                        );
                      } else {
                        return Html(
                          data: snapshot.data ?? '<p>No content available</p>',
                          style: {
                            "html": Style(
                              fontSize: FontSize(screenWidth * 0.045),
                              lineHeight: LineHeight(1.6),
                              color: Colors.black87,
                              textAlign: TextAlign.justify,
                            ),
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey.shade300,
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.04,
        ),
        child: ElevatedButton(
          onPressed: () async {
            letterData["isCompleted"] = true;

            // Call update service
            bool isUpdated = await _journeyService.updateMotivator(
                true,
                letterData["objectId"],
                email,
                skill.objectId,
                skilltrack.objectId);

            if (isUpdated) {
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

              int count = 0; // Counter to track popped routes
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update task. Please try again.'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
            ),
            elevation: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Done! What Next',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:fab/models/skill.dart';
// import 'package:fab/models/skillTrack.dart';
// import 'package:fab/screens/journeysecondlevel.dart';
// import 'package:fab/services/journey_service.dart';
// import 'package:http/http.dart' as http;

// class JourneyLetter extends StatelessWidget {
//   final Map letterData;
//   final Skill skill;
//   final String email;
//   final skillTrack skilltrack;

//   JourneyLetter({
//     Key? key,
//     required this.letterData,
//     required this.skill,
//     required this.skilltrack,
//     required this.email,
//   }) : super(key: key);

//   final JourneyService _journeyService = JourneyService();

//   // Fetch content from URL
//   Future<String> fetchContent(String url) async {
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         return response.body; // Return the raw HTML content
//       } else {
//         return 'Failed to load content';
//       }
//     } catch (e) {
//       return 'Error: $e';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         elevation: 4,
//         title: Text(
//           'Journey Letter',
//           style: TextStyle(
//             fontSize: screenWidth * 0.05,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           // Image
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Image.network(
//               letterData['headlineImageUrl'],
//               fit: BoxFit.cover,
//               height: screenHeight * 0.25, // Adjust this value as needed
//               width: screenWidth,
//             ),
//           ),
//           // Content Box (Starts from top, overlapping the image)
//           Positioned(
//             top: screenHeight * 0.25, // Content box starts right after the image
//             left: 0,
//             right: 0,
//             bottom: 0, // Stretches till the bottom
//             child: Container(
//               margin: EdgeInsets.symmetric(
//                 horizontal: screenWidth * 0.05,
//                 vertical: screenHeight * 0.02,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(screenWidth * 0.04),
//                 child: SingleChildScrollView( // Make content scrollable if necessary
//                   child: FutureBuilder<String>(
//                     future: fetchContent(letterData['contentUrl']),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       } else if (snapshot.hasError) {
//                         return Text(
//                           'Error: ${snapshot.error}',
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.04,
//                             color: Colors.red,
//                           ),
//                         );
//                       } else {
//                         return Html(
//                           data: snapshot.data ?? '<p>No content available</p>',
//                           style: {
//                             "html": Style(
//                               fontSize: FontSize(screenWidth * 0.045),
//                               lineHeight: LineHeight(1.6),
//                               color: Colors.black87,
//                               textAlign: TextAlign.justify,
//                             ),
//                           },
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         color: Colors.grey.shade300,
//         padding: EdgeInsets.symmetric(
//           vertical: screenHeight * 0.02,
//           horizontal: screenWidth * 0.04,
//         ),
//         child: ElevatedButton(
//           onPressed: () async {
//             letterData["isCompleted"] = true;

//             // Call update service
//             bool isUpdated = await _journeyService.updateMotivator(
//                 true, letterData["objectId"], email);

//             if (isUpdated) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => Journeysecondlevel(
//                     skill: skill,
//                     email: email,
//                     skilltrack: skilltrack,
//                   ),
//                 ),
//               );
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Failed to update task. Please try again.'),
//                 ),
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             padding: EdgeInsets.symmetric(
//               vertical: screenHeight * 0.02,
//             ),
//             elevation: 10,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.arrow_forward,
//                 color: Colors.white,
//                 size: screenWidth * 0.06,
//               ),
//               SizedBox(width: screenWidth * 0.02),
//               Text(
//                 'Done! What Next',
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.05,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }