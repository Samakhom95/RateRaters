import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rate_raters/Src/home.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const Text('Welcome new user!!'),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft, child: const Home()),
                (route) => false),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.grey,
              elevation: 0.0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
