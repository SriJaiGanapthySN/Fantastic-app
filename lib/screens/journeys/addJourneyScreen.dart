// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:fab/components/journeys/addJourneyTile.dart';
import 'package:fab/services/journey_service.dart';

class AddJourneyScreen extends StatefulWidget {
  final String email;
  const AddJourneyScreen({super.key, required this.email});

  @override
  State<AddJourneyScreen> createState() => _AddJourneyState();
}

class _AddJourneyState extends State<AddJourneyScreen> {
  final JourneyService _journeyService = JourneyService();
  bool _isLoading = true;
  List<Map<String, dynamic>> journeys = [];
  double _textSize = 24.0; // Initial font size
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getJourneys();
    _scrollController.addListener(_updateFontSize);
  }

  Future<void> getJourneys() async {
    try {
      final fetchedJourneys = await _journeyService.fetchJourneys();
      if (!mounted) return;
      setState(() {
        journeys = fetchedJourneys ?? []; // Ensure it's a list
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

  void _updateFontSize() {
    setState(() {
      _textSize = (24 - _scrollController.offset / 20).clamp(14.0, 24.0);
    });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : journeys.isEmpty
              ? const Center(
                  child: Text(
                    'No Journeys Found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: screenHeight * 0.1,
                      left: screenWidth * 0.05,
                    ),
                    child: Row(
                      children: [
                        // AnimatedDefaultTextStyle(
                        //   duration: const Duration(milliseconds: 200),
                        //   style: TextStyle(
                        //     color: Colors.black,
                        //     fontSize: _textSize,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        //   child: const Text("Journeys"),
                        // ),
                        const SizedBox(width: 30),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: screenHeight * 0.26,
                            child: Stack(
                              children: [
                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // const Text(
                                      //   "Explore Learning Paths",
                                      //   style: TextStyle(
                                      //       fontSize: 18,
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      // const SizedBox(height: 4),
                                      // const Text(
                                      //   "Choose a path to begin",
                                      //   style: TextStyle(
                                      //       fontSize: 16, color: Colors.grey),
                                      // ),
                                      // const SizedBox(height: 10),

                                      // List of Journeys
                                      SizedBox(
                                        width: journeys.length *
                                            (screenWidth * 0.462),
                                        height: screenHeight * 0.16,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: journeys.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: AddJourneyTile(
                                                tile: journeys[index],
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
