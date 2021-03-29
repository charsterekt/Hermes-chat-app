import 'package:chatapp/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xff1d1d1d),
            backwardsCompatibility: false,
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Color(0xff232323),
                statusBarIconBrightness: Brightness.light),
            title: Text(
              "Hermes",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffF4C2C2)),
            )),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover)),
          child: isLoading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center(
                  child: GestureDetector(
                    onTap: () {
                      AuthMethods().signInWithGoogle(context);
                      setState(() {
                        isLoading = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xffffffff)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Tab(
                            icon: Image.asset("assets/images/google.png"),
                          ),
                          Text("Sign In with Google",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
        ));
  }
}
