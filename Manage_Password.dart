import 'package:flutter/material.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';

class Manage_Password extends StatefulWidget {
  final String? password;
  final int minLength;
  final int minDigits;
  final int minSpecialChars;

  Manage_Password({
    this.password,
    this.minLength = 8,
    this.minDigits = 1,
    this.minSpecialChars = 1,
  });

  @override
  _Manage_PasswordState createState() => _Manage_PasswordState();
}

class _Manage_PasswordState extends State<Manage_Password> {
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String errorMessage = '';

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _togglePasswordVisibility(bool isCurrentPassword) {
    setState(() {
      if (isCurrentPassword) {
        _obscureCurrentPassword = !_obscureCurrentPassword;
      } else {
        _obscureNewPassword = !_obscureNewPassword;
      }
    });
  }

  void _validatePasswords() {
    setState(() {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        errorMessage = "Passwords do not match";
      } else {
        errorMessage = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(ColorVal),
        title: Text("Manage Password",
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(
              label: "Current Password",
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              toggleVisibility: () => _togglePasswordVisibility(true),
            ),
            SizedBox(height: 10),
            _buildPasswordField(
              label: "New Password",
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              toggleVisibility: () => _togglePasswordVisibility(false),
            ),
            SizedBox(height: 10),
            _buildPasswordField(
              label: "Confirm Password",
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              toggleVisibility: () => setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }),
              onChanged: _validatePasswords,
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                onPressed: () {},
                child: Text("Reset Password",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Container(
          height: 40,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              suffixIcon: IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: toggleVisibility,
              ),
              border: OutlineInputBorder(),
            ),
            onChanged: onChanged != null ? (_) => onChanged() : null,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
