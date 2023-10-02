import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/main.dart';
import 'package:todo/screens/todofeed.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ToDoFeed(),
          ),
        );
      }
    });
  }

  /// Function to generate a random 16 character string.
  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 60,
              ),
              const Text(
                "Get Started",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Ubuntu'),
              ),
              const SizedBox(
                height: 60,
              ),
              Image.asset(
                'assets/login_page.png',
                fit: BoxFit.fitWidth,
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Ubuntu',
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'Let us take care of the due dates\n'),
                          TextSpan(text: 'so you can focus on '),
                          TextSpan(
                              text: "what's important",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(
                height: 120,
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  const appAuth = FlutterAppAuth();

                  // Just a random string
                  final rawNonce = _generateRandomString();
                  final hashedNonce =
                      sha256.convert(utf8.encode(rawNonce)).toString();
                  final clientId = Platform.isAndroid
                      ? 'ANDROID_CLIENT_ID'
                      : 'IOS';

                  /// Set as reversed DNS form of Google Client ID + `:/` for Google login
                  final redirectUrl =
                      '${clientId.split('.').reversed.join('.')}:/';

                  /// Fixed value for google login
                  const discoveryUrl =
                      'https://accounts.google.com/.well-known/openid-configuration';

                  // authorize the user by opening the concent page
                  final result = await appAuth.authorize(
                    AuthorizationRequest(
                      clientId,
                      redirectUrl,
                      discoveryUrl: discoveryUrl,
                      nonce: hashedNonce,
                      scopes: [
                        'openid',
                        'email',
                        'profile',
                      ],
                    ),
                  );

                  if (result == null) {
                    throw 'No result';
                  }

                  // Request the access and id token to google
                  final tokenResult = await appAuth.token(
                    TokenRequest(
                      clientId,
                      redirectUrl,
                      authorizationCode: result.authorizationCode,
                      discoveryUrl: discoveryUrl,
                      codeVerifier: result.codeVerifier,
                      nonce: result.nonce,
                      scopes: [
                        'openid',
                        'email',
                      ],
                    ),
                  );

                  final idToken = tokenResult?.idToken;

                  if (idToken == null) {
                    throw 'No idToken';
                  }

                  await supabase.auth.signInWithIdToken(
                    provider: Provider.google,
                    idToken: idToken,
                    nonce: rawNonce,
                  );
                },
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/google_logo.png',
                    scale: 2,
                  ),
                ),
                label: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Sign Up with Google'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
