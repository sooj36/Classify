import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = 'AIzaSyBdhi3SyjsLP9Y3HFyaRjvSJRcGOydR6fE';
SharedPreferences? sharedPreferences;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
GenerativeModel? model;

Future<void> initSharedPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
}

void initGemini() {
  model = GenerativeModel(
    model: 'gemini-2.0-flash-lite',
    apiKey: apiKey,
  );
}
