// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart' as fstorage;
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:weathercloset/screens/root_screen.dart';
import '../../widgets/custom_text_field.dart';
// import '../../widgets/error_dialog.dart';
// import '../../widgets/loading_dialog.dart';
import 'package:provider/provider.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController confirmPasswordController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();

//   // XFile? imageXFile;
//   // final ImagePicker _picker = ImagePicker();

//   // String userImageUrl = "";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             // addProfilePhoto(context),
//             const SizedBox(height: 55),
//             const Text("WeatherCloset", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
//             signUpForm(),
//             const SizedBox(height: 10),
//             signUpButton(),
//             const SizedBox(
//               height: 30,
//             ),
//           ],
//         ),
//       )
//     );
//   }

//   ElevatedButton signUpButton() {
//     return ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF68CAEA),
//             padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
//           ),
//           onPressed: () {
//             debugPrint("[가입신청 버튼]을 누름");
//             formValidation();
//           },
//           child: const Text(
//             "가입신청",
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//   }

//   Form signUpForm() {
//     return Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               CustomTextField(
//                 data: Icons.person,
//                 controller: nameController,
//                 hintText: "이름",
//                 isObsecre: false,
//               ),
//               CustomTextField(
//                 data: Icons.email,
//                 controller: emailController,
//                 hintText: "이메일",
//                 isObsecre: false,
//               ),
//               CustomTextField(
//                 data: Icons.phone,
//                 controller: phoneController,
//                 hintText: "전화번호",
//                 isObsecre: false,
//               ),
//               CustomTextField(
//                 data: Icons.lock,
//                 controller: passwordController,
//                 hintText: "비밀번호",
//                 isObsecre: true,
//               ),
//               CustomTextField(
//                 data: Icons.lock,
//                 controller: confirmPasswordController,
//                 hintText: "비밀번호 확인",
//                 isObsecre: true,
//               ),
//             ],
//           ),
//         );
//   }

//   // InkWell addProfilePhoto(BuildContext context) {
//   //   return InkWell(
//   //         onTap: () {
//   //           _getImage();
//   //         },
//   //         child: CircleAvatar(
//   //           radius: MediaQuery.of(context).size.width * 0.20,
//   //           backgroundColor: Colors.white,
//   //           backgroundImage: imageXFile == null ? null : FileImage(File(imageXFile!.path)),
//   //           child: imageXFile == null
//   //               ? Icon(
//   //                   Icons.add_photo_alternate,
//   //                   size: MediaQuery.of(context).size.width * 0.20,
//   //                   color: Colors.grey,
//   //                 )
//   //               : null,
//   //         ),
//   //       );
//   // }

//   // Future<void> _getImage() async {
//   //   imageXFile = await _picker.pickImage(source: ImageSource.gallery);
//   //   setState(() {
//   //     imageXFile;
//   //   });
//   // }

//   Future<void> formValidation() async {
//     // if (imageXFile == null) {
//     //   return showDialog(
//     //       context: context,
//     //       builder: (c) {
//     //         return const ErrorDialog(
//     //           message: "이미지를 선택해주세요.",
//     //         );
//     //       });
//     // }
//     if (passwordController.text == confirmPasswordController.text) {
//         if (confirmPasswordController.text.isNotEmpty &&
//             emailController.text.isNotEmpty && 
//             nameController.text.isNotEmpty) {
//           debugPrint("모든 입력 속성이 잘 입력되었음");
//           showDialog(
//               context: context,
//               builder: (c) {
//                 return const LoadingDialog(
//                   message: "계정 생성 중",
//                 );
//               });
//           debugPrint("계정생성 시작");
//           authenticateUserAndSignUp();
//           // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//           // fstorage.Reference reference = fstorage.FirebaseStorage.instance.ref().child("users").child(fileName);
//           // fstorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
//           // fstorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
//           // await taskSnapshot.ref.getDownloadURL().then((url) {
//           //   userImageUrl = url;
//           // });
//         } else {
//           showDialog(
//               context: context,
//               builder: (c) {
//                 return const ErrorDialog(
//                   message: "모든 정보를 입력해주세요.",
//                 );
//               });
//         }
//       } else {
//         showDialog(
//             context: context,
//             builder: (c) {
//               return const ErrorDialog(
//                 message: "비밀번호가 일치하지 않습니다.",
//               );
//             });
//       }
//   }

//   void authenticateUserAndSignUp() async {
//     User? currentUser;
//     debugPrint("🔄 인증 시작");

//     await firebaseAuth
//         .createUserWithEmailAndPassword(
//       email: emailController.text.trim(),
//       password: passwordController.text.trim(),
//     )
//         .then((auth) {
//       currentUser = auth.user;
//       debugPrint("✅ 유저 생성 성공: ${currentUser?.uid}");
//     }).catchError((error) {
//       Navigator.pop(context);
//       debugPrint("❌ 인증 에러: $error");
//       showDialog(
//           context: context,
//           builder: (c) {
//             return ErrorDialog(
//               message: error.message.toString(),
//             );
//           });
//     });

//     if (currentUser != null) {
//       try {
//         await saveDataToFireStore(currentUser!);
//         debugPrint("➡️ Firestore 저장 완료 후 페이지 처리");
        
//         // LoadingDialog를 닫고 바로 새 페이지로 이동
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const RootScreen()),
//           (route) => false,  // 모든 이전 라우트 제거
//         );
        
//       } catch (error) {
//         debugPrint("❌ Firestore 저장 에러: $error");
//         Navigator.pop(context);  // 에러 발생 시 LoadingDialog 닫기
//       }
//     }
//   }

//   Future<void> saveDataToFireStore(User currentUser) async {
//     try {
//       await FirebaseFirestore.instance.collection("users") //데이터를 쓸 폴더 지정
//                                       .doc(currentUser.uid) //문서 제목
//                                       .set({ //문서 내용
//         "userUID": currentUser.uid,
//         "userEmail": currentUser.email,
//         "userName": nameController.text.trim(),
//         "phone": phoneController.text.trim(),
//         "status": "approved",
//         // "userAvatarUrl": userImageUrl,
//       });
//       debugPrint("✅ Firestore 데이터 저장 성공!");
//       debugPrint("저장된 데이터: {");
//       debugPrint("  userUID: ${currentUser.uid}");
//       debugPrint("  userEmail: ${currentUser.email}");
//       debugPrint("  userName: ${nameController.text.trim()}");
//       debugPrint("  phone: ${phoneController.text.trim()}");
//       debugPrint("}");
//     } catch (e) {
//       debugPrint("❌ Firestore 저장 실패: $e");
//       throw e;
//     }

//     sharedPreferences = await SharedPreferences.getInstance();
//     await sharedPreferences!.setString("uid", currentUser.uid);
//     await sharedPreferences!.setString("email", currentUser.email.toString());
//     await sharedPreferences!.setString("name", nameController.text.trim());
//     await sharedPreferences!.setString("phone", phoneController.text.trim());
//     // await sharedPreferences!.setString("photoUrl", userImageUrl);
//   }
// }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String status;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.status = "approved",
  });
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    // Firebase Auth 계정 생성
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    debugPrint("✅ Firebase 계정 생성: ${userCredential.user!.uid}");

    final user = UserModel(
      uid: userCredential.user!.uid,
      email: email,
      name: name,
      phone: phone,
    );

    // Firestore에 사용자 데이터 저장
    await _firestore.collection("users").doc(user.uid).set({
      "userUID": user.uid,
      "userEmail": user.email,
      "userName": user.name,
      "phone": user.phone,
      "status": user.status,
    });
    debugPrint("✅ Firestore 데이터 저장 완료");

    return user;
  }
}

class SignUpViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String phone,
  }) async {
    if (!_validateInputs(password, confirmPassword, email, name)) {
      debugPrint("❌ 입력값 검증 실패");
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      _isLoading = false;
      notifyListeners();
      debugPrint("✅ 회원가입 완료");
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint("❌ 회원가입 실패: $e");
      return false;
    }
  }

  bool _validateInputs(String password, String confirmPassword, String email, String name) {
    if (password != confirmPassword) {
      _error = "비밀번호가 일치하지 않습니다.";
      notifyListeners();
      return false;
    }
    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      _error = "모든 정보를 입력해주세요.";
      notifyListeners();
      return false;
    }
    return true;
  }
}

class SignupScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: Consumer<SignUpViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 55),
                  const Text("WeatherCloset", 
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  signUpForm(),
                  const SizedBox(height: 10),
                  if (viewModel.error != null)
                    Text(viewModel.error!, style: const TextStyle(color: Colors.red)),
                  signUpButton(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Form signUpForm() {
    return Form(
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

  ElevatedButton signUpButton(BuildContext context, SignUpViewModel viewModel) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF68CAEA),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
      ),
      onPressed: viewModel.isLoading
          ? null
          : () async {
              final success = await viewModel.signUp(
                email: emailController.text,
                password: passwordController.text,
                confirmPassword: confirmPasswordController.text,
                name: nameController.text,
                phone: phoneController.text,
              );
              
              if (success && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const RootScreen()),
                  (route) => false,
                );
              }
            },
      child: viewModel.isLoading
          ? const CircularProgressIndicator()
          : const Text("가입신청",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}