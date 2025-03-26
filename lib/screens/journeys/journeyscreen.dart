import 'package:fab/models/skill.dart';
import 'package:fab/models/skillTrack.dart';
import 'package:fab/screens/journeys/journeysecondlevel.dart';
import 'package:fab/services/journey_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Journeyscreen extends StatefulWidget {
  final String email;
  const Journeyscreen({super.key, required this.email});

  @override
  State<Journeyscreen> createState() => _JourneyscreenState();
}

class _JourneyscreenState extends State<Journeyscreen>
    with SingleTickerProviderStateMixin {
  final JourneyService _journeyService = JourneyService();
  skillTrack? skilltrack;
  bool _isLoading = true;
  String skillTrackID = '';
  List<Skill> skills = [];
  int completed = 0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();
  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: 0.6, end: 1.2).animate(_controller);
  late final Animation<double> _fadeAnimation =
      Tween<double>(begin: 1, end: 0.2).animate(_controller);
  @override
  void initState() {
    super.initState();
    print("object_________________");
    _fetchJourney();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchSkill() async {
    try {
      final result =
          await _journeyService.getSkills(skillTrackID, widget.email);
      int totalSkillLevelsCompleted =
          skills.fold(0, (sum, skill) => sum + skill.skillLevelCompleted);
      setState(() {
        skills = result;
        completed = totalSkillLevelsCompleted;
      });
    } catch (e) {
      print('Error adding skill: $e');
    }
  }

  Future<void> _fetchJourney() async {
    try {
      final journey =
          await _journeyService.fetchUnreleasedJourney(widget.email);
      if (journey != null) {
        setState(() {
          skilltrack = journey;
          _isLoading = false;
          skillTrackID = skilltrack!.objectId;
        });
        fetchSkill();
      } else {
        print('No unreleased journey found.');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching journey: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Text _fetchProgressText(int levelCompleted, int levelTotal, bool open) {
    String progressText = "Not yet unlocked";
    Color progressColor = Colors.grey;
    if (open) {
      if (levelCompleted == 0) {
        progressText = "Not yet Started";
        progressColor = Colors.blue;
      } else {
        progressText = "$levelCompleted/$levelTotal achived";
        progressColor = Colors.red;
      }
    }

    return Text(
      progressText,
      style: TextStyle(fontSize: 12, color: progressColor),
    );
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
      appBar: AppBar(
        title: Text('Journey'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : skilltrack == null
              ? Center(child: Text("No journey found"))
              : Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      width: double.infinity,
                      padding: EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                            image: NetworkImage(skilltrack!.imageUrl),
                            fit: BoxFit.cover),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${skilltrack!.levelsCompleted}/${skilltrack!.skillLevelCount} events achieved',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${(skilltrack!.levelsCompleted / skilltrack!.skillLevelCount * 100).toInt()}% completion',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: ListView.builder(
                        itemCount: skills.length,
                        itemBuilder: (context, index) {
                          final skill = skills[index];
                          bool shouldAnimate = (index == 0 &&
                                  skill.skillLevelCompleted <
                                      skill.totalLevels) ||
                              (index > 0 &&
                                  skills[index - 1].skillLevelCompleted ==
                                      skills[index - 1].totalLevels);

                          bool open = (index == 0) ||
                              (index > 0 &&
                                  skills[index - 1].skillLevelCompleted ==
                                      skills[index - 1].totalLevels);

                          return GestureDetector(
                              onTap: () {
                                if (open) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Journeysecondlevel(
                                          skill: skill,
                                          email: widget.email,
                                          skilltrack: skilltrack!),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 25),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Stack(
                                          children: [
                                            if (shouldAnimate)
                                              FadeTransition(
                                                opacity: _fadeAnimation,
                                                child: ScaleTransition(
                                                  scale: _scaleAnimation,
                                                  child: Container(
                                                    width: 45,
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: colorFromString(
                                                          skill.color),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            else
                                              Container(
                                                width: 45,
                                                height: 45,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: open
                                                      ? colorFromString(
                                                          skill.color)
                                                      : Colors.grey,
                                                ),
                                              ),
                                            // FadeTransition(
                                            //   opacity: _fadeAnimation,
                                            //   child: ScaleTransition(
                                            //     scale: _scaleAnimation,
                                            //     child: Container(
                                            //       width: 45,
                                            //       height: 45,
                                            //       decoration: BoxDecoration(
                                            //         shape: BoxShape.circle,
                                            //         color:
                                            //             colorFromString(skill.color),

                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                            Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.only(
                                                  left: 3, top: 2),
                                              child: CircleAvatar(
                                                backgroundColor: open
                                                    ? colorFromString(
                                                        skill.color)
                                                    : Colors.grey,
                                                child: skill.iconUrl != null
                                                    ? SvgPicture.network(
                                                        skill.iconUrl,
                                                        width: 20,
                                                        height: 20,
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Icon(
                                                        Icons.help_outline,
                                                        size: 20,
                                                        color: Colors.white,
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (index != skills.length - 1)
                                          DottedLineNearIcon(),
                                      ],
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            skill.title,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          _fetchProgressText(
                                              skill.skillLevelCompleted,
                                              skill.totalLevels,
                                              open),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class DottedLineNearIcon extends StatelessWidget {
  const DottedLineNearIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2,
      height: 50,
      child: CustomPaint(
        painter: DottedLinePainter(),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    double startY = 0;
    final dashHeight = 4;
    final spaceHeight = 4;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + spaceHeight;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
