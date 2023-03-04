
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';

import '../blocs/auth_blocs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
            appBar: 
          AppBar(  iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.white,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light),
              backgroundColor: Colors.white,
              title: const Text('RateRaters'),
              centerTitle: true,
              titleTextStyle: const TextStyle(
                color: Colors.black,
              ),
              elevation: 0.0,
            ),
            backgroundColor: Colors.white,
            body: 
           
        ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const Text('Log In'),
                SignInButton(
                  Buttons.Google,
                  onPressed: () async => {await authBloc.loginGoogle(context)},
                ),
              ],
            ),
          );
  }
}
