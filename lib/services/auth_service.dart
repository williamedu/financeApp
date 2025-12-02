import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firestore_service.dart'; // ← AGREGAR ESTE IMPORT

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService =
      FirestoreService(); // ← AGREGAR ESTO

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login con Google (optimizado para web y móvil)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Para WEB: usar GoogleAuthProvider popup
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // Para MÓVIL: usar GoogleSignIn
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      print('Error en Google Sign In: $e');
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  // Verificar si es primera vez del usuario
  Future<bool> isFirstTime(String uid) async {
    return await _firestoreService.isFirstTime(uid);
  }
}
