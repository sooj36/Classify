import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weathercloset/domain/models/auth/signup_user_model.dart';
import 'package:weathercloset/global/global.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({required UserModel user}) async {
    await _firestore.collection("users").doc(user.uid).set({
      "userUID": user.uid,
      "userEmail": user.email,
      "userName": user.name,
      "phone": user.phone,
      "status": user.status,
    });
  }

  // Future<void> updateUser({required UserModel user}) async {
  //   await _firestore.collection("users").doc(user.uid).update();
  // }

  Future<void> deleteUser() async {
    await _firestore.collection("users").doc(firebaseAuth.currentUser!.uid).delete();
  }

  Future<void> saveCloth(Map<String, dynamic> cloth) async {
    await _firestore
    .collection("users")
    .doc(firebaseAuth.currentUser!.uid)
    .collection("cloths")
    .add(cloth);
  }

  Stream<QuerySnapshot> watchCloth() {
    return _firestore
    .collection("users")
    .doc(firebaseAuth.currentUser!.uid)
    .collection("cloths")
    .snapshots();
  }

  // Future<UserModel> getUser({required UserModel user}) async {
  //   final userData = await _firestore.collection("users").doc(user.uid).get();
  //   return UserModel(
  //     uid: userData.data()?["userUID"],
  //     email: userData.data()?["userEmail"],
  //     name: userData.data()?["userName"],
  //     phone: userData.data()?["phone"],
  //     status: userData.data()?["status"],
  //   );
  // }
}
