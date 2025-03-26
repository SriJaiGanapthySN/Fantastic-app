import 'package:fab/components/discover/custombuttondiscover.dart';
import 'package:fab/components/journeys/addJourneyTile.dart';
import 'package:fab/services/challenges_service.dart';
import 'package:fab/services/coaching_service.dart';
import 'package:fab/services/guided_activities.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fab/services/journey_service.dart';

class Discoverscreen extends StatefulWidget {
  final String email;
  const Discoverscreen({super.key, required this.email});

  @override
  State<Discoverscreen> createState() => _DiscoverscreenState();
}

class _DiscoverscreenState extends State<Discoverscreen> {
  // service instance initiallization
  final CoachingService _coachingService = CoachingService();
  final JourneyService _journeyService = JourneyService();
  final GuidedActivities _guidedActivities = GuidedActivities();
  final ChallengesService _challengesService = ChallengesService();

  // list to respective data
  List<Map<String, dynamic>> categoryData = [];
  List<Map<String, dynamic>> coachingData = [];
  List<Map<String, dynamic>> journeys = [];
  List<Map<String, dynamic>> challenges = [];

  //common variables
  bool _isLoading = true;
  double _textSize = 20.0;
  double _textOpacity = 1.0;

  final ScrollController _scrollController = ScrollController();

  // Add state variables for image changing and button selection
  String _currentImage = "assets/images/image.png";
  int _selectedButtonIndex = 0;

  // Define images for each button
  final List<String> _buttonImages = [
    "assets/images/image.png", // Journeys image
    "assets/images/image (3).png", // Guided Coaching image
    "assets/images/image (1).png", // Guided Activities image - replace with actual image
    "assets/images/image (2).png", // Challenges image - replace with actual image
  ];

  // Define titles for each button
  final List<String> _buttonTitles = [
    "Journeys",
    "Coaching Series",
    "Guided Activities",
    "Challenges",
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateFontSize);
    // Load initial data based on default selected button (Journeys)
    getJourneys();
  }

  void _updateFontSize() {
    double offset = _scrollController.offset;
    double newSize = (24 - offset / 5).clamp(14.0, 24.0);
    double newOpacity = (1.0 - (offset - 20.0) / (40.0 - 20.0)).clamp(0.0, 1.0);

    if (_textSize != newSize || _textOpacity != newOpacity) {
      setState(() {
        _textSize = newSize;
        _textOpacity = newOpacity;
      });
    }
  }

  //button press handler
  void _handleButtonPress(int index) {
    setState(() {
      _selectedButtonIndex = index;
      _currentImage = _buttonImages[index];

      // Load appropriate data based on selected button
      if (index == 0 && journeys.isEmpty) {
        if (journeys.isEmpty) getJourneys();
      } else if (index == 1 && coachingData.isEmpty) {
        _fetchMainCoaching();
      } else if (index == 2 && categoryData.isEmpty) {
        _fetchCategories();
      } else if (index == 3 && challenges.isEmpty) {
        getChallenges();
      }
    });
  }

  // Get the currently active data list based on selection
  List<Map<String, dynamic>> get currentData {
    switch (_selectedButtonIndex) {
      case 1:
        return coachingData;
      case 2:
        return categoryData;
      case 3:
        return challenges;
      default:
        return journeys;
    }
  }

  //fetching data from services

  // coaching data
  Future<void> _fetchMainCoaching() async {
    coachingData = await _coachingService.getMainCoachings();
    setState(() {
      _isLoading = false; // Update UI after fetching data
    });
  }

  // guided activities data

  Future<void> _fetchCategories() async {
    categoryData = await _guidedActivities.fetchCategories();
    setState(() {
      _isLoading = false;
    });
  }

// journeys data
  Future<void> getJourneys() async {
    try {
      final fetchedJourneys = await _journeyService.fetchJourneys();
      if (!mounted) return;
      setState(() {
        journeys = fetchedJourneys ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching journeys: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // challenges data
  Future<void> getChallenges() async {
    try {
      final fetchedChallenges = await _challengesService.fetchChallenges();
      if (!mounted) return;
      setState(() {
        challenges = fetchedChallenges ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching journeys: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateFontSize);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bgdiscover.jpeg'),
                opacity: 0.4,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Animation
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child:
                Lottie.asset("assets/animations/discoverscreenanimation.json"),
          ),

          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1,
                      right: MediaQuery.of(context).size.width * 0.05,
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(1800),
                        bottomRight: Radius.circular(2500),
                      ),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        child: Image(
                          height: MediaQuery.of(context).size.height * 0.4,
                          key: ValueKey<String>(_currentImage),
                          image: AssetImage(_currentImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomButtonDiscover(
                            routineName: "Journeys",
                            handleButtonPress: _handleButtonPress,
                            a: 0,
                            selectedButtonIndex: _selectedButtonIndex),
                        CustomButtonDiscover(
                            routineName: "Coaching Series",
                            handleButtonPress: _handleButtonPress,
                            a: 1,
                            selectedButtonIndex: _selectedButtonIndex),
                        CustomButtonDiscover(
                            routineName: "Guided Activities",
                            handleButtonPress: _handleButtonPress,
                            a: 2,
                            selectedButtonIndex: _selectedButtonIndex),
                        CustomButtonDiscover(
                            routineName: "Challenges",
                            handleButtonPress: _handleButtonPress,
                            a: 3,
                            selectedButtonIndex: _selectedButtonIndex)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.09),
              Stack(
                children: [
                  // Fixed position title that will fade out
                  Positioned(
                    top: screenHeight * 0.045,
                    left: screenWidth * 0.1,
                    child: Opacity(
                      opacity: _textOpacity,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: _textSize,
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            _buttonTitles[_selectedButtonIndex],
                            key: ValueKey<String>(
                                _buttonTitles[_selectedButtonIndex]),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // The scrollable content
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: screenWidth * 0.6),
                        SizedBox(
                          width: currentData.length * (screenWidth * 0.462),
                          height: screenHeight * 0.16,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentData.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: AddJourneyTile(
                                  tile: currentData[index],
                                  email: widget.email,
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
            ],
          ),
        ],
      ),
    );
  }
}
