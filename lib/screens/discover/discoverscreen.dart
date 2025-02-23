// ignore_for_file: deprecated_member_use
import 'package:fab/components/discover/buttonimage.dart';
import 'package:fab/components/discover/discoverbuttons.dart';
import 'package:fab/components/discover/discoverstrip.dart';
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

class _DiscoverscreenState extends State<Discoverscreen>
    with SingleTickerProviderStateMixin {
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

  final ScrollController _scrollController = ScrollController();

  // Add state variables for image changing and button selection
  String _currentImage = "assets/images/image.png";
  int _selectedButtonIndex = 0;

  // Define images for each button
  final List<String> _buttonImages = [
    "assets/images/image (5).png", // Journeys image
    "assets/images/image (3).png", // Guided Coaching image
    "assets/images/image (4).png", // Guided Activities image - replace with actual image
    "assets/images/image (2).png", // Challenges image - replace with actual image
  ];
  // Animation controller for data discovery animation
  late AnimationController _dataDiscoveryController;

  @override
  void initState() {
    super.initState();

    // Load initial data based on default selected button (Journeys)
    getJourneys();

    // Initialize the animation controller with a longer duration to slow down the animation
    _dataDiscoveryController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Start the animation and make it repeat
    _dataDiscoveryController.repeat();
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
        journeys = fetchedJourneys;
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
        challenges = fetchedChallenges;
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
    _scrollController.dispose();
    _dataDiscoveryController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bgdiscover.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Buttonimage(currentImage: _currentImage),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Lottie.asset(
              "assets/animations/disbottom.json",
              controller: _dataDiscoveryController,
              repeat: false,
              animate: false,
              width: MediaQuery.of(context)
                  .size
                  .width, // Make animation span full width
            ),
          ),
          Column(
            children: [
              Discoverbuttons(
                  handleButtonPress: _handleButtonPress,
                  selectedButtonIndex: _selectedButtonIndex),
              SizedBox(height: screenHeight * 0.09),
              Discoverstrip(currentData: currentData, email: widget.email)
            ],
          ),
        ],
      ),
    );
  }
}
