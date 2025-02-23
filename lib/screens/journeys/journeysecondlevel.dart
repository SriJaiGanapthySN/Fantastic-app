import 'package:fab/models/skill.dart';
import 'package:fab/models/skillTrack.dart';
import 'package:fab/screens/journeys/journeyLetter.dart';
import 'package:fab/screens/journeys/journeyOneTime.dart';
import 'package:fab/screens/journeys/journey_reveal/journeyscreenrevealtype1.dart';
import 'package:fab/screens/journeys/journey_reveal/journeyscreenrevealtype2.dart';
import 'package:fab/screens/journeys/journey_reveal/journeyscreentype3.dart';
import 'package:fab/services/journey_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Journeysecondlevel extends StatefulWidget {
  final Skill skill;
  final String email;
  final skillTrack skilltrack;

  const Journeysecondlevel({
    super.key,
    required this.skill,
    required this.email,
    required this.skilltrack,
  });

  @override
  State<Journeysecondlevel> createState() => _JourneysecondlevelState();
}

class _JourneysecondlevelState extends State<Journeysecondlevel>
    with TickerProviderStateMixin {
  final JourneyService _journeyService = JourneyService();
  List<Map<String, dynamic>> skilllevels = [];
  int totalSkillLevels = 0;

  late ScrollController _scrollController;
  double _iconScale = 1.0;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);
  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: 0.6, end: 1.2).animate(_controller);
  late final Animation<double> _fadeAnimation =
      Tween<double>(begin: 1, end: 0.2).animate(_controller);
  late final Animation<double> _fadeAnimationQC =
      Tween<double>(begin: 0.001, end: 0.6).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut, // Add a curve for smooth animation
  ));

  @override
  void initState() {
    super.initState();
    fetchSkillLevels();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          double offset = _scrollController.offset;
          _iconScale = (1 - offset / 200).clamp(0.5, 1.0);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void fetchSkillLevels() async {
    List<Map<String, dynamic>> skillLevels = await _journeyService
        .getSkillLevels(widget.email, widget.skill.objectId);

    if (skillLevels.isEmpty) {
      print('No skill level found for skillId: $widget.skill.objectId');
    } else {
      skillLevels.sort((a, b) {
        // Assuming 'position' is an integer field. You can modify this if it's a different type (e.g., double, String)
        return a['position'].compareTo(b['position']);
      });
      print('Skills retrieved: $skillLevels');
      setState(() {
        skilllevels = skillLevels;
      });
      totalSkillLevels = skillLevels.length;

      // You can now work with the skillLevels list
    }
  }

  String getTypeText(String type, int pos) {
    switch (type) {
      case 'CONTENT':
        return 'Your Letter no. $pos';
      case 'ONE_TIME_REMINDER':
        return 'One-Time Action';
      case 'MOTIVATOR':
        return 'Motivator';
      case 'GOAL':
        return 'Goal';
      default:
        return ''; // Default case if no match is found
    }
  }

  void pageRoute(card) {
    switch (card['type'] as String? ?? '') {
      case 'CONTENT':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JourneyLetter(
                letterData: card,
                email: widget.email,
                skill: widget.skill,
                skilltrack: widget.skilltrack),
          ),
        );
      case 'ONE_TIME_REMINDER':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JourneyOneTime(
                oneTimeData: card,
                email: widget.email,
                skill: widget.skill,
                skilltrack: widget.skilltrack),
          ),
        );
      case 'MOTIVATOR':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Journeyscreentype3(
                motivatorData: card,
                email: widget.email,
                skill: widget.skill,
                skilltrack: widget.skilltrack),
          ),
        );
      case 'GOAL':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Journeyscreenrevealtype2(
                goalData: card,
                email: widget.email,
                skill: widget.skill,
                skilltrack: widget.skilltrack),
          ),
        );
      default:
        return; // Default case if no match is found
    }
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
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.white),
            pinned: true,
            title: Text(
              // "Small Change, Big Impact",
              widget.skill.title,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: colorFromString(widget.skill.color),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 210,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  // image: AssetImage('assets/images/meditation.jpg'),
                  image: NetworkImage(widget.skilltrack.topDecoImageUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  Transform.scale(
                    scale: _iconScale,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: colorFromString(widget.skill.color),
                      child: widget.skill.iconUrl != null
                          ? SvgPicture.network(
                              widget.skill.iconUrl,
                              width: 50,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              Icons.help_outline,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Card List Section
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cardData = skilllevels[index];

                return InkWell(
                  onTap: () {
                    // Navigate to another page, for example, a details page
                    pageRoute(cardData);
                  },
                  child: Card(
                    margin: EdgeInsets.only(left: 25, right: 25, top: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SizedBox(
                      height: 180,
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(26),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text Section
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getTypeText(
                                            cardData['type'] as String? ?? '',
                                            widget.skill.position),
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        cardData['contentTitle'] as String? ??
                                            '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      // Completion Status
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 8),
                                          Text(
                                            cardData['isCompleted'] == true
                                                ? 'COMPLETED'
                                                : 'READ',
                                            // "COMPLETED",
                                            style: TextStyle(
                                              // color: Colors.green,

                                              color: cardData['isCompleted'] ==
                                                      true
                                                  ? Colors.green
                                                  : colorFromString(
                                                      widget.skill.color),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: FadeTransition(
                                    opacity: _fadeAnimationQC,
                                    child: Container(
                                      width: 95, // Set the width you want
                                      height: 70,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 15),
                                      decoration: BoxDecoration(
                                        color: cardData['isCompleted'] == true
                                            ? Colors.green
                                            : colorFromString(
                                                widget.skill.color),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(0),
                                          topRight: Radius.circular(15),
                                          bottomLeft: Radius.circular(70),
                                        ),
                                      ),
                                    ),
                                  )),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: cardData['isCompleted'] == true
                                        ? Colors.green
                                        : colorFromString(widget.skill.color),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(70),
                                    ),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(left: 6),
                                    child: Text(
                                      // cardData['status']! as String,
                                      '${cardData['position']}/$totalSkillLevels',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: totalSkillLevels, // Total number of cards
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:fab/models/skill.dart';
// import 'package:fab/models/skillTrack.dart';
// import 'package:fab/screens/journeyLetter.dart';
// import 'package:fab/screens/journeyOneTime.dart';
// import 'package:fab/screens/journeyscreenrevealtype1.dart';
// import 'package:fab/screens/journeyscreenrevealtype2.dart';
// import 'package:fab/screens/journeyscreentype3.dart';
// import 'package:fab/services/journey_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// class Journeysecondlevel extends StatefulWidget {
//   final Skill skill;
//   final String email;
//   final skillTrack skilltrack;

//   const Journeysecondlevel({
//     super.key,
//     required this.skill,
//     required this.email,
//     required this.skilltrack,
//   });

//   @override
//   State<Journeysecondlevel> createState() => _JourneysecondlevelState();
// }

// class _JourneysecondlevelState extends State<Journeysecondlevel>
//     with TickerProviderStateMixin {
//   final JourneyService _journeyService = JourneyService();
//   List<Map<String, dynamic>> skilllevels = [];
//   int totalSkillLevels = 0;

//   late ScrollController _scrollController;
//   double _iconScale = 1.0;
//   late final AnimationController _controller = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 1500),
//   )..repeat();
//   late final Animation<double> _scaleAnimation =
//       Tween<double>(begin: 0.6, end: 1.2).animate(_controller);
//   late final Animation<double> _fadeAnimation =
//       Tween<double>(begin: 1, end: 0.2).animate(_controller);

//   @override
//   void initState() {
//     super.initState();
//     fetchSkillLevels();
//     _scrollController = ScrollController()
//       ..addListener(() {
//         setState(() {
//           double offset = _scrollController.offset;
//           _iconScale = (1 - offset / 200).clamp(0.5, 1.0);
//         });
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void fetchSkillLevels() async {
//     List<Map<String, dynamic>> skillLevels = await _journeyService
//         .getSkillLevels(widget.email, widget.skill.objectId);

//     if (skillLevels.isEmpty) {
//       print('No skill level found for skillId: $widget.skill.objectId');
//     } else {
//       skillLevels.sort((a, b) {
//         // Assuming 'position' is an integer field. You can modify this if it's a different type (e.g., double, String)
//         return a['position'].compareTo(b['position']);
//       });
//       print('Skills retrieved: $skillLevels');
//       setState(() {
//         skilllevels = skillLevels;
//       });
//       totalSkillLevels = skillLevels.length;

//       // You can now work with the skillLevels list
//     }
//   }

//   String getTypeText(String type, int pos) {
//     switch (type) {
//       case 'CONTENT':
//         return 'Your Letter no. ${pos}';
//       case 'ONE_TIME_REMINDER':
//         return 'One-Time Action';
//       case 'MOTIVATOR':
//         return 'Motivator';
//       case 'GOAL':
//         return 'Goal';
//       default:
//         return ''; // Default case if no match is found
//     }
//   }

//   void pageRoute(card) {
//     switch (card['type'] as String? ?? '') {
//       case 'CONTENT':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => JourneyLetter(
//                 letterData: card,
//                 email: widget.email,
//                 skill: widget.skill,
//                 skilltrack: widget.skilltrack),
//           ),
//         );
//       case 'ONE_TIME_REMINDER':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => JourneyOneTime(
//                 oneTimeData: card,
//                 email: widget.email,
//                 skill: widget.skill,
//                 skilltrack: widget.skilltrack),
//           ),
//         );
//       case 'MOTIVATOR':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Journeyscreentype3(
//                 motivatorData: card,
//                 email: widget.email,
//                 skill: widget.skill,
//                 skilltrack: widget.skilltrack),
//           ),
//         );
//       case 'GOAL':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Journeyscreenrevealtype2(
//                 goalData: card,
//                 email: widget.email,
//                 skill: widget.skill,
//                 skilltrack: widget.skilltrack),
//           ),
//         );
//       default:
//         return; // Default case if no match is found
//     }
//   }

//   Color colorFromString(String colorString) {
//     // Remove the '#' if it's there and parse the hex color code
//     String hexColor = colorString.replaceAll('#', '');

//     // Ensure the string has the correct length (6 digits)
//     if (hexColor.length == 6) {
//       // Parse the color string to an integer and return it as a Color
//       return Color(
//           int.parse('0xFF$hexColor')); // Adding 0xFF to indicate full opacity
//     } else {
//       throw FormatException('Invalid color string format');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           SliverAppBar(
//             iconTheme: IconThemeData(color: Colors.white),
//             pinned: true,
//             title: Text(
//               widget.skill.title,
//               style: TextStyle(color: Colors.white),
//             ),
//             backgroundColor: colorFromString(widget.skill.color),
//           ),
//           SliverToBoxAdapter(
//             child: Container(
//               height: 210,
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage(widget.skilltrack.topDecoImageUrl),
//                   fit: BoxFit.cover,
//                 ),
//                 borderRadius:
//                     BorderRadius.vertical(bottom: Radius.circular(10)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 80),
//                   Transform.scale(
//                     scale: _iconScale,
//                     child: CircleAvatar(
//                       radius: 40,
//                       backgroundColor: colorFromString(widget.skill.color),
//                       child: widget.skill.iconUrl != null
//                           ? SvgPicture.network(
//                               widget.skill.iconUrl,
//                               width: 50,
//                               fit: BoxFit.contain,
//                             )
//                           : Icon(
//                               Icons.help_outline,
//                               size: 50,
//                               color: Colors.white,
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ),

//           // Card List Section
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (context, index) {
//                 final cardData = skilllevels[index];

//                 return InkWell(
//                   onTap: () {
//                     // Navigate to another page, for example, a details page
//                     pageRoute(cardData);
//                   },
//                   child: Card(
//                     margin: EdgeInsets.only(left: 25, right: 25, top: 15),
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: SizedBox(
//                       height: 180,
//                       child: Stack(
//                         children: [
                          
//                           Padding(
//                             padding: EdgeInsets.all(26),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Text Section
//                                 Expanded(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         getTypeText(
//                                             cardData['type'] as String? ?? '',
//                                             widget.skill.position),
//                                         style: const TextStyle(
//                                           fontSize: 26,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         cardData['contentTitle'] as String? ??
//                                             '',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                       SizedBox(height: 15),
//                                       // Completion Status
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           SizedBox(width: 8),
//                                           Text(
//                                             cardData['isCompleted'] == true
//                                                 ? 'COMPLETED'
//                                                 : 'READ',
//                                             style: TextStyle(
//                                               color: cardData['isCompleted'] ==
//                                                       true
//                                                   ? Colors.green
//                                                   : colorFromString(
//                                                       widget.skill.color),
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
                                
//                               ],
                              
//                             ),
                            
//                           ),
//                           // Fade Transition with Positioned Container
                          
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               childCount: totalSkillLevels, // Total number of cards
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }