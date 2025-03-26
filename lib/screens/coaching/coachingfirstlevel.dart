// Import for the BackdropFilter

import 'package:fab/components/coaching/coachingfirstleveltile.dart';
import 'package:fab/screens/coaching/coachingscreenreveal.dart';
import 'package:fab/services/coaching_service.dart';
import 'package:flutter/material.dart';

class CoachingFirstLevel extends StatefulWidget {
  final String email;

  const CoachingFirstLevel({
    super.key,
    required this.email,
  });

  @override
  State<CoachingFirstLevel> createState() => _CoachingFirstLevelState();
}

class _CoachingFirstLevelState extends State<CoachingFirstLevel> {
  final CoachingService _coachingService = CoachingService();
  bool _isLoading = true;
  List<Map<String, dynamic>> coachingData = [];

  @override
  void initState() {
    super.initState();
    _fetchMainCoaching(); // Fetch data on widget load
  }

  Future<void> _fetchMainCoaching() async {
    coachingData = await _coachingService.getMainCoachings();
    setState(() {
      _isLoading = false; // Update UI after fetching data
    });
  }

  Color colorFromString(String colorString) {
    // Remove the '#' if it's there and parse the hex color code
    String hexColor = colorString.replaceAll('#', '');

    // Ensure the string has the correct length (6 digits)
    if (hexColor.length == 6) {
      // Parse the color string to an integer and return it as a Color
      return Color(
          int.parse('0xFF$hexColor')); // Adding 0xFF to indicate full opacity
    } else {
      throw FormatException('Invalid color string format');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Set tile height and padding dynamically based on screen size
    final double tileHeight = screenHeight * 0.19;
    final double tilePadding = screenWidth * 0.02;

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            )
          : CustomScrollView(
              slivers: [
                // SliverAppBar with title at the top
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: screenHeight * 0.25, // 25% of screen height
                  backgroundColor:
                      colorFromString("#022A67"), // AppBar background color
                  title: const Text(
                    "Coaching",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        Image.asset(
                          "assets/images/RoutinesList.png",
                          fit: BoxFit.cover,
                        ),
                        // Applying blur effect only on the lower part of the image
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: screenHeight *
                                0.1, // Height of the blurred edge
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  colorFromString("#022A67").withOpacity(0.7),
                                ],
                                stops: [0.6, 1.0], // Creates the fade effect
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Body content with blue background
                SliverToBoxAdapter(
                  child: Container(
                    color: colorFromString("#022A67"), // Page background color
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tilePadding,
                        vertical: tilePadding,
                      ),
                      child: Column(
                        children: List.generate(coachingData.length, (index) {
                          final training = coachingData[index];
                          return Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical:
                                        tilePadding), // Optional spacing between tiles
                                child: Material(
                                  elevation: 8, // Controls the shadow intensity
                                  borderRadius: BorderRadius.circular(
                                      10), // Matches the tile's border radius
                                  shadowColor: Colors.black.withOpacity(
                                      0.4), // Shadow color and transparency
                                  child: Container(
                                    height: tileHeight,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          10), // Ensure shadow follows rounded corners
                                    ),
                                    child: CoachingFirstTile(
                                      url: training['imageUrl'] ??
                                          'assets/images/default.jpg',
                                      title: training['title'] ?? 'No Title',
                                      color: training["color"] ??
                                          Colors.blue, // Default color
                                      subtitle: training["subtitle"] ?? '',
                                      onTap: () {
                                        // Navigate to the next screen on tile tap
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Coachingscreenreveal(
                                              email: widget.email,
                                              coachingSeriesId:
                                                  training["objectId"],
                                              coachingSeries: training,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //     height: tilePadding), // Spacing between tiles
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
