import 'package:fab/components/common/mytextfield.dart';
import 'package:fab/screens/nacScreen.dart';
import 'package:fab/screens/auth/signup/signinscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Import HomePage

class LoginScreenEmail extends StatefulWidget {
  const LoginScreenEmail({super.key});

  @override
  _LoginScreenEmailState createState() => _LoginScreenEmailState();
}

class _LoginScreenEmailState extends State<LoginScreenEmail> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle sign-in
  Future<void> _signInWithEmailPassword() async {
    try {
      // Get the email and password from controllers
      String email = _emailController.text;
      String password = _passwordController.text;

      // Sign in with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If sign-in is successful, navigate to the HomePage
      if (userCredential.user != null) {
        String? userEmail = userCredential.user?.email;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  // Routinelistscreen(email: userEmail!), // Pass email here
                  // VerticalStackedCardScreen()
                  // VerticalStackedCardScreen()
                  MainScreen(email: userEmail!)),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Log in With Email",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 50),
                    // Email TextField
                    MyTextfield(
                      hinttext: "E-mail",
                      obscure: false,
                      controller: _emailController,
                    ),
                    SizedBox(height: 70),
                    // Password TextField
                    MyTextfield(
                      hinttext: "Password",
                      obscure: true,
                      controller: _passwordController,
                    ),
                    SizedBox(height: 50),
                    // Sign In Button
                    ElevatedButton(
                      onPressed: _signInWithEmailPassword,
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Log In",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Sign Up Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not a User?",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Signinscreen();
                            }));
                          },
                          child: Text(
                            " Register Now",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
