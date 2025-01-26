import 'package:weathercloset/global/global.dart';
import 'package:weathercloset/widgets/custom_text_field.dart';
import 'package:weathercloset/widgets/error_dialog.dart';
import 'package:weathercloset/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weathercloset/screens/signup_screen.dart';
import 'package:weathercloset/screens/root_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late bool rememberMe;

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
    rememberMe = false;

    if (sharedPreferences != null && sharedPreferences!.containsKey("savedEmail")) {
      emailController.text = sharedPreferences!.getString("savedEmail") ?? "";
      rememberMe = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("WeatherCloset", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
          const SizedBox(height: 20,),
          longinForm(),
          const SizedBox(height: 10,),
          buildButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Form longinForm() {
    return Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                data: Icons.email,
                controller: emailController,
                hintText: "Email",
                isObsecre: false,
              ),
              CustomTextField(
                data: Icons.lock,
                controller: passwordController,
                hintText: "비밀번호",
                isObsecre: true, 
              ),
            ],
          ),
        );
  }

  Widget buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF68CAEA),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                formValidation();
              },
              child: const Text(
                "로그인",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),  // 버튼 사이 간격
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF68CAEA),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: const Text(
                "회원가입",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  //login 전에 textfield에 아이디와 비밀번호가 잘 입력되어 있는지 확인
  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //rememberMe가 true이면 이메일을 기기에 저장
      if (rememberMe) {
        sharedPreferences?.setString("savedEmail", emailController.text);
      } else {
        // If Remember Me is unchecked, remove the saved email
        sharedPreferences?.remove("savedEmail");
      }
      //login
      loginNow();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "이메일과 비밀번호를 입력해주세요.",
            );
          });
    }
  }

  loginNow() async {
    showDialog(
        context: context,
        builder: (c) {
          return const LoadingDialog(
            message: "정보를 확인하는 중",
          );
        });

    User? currentUser;
    await firebaseAuth
      .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      )
      .then((auth) { 
        currentUser = auth.user!;
        Navigator.pushAndRemoveUntil( //새로운 화면으로 이동하면서 모든 이전 루트 제거
          context,
          MaterialPageRoute(builder: (context) => const RootScreen()),
          (route) => false,  // 실질적으로 모든 이전 루트 제거는 여기서 이뤄짐
        );
      })
      .catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "등록되지 않은 사용자입니다. 먼저 회원가입을 해주세요.",
            );
          });
    });
    // if (currentUser != null) {
    //   readDataAndSetDataLocally(currentUser!);
    // }
  }

  // Future readDataAndSetDataLocally(User currentUser) async {
  //   await FirebaseFirestore.instance.collection("users").doc(currentUser.uid).get().then((snapshot) async {
  //     if (snapshot.exists) {
  //       await sharedPreferences!.setString("uid", currentUser.uid);
  //       await sharedPreferences!.setString("email", snapshot.data()!["userEmail"]);
  //       await sharedPreferences!.setString("name", snapshot.data()!["userName"]);
  //       await sharedPreferences!.setString("photoUrl", snapshot.data()!["userAvatarUrl"]);

  //       Navigator.pop(context);
  //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TestWidget(text: "Test")));
  //     } else {
  //       firebaseAuth.signOut();
  //       Navigator.pop(context);
  //       Navigator.push(context, MaterialPageRoute(builder: (c) => const TestWidget(text: "test")));

  //       showDialog(
  //           context: context,
  //           builder: (c) {
  //             return const ErrorDialog(
  //               message: "계정을 찾을 수 없습니다.",
  //             );
  //           });
  //     }
  //   });
  // }

}
