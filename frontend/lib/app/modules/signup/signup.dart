import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:frontend/app/modules/signin/signin.dart';
import 'package:frontend/app/theme/color_theme.dart';
import 'package:frontend/app/modules/signin/widgets/custom_circle_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen();

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String firstname = '';
  String lastname = '';
  String username = '';
  String email = '';
  String password = '';
  String error = '';
  bool _passwordIsHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GFTheme.secondaryGrey,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 45,
                      ),
                      Text(
                        'Signup',
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .copyWith(color: Colors.black),
                      ),
                      // Name text field
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'First name'),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter your first name' : null,
                        onChanged: (val) {
                          setState(() => firstname = val);
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Last name'),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter your last name' : null,
                        onChanged: (val) {
                          setState(() => lastname = val);
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter your username' : null,
                        onChanged: (val) {
                          setState(() => username = val);
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      // Email Text field
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Email address'),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter an email' : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      // Password Text Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: GestureDetector(
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordIsHidden = !_passwordIsHidden;
                                });
                              },
                              icon: Icon(
                                _passwordIsHidden
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        obscureText: _passwordIsHidden,
                        validator: (val) => val!.length < 8
                            ? 'Enter a password 8+ characters long'
                            : null,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      CustomCircleButton(
                        onPressed: () async {
                          //await AppNavigator.replaceWith(Routes.signin);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Already have an account?',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                GFTheme.lightPurple),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                ContinuousRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20.0)))),
                        onPressed: () async {
                          GetPage(name: 'signin', page: () => SignInScreen());
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(color: GFTheme.primaryMaroon),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
