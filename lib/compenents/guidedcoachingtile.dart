import 'package:flutter/material.dart';

class Guidedcoachingtile extends StatefulWidget {
  const Guidedcoachingtile(
      {super.key,
      required this.url,
      required this.title,
      required this.timestamp,
       this.subtitle,
       required this.color,
      this.onTap});
  final String url;
  final String title;
  final String timestamp;
  final String? subtitle; // Optional subtitle
  final VoidCallback? onTap;
  final String color;


  @override
  _Guidedcoachingtile createState() => _Guidedcoachingtile();
}

class _Guidedcoachingtile extends State<Guidedcoachingtile> {
  final GlobalKey _subtitleKey = GlobalKey(); // Key to measure subtitle widget
  double _subtitleHeight = 0;

  Color colorFromString(String colorString) {
    String hexColor = colorString.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('0xFF$hexColor'));
    } else {
      throw FormatException('Invalid color string format');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double tileHeight = screenHeight * 0.5; // 50% of screen height
    final double horizontalMargin = screenWidth * 0.00;
    final double titleFontSize = screenWidth * 0.065; // 6.5% of screen width
    final double subtitleFontSize = screenWidth * 0.05; // 5% of screen width

    // Adjust title position based on subtitle height
    double titlePosition = tileHeight * 0.1;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            height: tileHeight,
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(widget.url),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorFromString(widget.color),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            left: horizontalMargin + 10,
            top: titlePosition, // Adjusted title position
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                // shadows: [
                //   Shadow(
                //     offset: const Offset(1, 1),
                //     blurRadius: 4,
                //     color: Colors.black.withOpacity(0.7),
                //   ),
                // ],
              ),
            ),
          ),
          if (widget.subtitle != null)
            Positioned(
              left: horizontalMargin + 10,
              right: horizontalMargin + 10,
              top: tileHeight * 0.2,
              child: Text(
                widget.subtitle!,
                key: _subtitleKey, // Attach the key to subtitle text
                style: TextStyle(
                  height: 1.15,
                  color: Colors.white,
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.normal,
                  // shadows: [
                  //   Shadow(
                  //     offset: const Offset(1, 1),
                  //     blurRadius: 4,
                  //     color: Colors.black.withOpacity(0.7),
                  //   ),
                  // ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Stack(
//         children: [
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 20),
//             height: 130,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//               image: DecorationImage(
//                 image: NetworkImage(url),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 alignment: Alignment.center,
//                 margin: const EdgeInsets.only(left: 300, top: 20),
//                 height: 40,
//                 width: 80,
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(120, 0, 0, 0),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   timestamp,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.only(left: 40, top: 10),
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
