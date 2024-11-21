import 'dart:math' as math;
import 'dart:io' show Platform;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';

String generateNonce([int length = 32]) {
  final charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = math.Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ],
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  static final FacebookAuth facebookAuth = FacebookAuth.instance;
  String? _nonce;

  @override
  void initState() {
    super.initState();
    // _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed:_googleHandleSignIn,
                style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                foregroundColor: Colors.white70,
                backgroundColor: const Color.fromARGB(255, 53, 82, 98),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FaIcon(
                      FontAwesomeIcons.google,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Google',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  ],
                ),
              ),
            ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child:ElevatedButton(
              onPressed: _metaHandleSignIn,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                foregroundColor: Colors.white70,
                backgroundColor: const Color.fromARGB(255, 53, 82, 98),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FaIcon(
                      FontAwesomeIcons.facebook,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Facebook',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  ],
                ),
              ),
            ),
            )
          ],
          ),
        ),
      ),
    );
  }

  Future<void> _googleHandleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication googleAuth = await account.authentication;
        final String? accessToken = googleAuth.accessToken;
        
        final response = await http.post(
          Uri.parse('${getServerUrl()}/social-login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'accessToken': accessToken,
            'provider': 'google',
          }),
        );

        print(response.body);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    } catch (error) {
      print('Sign-in error: $error');
    }
  }

  Future<void> _metaHandleSignIn() async {
    _nonce = generateNonce();

    final result = await facebookAuth.login(
      loginTracking: LoginTracking.limited,
      nonce: _nonce,
    );

    switch (result.status) {
      case LoginStatus.success:
        final response = await http.post(
          Uri.parse('${getServerUrl()}/social-login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'accessToken': result.accessToken,
            'provider': 'facebook',
          }),
        );

        print(response.body);

      case LoginStatus.cancelled:
      case _:
        print(
          '${result.status.name}: ${result.message}',
        );
    }
  }

  String getServerUrl() {
    const bool kIsWeb = identical(0, 0.0);
    const serverPort = String.fromEnvironment('SERVER_PORT', defaultValue: '5000');
    
    if (kIsWeb) {
      return 'http://localhost:$serverPort';
    }
    
    if (Platform.isAndroid) {
      if (const bool.fromEnvironment('dart.vm.product')) {
        // Release mode - use your production server
        return 'https://your-production-server.com';
      }
      // Debug mode - use 10.0.2.2 for Android emulator
      return 'http://10.0.2.2:$serverPort';
    }
    
    // iOS or other platforms
    return 'http://localhost:$serverPort';
  }
}