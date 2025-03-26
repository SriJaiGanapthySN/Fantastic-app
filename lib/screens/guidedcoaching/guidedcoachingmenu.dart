import 'dart:ui';

import 'package:fab/screens/guidedcoaching/guidedcoachingsecondlevel.dart';
import 'package:fab/services/guided_activities.dart';
import 'package:flutter/material.dart';

class Guidedcoachingmenu extends StatefulWidget {
  final String email;

  const Guidedcoachingmenu({super.key, required this.email});

  @override
  State<Guidedcoachingmenu> createState() => _GuidedcoachingmenuState();
}

class _GuidedcoachingmenuState extends State<Guidedcoachingmenu> {
  final GuidedActivities _guidedActivities = GuidedActivities();
  List<Map<String, dynamic>> categoryData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch data on widget load
  }

  Future<void> _fetchCategories() async {
    categoryData = await _guidedActivities.fetchCategories();
    setState(() {
      _isLoading = false; // Update UI after fetching data
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamically calculate the crossAxisCount based on screen width

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                margin: EdgeInsets.only(
                  top: screenHeight * 0.1,
                  left: screenWidth * 0.05,
                ),
                child: Row(
                  children: [
                    Text(
                      "Guided \nActivites",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 30),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: screenHeight * 0.26,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color.fromARGB(255, 209, 149, 59)
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.1), // Light overlay
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Explore Learning Paths",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Choose a path to begin",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    width: categoryData.length *
                                        (screenWidth * 0.462),
                                    height: screenHeight * 0.16,
                                    child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.all(5),
                                      itemCount: categoryData.length,
                                      itemBuilder: (context, index) {
                                        final category = categoryData[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Guidedcoachingsecondlevel(
                                                    email: widget.email,
                                                    category: category,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                // Background Image Container
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds:
                                                          300), // Animation duration
                                                  curve: Curves
                                                      .easeInOut, // Smooth animation curve
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal:
                                                          screenWidth * 0),
                                                  padding: EdgeInsets.all(
                                                      screenWidth * 0.03),
                                                  height: screenHeight * 0.1,
                                                  width: screenWidth * 0.4,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors
                                                        .blue, // Null to show image
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          category['imageUrl']),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),

                                                // Overlaying Title, Subtitle, Info Icon, and Percentage Text
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: screenHeight * 0.01),
                                                  child: Text(
                                                    category['name'],
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize:
                                                          screenWidth * 0.035,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
    );
  }
}
