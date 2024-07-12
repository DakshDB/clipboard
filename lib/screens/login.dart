import 'package:clipboard/constants/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  static const String id = 'login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServicesProvider);
    return Scaffold(
      backgroundColor: platinum, // Use platinum color from themes.dart
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(55),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Text Logo
              // DB
              // Clipboard
              Text(
                'DB \nClipboard',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: oxfordBlue) // Use oxfordBlue color from themes.dart
                    .copyWith(fontSize: 50)
                    .copyWith(fontWeight: FontWeight.w600),
              ),

              // Sign in with Google button
              Container(
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(MediaQuery.of(context).size.height * 0.01),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    auth.signInWithGoogle();
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(
                            color: platinum, // Use platinum color from themes.dart
                            border: Border.all(color: oxfordBlue),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(MediaQuery.of(context).size.height * 0.01),
                              bottomLeft: Radius.circular(MediaQuery.of(context).size.height * 0.01),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: oxfordBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(
                            color: oxfordBlue,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(MediaQuery.of(context).size.height * 0.01),
                              bottomRight: Radius.circular(MediaQuery.of(context).size.height * 0.01),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Sign In',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(color: platinum) // Use platinum color from themes.dart
                                .copyWith(fontSize: 22)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
