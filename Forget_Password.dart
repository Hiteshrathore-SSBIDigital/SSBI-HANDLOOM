import 'package:flutter/material.dart';
import 'package:nehhdc_app/Model_Screen/APIs_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';

class Forget_Password extends StatefulWidget {
  @override
  _Forget_PasswordState createState() => _Forget_PasswordState();
}

class _Forget_PasswordState extends State<Forget_Password> {
  final TextEditingController _Usercontroller = TextEditingController();
  final TextEditingController _Mailcontroller = TextEditingController();
  bool _Uservalidate = false;
  bool _Mailvalidate = false;

  String message = '';
  void fetchForget(BuildContext context) async {
    try {
      // Show the "Please Wait" dialog
      plaesewaitmassage(context);

      Forgetapis forgetapis = Forgetapis();
      Tempforget tempForget = await forgetapis.Fetchforget(
          _Usercontroller.text.trim(), _Mailcontroller.text.trim());

      setState(() {
        message = tempForget.tempmass;
        Navigator.of(context).pop();
        showForgetMessage(context, message);
      });
      Navigator.of(context).pop();
      showForgetMessage(context, message);
    } catch (e) {
      Navigator.of(context).pop();

      setState(() {
        message = 'Error: $e';
        showForgetMessage(context, message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(color: Color(ColorVal)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Forget Password",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Enter the email address associated with your account or",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "User ID and we'll send you a link a rest your password ",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 160),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)),
                    color: Colors.white,
                  ),
                  height: MediaQuery.of(context).size.height / 0.90,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 200, left: 20, right: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.mail_lock_outlined,
                      size: 100,
                      color: Color(ColorVal),
                    ),
                    TextField(
                      controller: _Usercontroller,
                      decoration: InputDecoration(
                          errorText:
                              _Uservalidate ? 'Please enter the user id' : null,
                          label:
                              Text("User Id", style: TextStyle(fontSize: 14))),
                    ),
                    TextField(
                      controller: _Mailcontroller,
                      decoration: InputDecoration(
                          errorText:
                              _Mailvalidate ? 'Please enter the email' : null,
                          label: Text("Email", style: TextStyle(fontSize: 14))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width / 2.5,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(ColorVal)),
                          child: Center(
                              child: Text(
                            "Continue",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                        ),
                        onTap: () {
                          setState(() {
                            _Uservalidate = _Usercontroller.text.isEmpty;
                            _Mailvalidate = _Mailcontroller.text.isEmpty;
                          });

                          if (_Mailvalidate || _Uservalidate) {
                            // Show error message for empty username or password
                            return;
                          }
                          fetchForget(
                            context,
                          );
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Color(ColorVal),
                        ),
                        InkWell(
                          child: Text(
                            "Back to login",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(ColorVal)),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
