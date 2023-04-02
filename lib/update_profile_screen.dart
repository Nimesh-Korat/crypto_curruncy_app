import 'package:crypto_curruncy_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatelessWidget {
  UpdateProfileScreen({super.key});

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController age = TextEditingController();
  bool isDarkModeEnabled = AppTheme.isDarkModeEnabled;

  Future<void> saveData(String key, String value) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.setString(key, value);
  }

  void saveUserDetails() async {
    await saveData('name', name.text);
    await saveData('email', email.text);
    await saveData('age', age.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkModeEnabled
          ? const Color.fromARGB(255, 37, 33, 33)
          : Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: isDarkModeEnabled ? Colors.white : Colors.black,
        ),
        title: Text(
          "Update Profile",
          style:
              TextStyle(color: isDarkModeEnabled ? Colors.white : Colors.black),
        ),
        backgroundColor: isDarkModeEnabled
            ? const Color.fromARGB(255, 58, 54, 54)
            : Colors.white,
      ),
      body: Column(
        children: [
          customTextField("Name", name, false),
          customTextField("E-Mail", email, false),
          customTextField("Age", age, true),
          ElevatedButton(
              onPressed: () {
                saveUserDetails();
              },
              child: const Text("Save Details"))
        ],
      ),
    );
  }

  Widget customTextField(
    String title,
    TextEditingController controller,
    bool isAgeTextField,
  ) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        style: TextStyle(
          color: isDarkModeEnabled ? Colors.white : Colors.black,
        ),
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDarkModeEnabled ? Colors.white : Colors.grey,
            ),
          ),
          hintText: title,
          hintStyle: TextStyle(
            color: isDarkModeEnabled ? Colors.white : Colors.black,
          ),
        ),
        keyboardType: isAgeTextField ? TextInputType.number : null,
      ),
    );
  }
}
