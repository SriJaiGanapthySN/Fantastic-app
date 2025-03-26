import 'package:fab/components/common/mytextfield.dart';
import 'package:fab/screens/auth/login/loginemail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  _SigninscreenState createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle user sign up
  Future<void> _signUpWithEmailPassword() async {
    String email =
        _emailController.text.trim(); // Trim to remove any extra spaces
    String password = _passwordController.text.trim();

    // Check if email or password is empty
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in both email and password.")),
      );
      return;
    }

    try {
      // Create the user with Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If the sign-up is successful, add the email to Firestore
      if (userCredential.user != null) {
        // Debugging: Print values to check if they are correct
        print("Sign up successful. Email: $email");

        try {
          // Step 1: Add the user document to the 'testers' collection
          await FirebaseFirestore.instance
              .collection('testers')
              .doc(email)
              .set({
            'email': email,
            'createdAt': Timestamp.now(),
          });

          // Step 2: Add an empty document to the 'tasks' subcollection
          // await FirebaseFirestore.instance.collection('testers').doc(email).collection('tasks').doc('initial').set({
          //   // You can leave it empty or add placeholders if needed
          //   'taskPlaceholder': 'This is an empty task placeholder',
          // });

          print("User created and tasks successfully.");
        } catch (e) {
          print("Error: $e");
        }

        // Show confirmation in the form of a snack bar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created successfully!")),
        );

        // Navigate to the login screen after sign-up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreenEmail()),
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
                      "Sign Up With Email",
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
                    // Sign Up Button
                    ElevatedButton(
                      onPressed: _signUpWithEmailPassword,
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Login Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already a User?",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return LoginScreenEmail();
                            }));
                          },
                          child: Text(
                            " Log In Now",
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
