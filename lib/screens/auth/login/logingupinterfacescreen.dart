import 'package:fab/screens/auth/login/loginemail.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Logingupinterfacescreen extends StatelessWidget {
  const Logingupinterfacescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Title Text
          Positioned(
            top: 100,
            left: 30,
            right: 30,
            child: Center(
              child: Text(
                "Habbit building made easy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Sign-in Buttons
          Positioned(
            top: MediaQuery.of(context).size.height * 0.7, // 70% from top
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Google Sign-In Button
                Container(
                  height: 50,
                  width: 350,
                  margin: EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.google,
                          color: const Color.fromARGB(255, 8, 8, 8),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Sign in with Google',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 1, 1, 1),
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                // Email Sign-In Button
                SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return LoginScreenEmail();
                      }));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          FontAwesomeIcons.envelope,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Sign in with Email',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
