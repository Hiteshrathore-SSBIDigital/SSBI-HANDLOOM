import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';
import 'package:path/path.dart' as path;

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController docController = TextEditingController();
  final TextEditingController captchaController = TextEditingController();

  bool isValidCaptcha = false;
  bool isNameValid = false;
  bool isMessageValid = false;
  bool isEmailValid = false;
  bool isMobileValid = false;
  bool isDocValid = false;
  bool isSelectDocEnabled = false;

  String captchaText = '';
  String selectedSuggestion = '';
  String errorMessage = '';
  List<String> suggestions = [
    'Select Suggestion',
    'IOT Device',
    'Mobile Application',
    'General Inquiries',
    'Feedback',
    'Other Queries'
  ];

  File? docFile;

  @override
  void initState() {
    super.initState();
    selectedSuggestion = suggestions.first;
    _generateCaptcha();
  }

  void _generateCaptcha() {
    captchaText = _generateRandomText();
    setState(() {});
  }

  String _generateRandomText() {
    const chars = 'ABCDEFGHIJKMNPQRSTUVWXYZabcdefghjklmnpqrstuvwxyz123456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)])
        .join();
  }

  void validateEmail(String email) {
    setState(() {
      isEmailValid =
          email.isEmpty || !email.contains('@') || !email.contains('.');
    });
  }

  Future<void> _uploadDocument() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      docFile = File(pickedFile.path);
      if (await docFile!.length() <= 1048576) {
        // 1MB
        setState(() {
          docController.text = path.basename(pickedFile.path);
          isDocValid = true;
        });
      } else {
        _showDialog('Upload Document Size Limit Exceeded!',
            'Please select a document with a maximum size of 1MB.');
      }
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          content: Text(content, style: TextStyle(fontSize: 13)),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(), child: Text('OK'))
          ],
        );
      },
    );
  }

  void _handleChanged(String value) {
    String sanitizedValue = value
        .replaceAll(RegExp(r'[^\d]'), '')
        .substring(0, min(value.length, 10));
    setState(() {
      mobileController.value = TextEditingValue(
        text: sanitizedValue,
        selection: TextSelection.collapsed(offset: sanitizedValue.length),
      );
      isMobileValid = sanitizedValue.length == 10 &&
          RegExp(r'^[0-9]+$').hasMatch(sanitizedValue);
    });
  }

  void validateMessage() {
    setState(() {
      isMessageValid = messageController.text.length >= 100;
    });
  }

  void _onSubmit() {
    setState(() {
      isNameValid = nameController.text.isEmpty;
      isEmailValid = emailController.text.isEmpty;
      isMobileValid = mobileController.text.isEmpty;
      isDocValid = docController.text.isEmpty;
      isValidCaptcha = captchaController.text.isEmpty;
      isMessageValid = messageController.text.isEmpty;

      if (selectedSuggestion == suggestions.first) {
        isSelectDocEnabled = true;
      } else {
        isSelectDocEnabled = false;
      }

      if (captchaController.text == captchaText) {
        errorMessage = '';
        _generateCaptcha();
      } else {
        errorMessage = 'Invalid Captcha';
        captchaController.clear();
        return;
      }

      if (!isMessageValid ||
          !isNameValid ||
          !isEmailValid ||
          !isMobileValid ||
          !isDocValid) {
        return;
      }

      _submitForm();
    });
  }

  void _submitForm() {
    // Place your form submission logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Contact Us",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Color(ColorVal),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
                "Name", nameController, isNameValid, "Please enter Name"),
            SizedBox(
              height: 10,
            ),
            _buildTextField(
                "Email", emailController, isEmailValid, "Please enter email",
                keyboardType: TextInputType.emailAddress,
                onChanged: validateEmail),
            SizedBox(
              height: 10,
            ),
            _buildTextField("Mobile No", mobileController, isMobileValid,
                "Please enter mobile no",
                keyboardType: TextInputType.number, onChanged: _handleChanged),
            SizedBox(
              height: 10,
            ),
            _buildDropdownField("Suggestion", suggestions, selectedSuggestion,
                (value) {
              setState(() {
                if (value != suggestions.first) {
                  selectedSuggestion = value!;
                }
              });
            }),
            SizedBox(
              height: 10,
            ),
            _buildTextField("Message", messageController, isMessageValid,
                "Please enter a message",
                maxLines: 10, onChanged: (value) => validateMessage()),
            SizedBox(
              height: 10,
            ),
            _buildDocumentUploader(
                "Upload Document", docController, isDocValid),
            SizedBox(
              height: 10,
            ),
            _buildCaptchaField(
                "Captcha", captchaText, captchaController, isValidCaptcha),
            SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: _onSubmit,
                child: Text("Submit",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(ColorVal),
                    minimumSize:
                        Size(MediaQuery.of(context).size.width / 2.5, 40)),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      bool isValid, String errorText,
      {int maxLines = 1,
      TextInputType? keyboardType,
      void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('*', style: TextStyle(color: Colors.red))
          ],
        ),
        SizedBox(height: 2),
        Container(
          height: 35,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 0, color: Colors.grey)),
          child: Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 15),
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
              controller: controller,
              style: TextStyle(fontSize: 12),
              maxLines: maxLines,
              keyboardType: keyboardType,
              onChanged: onChanged,
            ),
          ),
        ),
        if (isValid)
          Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(errorText,
                  style: TextStyle(color: Colors.red, fontSize: 12))),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('*', style: TextStyle(color: Colors.red))
          ],
        ),
        SizedBox(height: 2),
        Container(
          height: 35,
          width: MediaQuery.of(context).size.height / 1,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 0, color: Colors.grey)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items
                  .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(item, style: TextStyle(fontSize: 12)))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploader(
      String label, TextEditingController controller, bool isValid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('*', style: TextStyle(color: Colors.red))
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: InkWell(
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0, color: Colors.grey)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 15),
                    child: TextField(
                      decoration: InputDecoration(border: InputBorder.none),
                      controller: controller,
                      style: TextStyle(fontSize: 12),
                      readOnly: true,
                    ),
                  ),
                ),
                onTap: () {
                  _uploadDocument();
                },
              ),
            ),
          ],
        ),
        if (isValid)
          Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text("Please upload a document",
                  style: TextStyle(color: Colors.red, fontSize: 12))),
      ],
    );
  }

  Widget _buildCaptchaField(String label, String captcha,
      TextEditingController controller, bool isValid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('*', style: TextStyle(color: Colors.red))
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width / 4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 0, color: Colors.grey)),
              child:
                  Center(child: Text(captcha, style: TextStyle(fontSize: 18))),
            ),
            IconButton(
              onPressed: _generateCaptcha,
              icon: Icon(Icons.restart_alt, color: Color(ColorVal)),
            ),
          ],
        ),
        SizedBox(height: 10),
        _buildTextField("Enter Captcha", captchaController, isValidCaptcha,
            "Please enter Captcha"),
        // if (errorMessage.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 5),
        //     child: Text(errorMessage,
        //         style: TextStyle(color: Colors.red, fontSize: 12)),
        //   ),
      ],
    );
  }
}
