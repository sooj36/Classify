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
    try {
      // 현재 유저가 있는지 확인
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        // 계정 삭제 후 Google Sign In에서도 로그아웃
        await GoogleSignIn().signOut();
      } else {
        throw Exception('로그인된 사용자가 없습니다');
      }
    } catch (e) {
      // 민감한 작업은 재인증이 필요할 수 있음
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        throw Exception('계정 삭제를 위해 재로그인이 필요합니다');
      }
      throw Exception('계정 삭제 중 오류 발생: $e');
    }
  }
}