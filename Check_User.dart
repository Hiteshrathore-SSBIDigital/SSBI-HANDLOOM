import 'package:flutter/material.dart';
import 'package:nehhdc_app/Model_Screen/APIs_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';

class Registered_Screen extends StatefulWidget {
  @override
  _Registered_ScreenState createState() => _Registered_ScreenState();
}

class _Registered_ScreenState extends State<Registered_Screen> {
  final TextEditingController _mailcontroller = TextEditingController();
  String message = '';

  bool _mailvalidate = false;

  void fetchmail(BuildContext context) async {
    try {
      plaesewaitmassage(context);

      RegisteredAPIs registeredAPIs = RegisteredAPIs();
      Tempmail tempMail =
          await registeredAPIs.fetchRegisteredMail(_mailcontroller.text);

      setState(() {
        message = tempMail.tempurl;
        // Update the message state variable with the fetched message
        Navigator.of(context).pop();
        showRegisteredMessage(context, message);
      });
      Navigator.of(context).pop();
      showRegisteredMessage(context, message);
      // Dismiss the "Please Wait" dialog after updating the message
    } catch (e) {
      // Dismiss the "Please Wait" dialog if it's still showing
      Navigator.of(context).pop();

      setState(() {
        message = 'Error: $e';
        // Display error message dialog
        showRegisteredMessage(context, message);
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
                        "Registered Mail !",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    color: Colors.white,
                  ),
                  height: MediaQuery.of(context).size.height / 0.90,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 100,
                        color: Color(ColorVal),
                      ),
                    ),
                    Text(
                      "Email",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: _mailvalidate ? 35 : 35,
                      //    width: MediaQuery.of(context).size.width / 2.4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 0, color: Colors.grey)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 5),
                        child: TextField(
                          decoration: InputDecoration(border: InputBorder.none),
                          textAlign: TextAlign.left, // Align text to the left
                          controller: _mailcontroller,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    if (_mailvalidate) // Placing the error message outside the row
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: Text(
                          'Please enter the registered email',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 50,
                    ),
                    InkWell(
                        child: Center(
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width / 2.5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(ColorVal)),
                            child: Center(
                                child: Text(
                              "Submit",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _mailvalidate = _mailcontroller.text.isEmpty;
                          });

                          if (_mailvalidate) {
                            // Show error message for empty username or password
                            return;
                          }
                          fetchmail(context);
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
                            style: TextStyle(color: Color(ColorVal)),
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
