
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginService {
  static List<String> scopes = <String>[
  'email',
];

  Future<UserCredential> signInWithGoogle() async {
    // Google Sign In 진행
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    
    // 인증 정보 가져오기
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    
    // credential 생성
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    
    // Firebase에 로그인하고 UserCredential 반환
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    await FirebaseAuth.instance.currentUser?.delete();
  }
}