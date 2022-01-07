import 'package:flutter/material.dart';
import 'package:frontend/app/data/models/login.dart';
import 'package:frontend/app/data/provider/api_services.dart';
import 'package:frontend/app/global_widgets/action_button.dart';
import 'package:frontend/app/global_widgets/snackbar.dart';
import 'package:frontend/app/modules/home/views/home_view.dart';
import 'package:frontend/app/theme/color_theme.dart';
import 'package:frontend/app/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:the_validator/the_validator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends StatefulWidget {
  final Function onSignUpSelected;
  LoginScreen({Key? key, required this.onSignUpSelected}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPassEmpty = true;
  bool _isObscurePass = true;

  @override
  void initState() {
    // Future.delayed(Duration.zero, () => context.read<AuthNotifier>())
    //     .then((value) => initCurrentUser(value));
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
            borderRadius: BorderRadius.all(Radius.circular(25)),
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
                : 70.w,
            child: Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Login",
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
                          title: "Login",
                          press: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              GetIt.I<APIServices>()
                                  .login(
                                      email: _emailController.text,
                                      password: _passwordController.text)
                                  .then((value) => value.loggedIn
                                      ? Get.off(() => HomeView())
                                      : SnackbarMessage(
                                          message: value.message,
                                          icon: Icon(Icons.error,
                                              color: Colors.red),
                                        ).showMessage(
                                          context,
                                        ));
                            }
                          }),
                      SizedBox(height: 32),
                      Responsive(
                          mobile: GoToRegister(
                            textSize: _size.width < 500 ? 9 : 7,
                            widget: widget,
                          ),
                          desktop: GoToRegister(
                            textSize: 7,
                            widget: widget,
                          ),
                          tablet: GoToRegister(
                            textSize: 7,
                            widget: widget,
                          )),
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
            controller: _emailController,
            validator: FieldValidator.email(),
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Colors.black, fontSize: 10.sp),
            decoration: const InputDecoration(
              // filled: true,
              labelText: "Email",
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          TextFormField(
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _isPassEmpty = false;
                });
              } else {
                setState(() {
                  _isPassEmpty = true;
                });
              }
            },
            controller: _passwordController,
            obscureText: _isObscurePass,
            validator: FieldValidator.required(),
            style: TextStyle(color: Colors.black, fontSize: 10.sp),
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock_outline),
              //filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              suffixIcon: !_isPassEmpty
                  ? IconButton(
                      icon: _isObscurePass
                          ? Icon(
                              Icons.visibility,
                            )
                          : Icon(Icons.visibility_off),
                      splashRadius: 0.2,
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          _isObscurePass = !_isObscurePass;
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

class GoToRegister extends StatelessWidget {
  const GoToRegister({
    Key? key,
    required this.textSize,
    required this.widget,
  }) : super(key: key);

  final LoginScreen widget;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account yet?",
          style: TextStyle(color: Colors.black, fontSize: textSize.sp),
        ),
        SizedBox(
          width: 8,
        ),
        GestureDetector(
          onTap: () {
            widget.onSignUpSelected();
          },
          child: Row(
            children: [
              Text(
                "Signup",
                style: TextStyle(
                    color: GFTheme.primaryColor,
                    fontSize: textSize.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 8,
              ),
              Icon(
                Icons.arrow_forward,
                color: GFTheme.primaryColor,
                size: 10.sp,
              )
            ],
          ),
        )
      ],
    );
  }
}
