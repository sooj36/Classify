import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_gemini/google_gemini.dart';

const apiKey = 'AIzaSyBdhi3SyjsLP9Y3HFyaRjvSJRcGOydR6fE';
SharedPreferences? sharedPreferences;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
GoogleGemini? gemini;

Future<void> initSharedPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
}

void initGemini() {
  gemini = GoogleGemini(
    apiKey: apiKey,
  );
}