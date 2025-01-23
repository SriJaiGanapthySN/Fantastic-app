import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ContentCard extends StatefulWidget {
  final String title;
  final String duration;
  final String type;
  const ContentCard({
    super.key,
    required this.title,
    required this.duration,
    required this.type,
  });

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
//   late final VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
// // ignore: deprecated_member_use
//     _controller = VideoPlayerController.asset("assets/videos/chatBg.mp4")
//       ..initialize().then((_) {
//         setState(() {});
//       });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF002A73),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ListTile(
                    //   leading: _controller.value.isInitialized
                    //       ? Container(
                    //           width: 100.0,
                    //           height: 56.0,
                    //           child: VideoPlayer(_controller),
                    //         )
                    //       : CircularProgressIndicator(),
                    //   // title: Text(widget.video.file.path.split('/').last),
                    //   onTap: () {
                    //     // Navigator.push(
                    //     //   context,
                    //     //   MaterialPageRoute(
                    //     //     builder: (context) =>
                    //     //         VideoPlayerPage(videoUrl: widget.video.file.path),
                    //     //   ),
                    //     // );
                    //   },
                    // ),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              widget.duration,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            const Icon(Icons.folder,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              widget.type,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: Colors.white),
        ],
      ),
    );
  }
}
