import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/features/auth1/presentation/bloc/auth_state.dart';
import 'package:thesavage/features/auth1/domain/use_cases/login_user.dart';
import 'package:thesavage/features/auth1/domain/use_cases/register_user.dart';
import 'package:thesavage/features/auth1/domain/use_cases/google_login_user.dart'; // Added
import 'package:thesavage/features/auth1/domain/repositories/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final GoogleLoginUser _googleLoginUser; // Added
  final AuthRepository _authRepository;

  AuthCubit(
      this._loginUser,
      this._registerUser,
      this._googleLoginUser, // Added
      this._authRepository,
      ) : super(AuthInitial());

  Future<void> googleSignIn() async {
    try {
      emit(AuthLoading());
      
      // Step 1: Sign in with Google
      // Platform-specific configuration: Web uses clientId, Android/iOS use serverClientId
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        clientId: kIsWeb ? '713764696012-lpi2c1dsig6t6mgsj9leiup44ff2gec6.apps.googleusercontent.com' : null,
        serverClientId: !kIsWeb ? '713764696012-lpi2c1dsig6t6mgsj9leiup44ff2gec6.apps.googleusercontent.com' : null,
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        emit(AuthInitial()); // User canceled
        return;
      }

      // Step 2: Get Google Auth credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Step 3: Create Firebase credential from Google tokens
      final firebase_auth.OAuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase with Google credential
      final firebase_auth.UserCredential firebaseUserCredential = 
          await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      
      // Step 5: Get ID Token from Firebase User
      final String? idToken = await firebaseUserCredential.user?.getIdToken();
      
      print('Firebase ID Token: $idToken');

      if (idToken == null) {
        emit(const AuthFailure(error: 'Failed to retrieve Firebase ID Token'));
        return;
      }

      // Step 6: Send ID Token to your backend
      final user = await _googleLoginUser(idToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", user.token ?? "");
      await prefs.setString("userEmail", user.email);
      await prefs.setString("userId", user.id); // Save User ID

      emit(AuthSuccess(token: user.token ?? '', user: user));
      
      await fetchUserProfile();

    } catch (e) {
      print('Google Sign-In Error: $e');
      String errorMessage = 'Google Sign-In Failed: $e';
      
      if (e is PlatformException) {
        if (e.code == 'sign_in_failed') {
          errorMessage = 'Google Sign-In Failed (ApiException 10). This usually means the SHA-1 or SHA-256 fingerprint is missing in Firebase, or the Support Email is not set.';
        }
      }
      
      emit(AuthFailure(error: errorMessage));
    }
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(const AuthFailure(error: 'البريد وكلمة المرور لا يمكن أن تكون فارغة.'));
      return;
    }

    emit(AuthLoading());

    try {
      final user = await _loginUser(email, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", user.token ?? "");
      await prefs.setString("userEmail", user.email);
      await prefs.setString("userId", user.id); // Add this line

      emit(AuthSuccess(token: user.token ?? '', user: user));

      await fetchUserProfile();

    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> register({
    required String userName, // Added userName
    required String email,
    required String password,
    required String role, 
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    emit(AuthLoading());

    try {
      final user = await _registerUser(
        userName: userName, // Use the passed userName
        email: email,
        password: password,
        role: role, // ✅ Pass role correctly
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", user.token ?? "");
      await prefs.setString("userEmail", user.email);
      await prefs.setString("userId", user.id);

      emit(AuthSuccess(token: user.token ?? '', user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }


  Future<void> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final email = prefs.getString("userEmail");

      if (token == null || token.isEmpty || email == null || email.isEmpty) return;

      final user = await _authRepository.getUserProfile(email);

      await prefs.setString("firstName", user.firstName ?? "");
      await prefs.setString("lastName", user.lastName ?? "");
      await prefs.setString("userRole", user.role);
      await prefs.setString("userEmail", user.email);
      await prefs.setString("userId", user.id); // Fix: Ensure userId is always saved
      print("AuthCubit: Profile fetched & userId saved: ${user.id}");

      emit(AuthSuccess(token: token, user: user));
    } catch (e) {
      print("Failed to fetch profile: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthInitial());
  }
}
