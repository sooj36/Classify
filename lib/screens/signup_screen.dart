// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weathercloset/global/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart' as fstorage;
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weathercloset/screens/home_screen.dart';
import 'package:weathercloset/test.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // XFile? imageXFile;
  // final ImagePicker _picker = ImagePicker();

  // String userImageUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // addProfilePhoto(context),
            const SizedBox(height: 10),
            signUpForm(),
            const SizedBox(height: 10),
            signUpButton(),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      )
    );
  }

  ElevatedButton signUpButton() {
    return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF68CAEA),
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
          ),
          onPressed: () {
            debugPrint("[가입신청 버튼]을 누름");
            formValidation();
          },
          child: const Text(
            "가입신청",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
  }

  Form signUpForm() {
    return Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                data: Icons.person,
                controller: nameController,
                hintText: "이름",
                isObsecre: false,
              ),
              CustomTextField(
                data: Icons.email,
                controller: emailController,
                hintText: "이메일",
                isObsecre: false,
              ),
              CustomTextField(
                data: Icons.phone,
                controller: phoneController,
                hintText: "전화번호",
                isObsecre: false,
              ),
              CustomTextField(
                data: Icons.lock,
                controller: passwordController,
                hintText: "비밀번호",
                isObsecre: true,
              ),
              CustomTextField(
                data: Icons.lock,
                controller: confirmPasswordController,
                hintText: "비밀번호 확인",
                isObsecre: true,
              ),
            ],
          ),
        );
  }

  // InkWell addProfilePhoto(BuildContext context) {
  //   return InkWell(
  //         onTap: () {
  //           _getImage();
  //         },
  //         child: CircleAvatar(
  //           radius: MediaQuery.of(context).size.width * 0.20,
  //           backgroundColor: Colors.white,
  //           backgroundImage: imageXFile == null ? null : FileImage(File(imageXFile!.path)),
  //           child: imageXFile == null
  //               ? Icon(
  //                   Icons.add_photo_alternate,
  //                   size: MediaQuery.of(context).size.width * 0.20,
  //                   color: Colors.grey,
  //                 )
  //               : null,
  //         ),
  //       );
  // }

  // Future<void> _getImage() async {
  //   imageXFile = await _picker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     imageXFile;
  //   });
  // }

  Future<void> formValidation() async {
    // if (imageXFile == null) {
    //   return showDialog(
    //       context: context,
    //       builder: (c) {
    //         return const ErrorDialog(
    //           message: "이미지를 선택해주세요.",
    //         );
    //       });
    // }
    if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            emailController.text.isNotEmpty && 
            nameController.text.isNotEmpty) {
          debugPrint("모든 입력 속성이 잘 입력되었음");
          showDialog(
              context: context,
              builder: (c) {
                return const LoadingDialog(
                  message: "계정 생성 중",
                );
              });
          debugPrint("계정생성 시작");
          authenticateUserAndSignUp();
          // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          // fstorage.Reference reference = fstorage.FirebaseStorage.instance.ref().child("users").child(fileName);
          // fstorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
          // fstorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          // await taskSnapshot.ref.getDownloadURL().then((url) {
          //   userImageUrl = url;
          // });
        } else {
          showDialog(
              context: context,
              builder: (c) {
                return const ErrorDialog(
                  message: "모든 정보를 입력해주세요.",
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "비밀번호가 일치하지 않습니다.",
              );
            });
      }
  }

  void authenticateUserAndSignUp() async {
    User? currentUser;

    await firebaseAuth
        .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });
    if (currentUser != null) {
      debugPrint("성공적으로 새 유저 생성 완료");
      saveDataToFireStore(currentUser!).then((value) {
        //formValidation에서 생성한 dialog 제거
        Navigator.pop(context);
        //signup이 완료되었으니 메인 화면으로 갈 준비
        Route newRoute = MaterialPageRoute(builder: (c) => const HomeScreen());
        //스택 상 최상위 페이지를 signupscreen -> newRoute로 교체
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFireStore(User currentUser) async {
    FirebaseFirestore.instance.collection("users").doc(currentUser.uid).set({
      "userUID": currentUser.uid,
      "userEmail": currentUser.email,
      "userName": nameController.text.trim(),
      // "userAvatarUrl": userImageUrl,
      "phone": phoneController.text.trim(),
      "status": "approved",
    });

    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("name", nameController.text.trim());
    // await sharedPreferences!.setString("photoUrl", userImageUrl);
    await sharedPreferences!.setString("phone", phoneController.text.trim());
  }

}
