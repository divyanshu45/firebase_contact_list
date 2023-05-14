import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseFunctions {

  static final _auth = FirebaseAuth.instance;

  static Future uploadUserDetails(
      {required String email, required String uid}) async {
    try {
      await FirebaseFirestore.instance.collection('users')
          .doc(uid)
          .set({
        'email': email,
      });
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  static Future createContact(
      {required String name, required String phone}) async {
    try {
      await FirebaseFirestore.instance.collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('contacts')
          .add({
        'name': name,
        'phone': phone,
      });
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  static Future updateContact(
      {required String name, required String phone, required String docId}) async {
    try {
      await FirebaseFirestore.instance.collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('contacts')
          .doc(docId)
          .set({
        'name': name,
        'phone': phone,
      });
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  static Future deleteContact(
      {required String docId}) async {
    try {
      await FirebaseFirestore.instance.collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('contacts')
          .doc(docId)
          .delete();
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}