import 'package:flutter/material.dart';

class CustomButtonDiscover extends StatelessWidget {
  CustomButtonDiscover({
    super.key,
    required this.routineName,
    required this.handleButtonPress,
    required this.selectedButtonIndex,
    required this.a,
  });
  final int selectedButtonIndex;
  final Function handleButtonPress;
  final String routineName;
  final int a;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      margin: EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: () => handleButtonPress(a),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedButtonIndex == a
              ? const Color.fromARGB(255, 255, 255, 255)
              : const Color.fromARGB(255, 215, 172, 52),
          foregroundColor: selectedButtonIndex == a
              ? const Color.fromARGB(255, 215, 172, 52)
              : const Color.fromARGB(255, 255, 255, 255),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Text(
          routineName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
