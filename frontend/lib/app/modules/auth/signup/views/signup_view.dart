import 'package:flutter/material.dart';
import 'package:frontend/app/data/models/login.dart';
import 'package:frontend/app/data/provider/api_services.dart';
import 'package:frontend/app/global_widgets/action_button.dart';
import 'package:frontend/app/global_widgets/snackbar.dart';
import 'package:frontend/app/modules/auth/signin/views/signin_view.dart';
import 'package:frontend/app/modules/home/views/home_view.dart';
import 'package:frontend/app/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:frontend/app/theme/color_theme.dart';
import 'package:the_validator/the_validator.dart';

import '../../auth.dart';

class SignupScreen extends StatefulWidget {
  final Function onLoginSelected;

  SignupScreen({
    Key? key,
    required this.onLoginSelected,
  }) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordEmpty = true;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordEmpty = true;
  bool _isConfirmPasswordObscure = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(_size.height > 770
          ? 32
          : _size.height > 670
              ? 16
              : 16),
      child: Center(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: Responsive.isMobile(context)
                ? _size.height *
                    (_size.height > 770
                        ? 0.7
                        : _size.height > 670
                            ? 0.7
                            : 0.9)
                : _size.height *
                    (_size.height > 770
                        ? 0.7
                        : _size.height > 670
                            ? 0.8
                            : 0.9),
            width: Responsive.isMobile(context) && _size.width < 500
                ? _size.width
                : 60.w,
            child: Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Signup",
                        style: Theme.of(context)
                            .textTheme
                            .headline3
                            ?.copyWith(color: Colors.black, fontSize: 16.sp),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: 30,
                        child: Divider(
                          color: GFTheme.primaryColor,
                          thickness: 2,
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      _loginForm(),
                      SizedBox(
                        height: 32,
                      ),
                      ActionButton(
                          press: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              GetIt.I<APIServices>()
                                  .register(
                                      forename: _firstnameController.text,
                                      surname: _lastnameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      username: _usernameController.text)
                                  .then((value) async {
                                if (value.signedUp) {
                                  GetIt.I<APIServices>()
                                      .login(
                                          email: _emailController.text,
                                          password: _passwordController.text)
                                      .then(
                                          (value) => Get.off(() => HomeView()));
                                } else {
                                  SnackbarMessage(
                                    message: value.message,
                                    icon: Icon(Icons.error, color: Colors.red),
                                  ).showMessage(
                                    context,
                                  );
                                }
                              });
                            }
                          },
                          title: 'Register'),
                      SizedBox(
                        height: 32,
                      ),
                      Responsive(
                        desktop: GoToLogin(
                          textSize: 7,
                          widget: widget,
                        ),
                        mobile: GoToLogin(
                          textSize: _size.width < 500 ? 9 : 7,
                          widget: widget,
                        ),
                        tablet: GoToLogin(
                          textSize: 7,
                          widget: widget,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Form _loginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _firstnameController,
            keyboardType: TextInputType.name,
            validator: FieldValidator.required(message: "First name required"),
            style: TextStyle(color: Colors.black, fontSize: 10.sp),
            decoration: const InputDecoration(
              //filled: true,
              labelText: "First name",
              prefixIcon: Icon(Icons.perm_identity),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: _lastnameController,
            keyboardType: TextInputType.name,
            validator: FieldValidator.required(message: "Last name required"),
            style: TextStyle(color: Colors.black, fontSize: 10.sp),
            decoration: const InputDecoration(
              //filled: true,
              labelText: "Last name",
              prefixIcon: Icon(Icons.perm_identity),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.text,
            validator: FieldValidator.required(message: "Username required"),
            style: TextStyle(color: Colors.black, fontSize: 10.sp),
            decoration: const InputDecoration(
              //filled: true,
              labelText: "Username",
              prefixIcon: Icon(Icons.verified_user_sharp),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: FieldValidator.email(),
            style: TextStyle(color: Colors.black, fontSize: 10.sp),
            decoration: const InputDecoration(
              //filled: true,
              labelText: "Email",
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          TextFormField(
            style: TextStyle(color: Colors.black, fontSize: 10.sp),
            controller: _passwordController,
            //autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _isPasswordEmpty = false;
                });
              } else {
                setState(() {
                  _isPasswordEmpty = true;
                });
              }
            },
            obscureText: _isPasswordObscure,
            validator: FieldValidator.password(
                minLength: 6,
                shouldContainNumber: true,
                shouldContainCapitalLetter: true,
                shouldContainSmallLetter: true,
                shouldContainSpecialChars: true,
                errorMessage: "Password must match the required format",
                onNumberNotPresent: () {
                  return "Password must contain number";
                },
                onSpecialCharsNotPresent: () {
                  return "Password must contain special characters";
                },
                onCapitalLetterNotPresent: () {
                  return "Password must contain capital letters";
                }),
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock_outline),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              suffixIcon: !_isPasswordEmpty
                  ? IconButton(
                      icon: _isPasswordObscure
                          ? Icon(
                              Icons.visibility,
                            )
                          : Icon(Icons.visibility_off),
                      splashRadius: 0.2,
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          _isPasswordObscure = !_isPasswordObscure;
                        });
                      },
                    )
                  : null,
            ),
          ),
          SizedBox(
            height: 32,
          ),
          TextFormField(
            style: TextStyle(color: Colors.black, fontSize: 10.sp),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _isConfirmPasswordEmpty = false;
                });
              } else {
                setState(() {
                  _isConfirmPasswordEmpty = true;
                });
              }
            },
            controller: _confirmPasswordController,
            obscureText: _isConfirmPasswordObscure,
            validator: FieldValidator.equalTo(_passwordController,
                message: "Password Mismatch"),
            decoration: InputDecoration(
              labelText: "Re-enter password",
              prefixIcon: Icon(Icons.lock_outline),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              suffixIcon: !_isConfirmPasswordEmpty
                  ? IconButton(
                      icon: _isConfirmPasswordObscure
                          ? Icon(
                              Icons.visibility,
                            )
                          : Icon(Icons.visibility_off),
                      splashRadius: 0.2,
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordObscure =
                              !_isConfirmPasswordObscure;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class GoToLogin extends StatelessWidget {
  const GoToLogin({Key? key, required this.textSize, required this.widget})
      : super(key: key);

  final SignupScreen widget;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(
            color: Colors.black,
            fontSize: textSize.sp,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        GestureDetector(
          onTap: () {
            widget.onLoginSelected();
          },
          child: Row(
            children: [
              Text(
                "Login",
                style: TextStyle(
                  color: GFTheme.primaryColor,
                  fontSize: textSize.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Icon(
                Icons.arrow_forward,
                color: GFTheme.primaryColor,
                size: 10.sp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
